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

-(NSString *) cacheFileName
{
	if(self.fullGameInfo == nil)
		return nil;
	
	return [NSString stringWithFormat:@"game-forums-list-%@.cache.html", self.fullGameInfo.gameId];
}

#pragma mark LoadingTableViewController overrides

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

@end
