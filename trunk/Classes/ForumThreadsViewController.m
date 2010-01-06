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
//  ForumThreadsViewController.m
//  BGG
//
//  Created by Petteri Kamppuri on 3.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "ForumThreadsViewController.h"
#import "BGGAppDelegate.h"
#import "BGGForum.h"
#import "BGGThread.h"
#import "BGGHTMLScraper.h"
#import "MessageThreadViewController.h"


@implementation ForumThreadsViewController

@synthesize forum;

#pragma mark UIViewController overrides

-(void) viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.rowHeight = 64;
}

#pragma mark LoadingViewController overrides

-(NSString *) cacheFileName
{
	if(self.forum == nil)
		return nil;
	
	return [NSString stringWithFormat:@"forum-threads-%@-page-1.cache.html", self.forum.forumId];
}

-(NSString *) urlStringForLoading
{
	if(self.forum == nil)
		return nil;
	
	return [@"http://boardgamegeek.com/" stringByAppendingString:self.forum.forumURL];
}

-(id) resultsFromDocument:(NSString *)document withHTMLScraper:(BGGHTMLScraper *)htmlScraper
{
	return [htmlScraper scrapeThreadsFromForum:document];
}

#pragma mark GameForumsViewController overrides

-(UITableViewCellStyle) cellStyle
{
	return UITableViewCellStyleSubtitle;
}

-(void) tappedAtItemAtIndexPath:(NSIndexPath *)indexPath
{
	BGGThread *thread = [items objectAtIndex:indexPath.row];
	
	MessageThreadViewController *threadViewController = [[[MessageThreadViewController alloc] init] autorelease];
	threadViewController.title = thread.title;
	threadViewController.thread = thread;
	
	[self.navigationController pushViewController:threadViewController animated:YES];
}

-(void) updateCell:(UITableViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	BGGThread *thread = [items objectAtIndex:indexPath.row];
	
	cell.textLabel.text = thread.title;
	cell.textLabel.numberOfLines = 2;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
	
	cell.detailTextLabel.text = thread.lastEditDate;
}

-(void) dealloc
{
	[forum release];
	
	[super dealloc];
}

@end
