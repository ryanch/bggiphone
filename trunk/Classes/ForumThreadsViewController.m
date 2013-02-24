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
@synthesize pageNumber;
@synthesize forum;

#pragma mark UIViewController overrides

- (void) userWantsMore {
    
    ForumThreadsViewController * more = [[ForumThreadsViewController alloc] init];
    more.pageNumber = self.pageNumber + 1;
	more.forum = self.forum;
    more.title = [NSString stringWithFormat:@"Page %d", more.pageNumber];
    
    [self.navigationController pushViewController:more animated:YES];
    
}

-(void) viewDidLoad
{
	[super viewDidLoad];
    
    /*
 	if ( self.navigationItem.rightBarButtonItem == nil )
	{
		UIBarButtonItem * nextButton = [[UIBarButtonItem alloc]
                                        initWithTitle:NSLocalizedString(@"More", @"more games toolbar button") style: UIBarButtonItemStyleBordered  target:self action:@selector(userWantsMore)];
		
		[self.navigationItem setRightBarButtonItem:nextButton animated:YES];
		
	}
     */
    
	
	self.tableView.rowHeight = 64;
}

#pragma mark LoadingViewController overrides

-(NSString *) cacheFileName
{
	if(self.forum == nil)
		return nil;
	
	return [NSString stringWithFormat:@"forum-threads-%@-page-%d.cache.html", self.forum.forumId,pageNumber];
}

-(NSString *) urlStringForLoading
{
	if(self.forum == nil)
		return nil;
	
	NSString * url =  [@"http://boardgamegeek.com/" stringByAppendingString:self.forum.forumURL];
    url = [url stringByAppendingFormat:@"/page/%d",pageNumber];
    
    NSLog(@"load: %@", url);
    
    return url;
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
	
	MessageThreadViewController *threadViewController = [[MessageThreadViewController alloc] init];
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
	
	cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Post %@ by %@", @"forum threads list last post format string"), thread.lastPostDate, thread.lastPoster];
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
}


- (id)init
{
    self = [super init];
    if (self) {
        pageNumber = 1;
    }
    return self;
}

@end
