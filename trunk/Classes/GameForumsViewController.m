/*
 Copyright 2010 Petteri Kamppuri
 
 Licensed under the Apache License, Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed under the 
 License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
 either express or implied. See the License for the specific 
 language governing permissions and limitations under the License. 
 */

//
//  GameForumsViewController.m
//  BGG
//
//  Created by Petteri Kamppuri on 3.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "GameForumsViewController.h"
#import "ForumThreadsViewController.h"
#import "BGGAppDelegate.h"
#import "BGGHTMLScraper.h"
#import "BGGForum.h"
#import "FullGameInfo.h"


@implementation GameForumsViewController

@synthesize fullGameInfo;

#pragma mark LoadingViewController overrides

-(void) updateViews
{
	[self.tableView reloadData];
}

-(NSString *) urlStringForLoading
{
	if(self.fullGameInfo == nil)
		return nil;
	
	return [@"http://boardgamegeek.com/forums/thing/" stringByAppendingString:self.fullGameInfo.gameId];
}

-(id) resultsFromDocument:(NSString *)document withHTMLScraper:(BGGHTMLScraper *)htmlScraper
{
	return [htmlScraper scrapeForumsFromList:document];
}

#pragma mark Protected overrides

-(UITableViewCellStyle) cellStyle
{
	return UITableViewCellStyleDefault;
}

-(void) tappedAtItemAtIndexPath:(NSIndexPath *)indexPath
{
	BGGForum *forum = [items objectAtIndex:indexPath.row];
	
	ForumThreadsViewController *threadsViewController = [[[ForumThreadsViewController alloc] init] autorelease];
	threadsViewController.title = forum.name;
	threadsViewController.fullGameInfo = self.fullGameInfo;
	threadsViewController.forum = forum;
	[threadsViewController startLoading];
	
	[self.navigationController pushViewController:threadsViewController animated:YES];
}

-(void) updateCell:(UITableViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	BGGForum *forum = [items objectAtIndex:indexPath.row];
	
	cell.textLabel.text = forum.name;
	cell.textLabel.adjustsFontSizeToFitWidth = NO;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableViewActed numberOfRowsInSection:(NSInteger)section {
	if ( items == nil) {
		return 1;
	}
	else
	{
		return [items count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ( items == nil) {
		UIViewController * loadingCell = [[UIViewController alloc] initWithNibName:@"LoadingCell" bundle:nil];
		
		UITableViewCell * cell = (UITableViewCell*) loadingCell.view;
		[[cell retain] autorelease];
		
		[loadingCell release];
		
		return cell;
	}
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:[self cellStyle] reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	[self updateCell:cell forItemAtIndexPath:indexPath];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tappedAtItemAtIndexPath:indexPath];
}

#pragma mark UIViewController overrides

-(void) loadView
{
	UITableView *tableView = [[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain] autorelease];
	
	tableView.dataSource = self;
	tableView.delegate = self;
	
	self.view = tableView;
}

#pragma mark Public

-(UITableView *) tableView
{
	return (UITableView *) self.view;
}

@end
