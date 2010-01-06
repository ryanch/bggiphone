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
//  LoadingTableViewController.m
//  BGG
//
//  Created by Petteri Kamppuri on 6.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "LoadingTableViewController.h"


@implementation LoadingTableViewController

#pragma mark LoadingViewController overrides

-(void) updateViews
{
	[self.tableView reloadData];
}

#pragma mark Protected overrides

-(UITableViewCellStyle) cellStyle
{
	return UITableViewCellStyleDefault;
}

-(void) tappedAtItemAtIndexPath:(NSIndexPath *)indexPath
{
	// Intentionally empty implementation in abstract base class.
}

-(void) updateCell:(UITableViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	// Intentionally empty implementation in abstract base class.
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableViewActed numberOfRowsInSection:(NSInteger)section {
	if ( self.isLoading )
		return 1;
	else
		return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ( self.isLoading) {
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
