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
//  BrowseTop100ViewController.m
//  BGG
//
//  Created by Petteri Kamppuri on 2.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "BrowseTop100ViewController.h"
#import "BBGSearchResult.h"
#import "BGGAppDelegate.h"
#import "BGGHTMLScraper.h"


@implementation BrowseTop100ViewController

#pragma mark Private

-(void) backgroundImageLoadDidFinish:(BBGSearchResult *)result
{
	if(cancelLoading)
		return;
	
	[imagesLoading removeObject:result.imageURL];
	
	NSInteger row = [items indexOfObjectIdenticalTo:result];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	if(cell == nil)
		return; // Cell for this game isn't visible.
	
	[self.tableView reloadData];
}

-(void) backgroundImageLoad:(BBGSearchResult *)result
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate cacheGameImageAtURL:result.imageURL gameID:result.gameId];
	
	[self performSelectorOnMainThread:@selector(backgroundImageLoadDidFinish:) withObject:result waitUntilDone:NO];
	
	[pool release];	
}

-(void) startLoadingImageForResult:(BBGSearchResult *)result
{
	if(result.imageURL == nil || result.gameId == nil)
		return;
	
	if([imagesLoading containsObject:result.imageURL])
		return;
	
	if(imagesLoading == nil)
		imagesLoading = [[NSMutableSet alloc] init];
	
	[imagesLoading addObject:result.imageURL];
	
	[NSThread detachNewThreadSelector:@selector(backgroundImageLoad:) toTarget:self withObject:result];
}

#pragma mark UIViewController overrides

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// save the current state
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate saveResumePoint:BGG_RESUME_BROWSE_TOP_100_GAMES withString:nil];
}

#pragma mark LoadingViewController overrides

-(NSString *) cacheFileName
{
	return @"top100.cache.html";
}

-(NSString *) urlStringForLoading
{
	return @"http://www.boardgamegeek.com/browse/boardgame";
}

-(id) resultsFromDocument:(NSString *)document withHTMLScraper:(BGGHTMLScraper *)htmlScraper
{
	return [htmlScraper scrapeGamesFromTop100:document];
}

#pragma mark LoadingTableViewController overrides

-(void) tappedAtItemAtIndexPath:(NSIndexPath *)indexPath
{
	BBGSearchResult * result = (BBGSearchResult*) [items objectAtIndex:indexPath.row];
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[appDelegate loadGameFromSearchResult: result];
}

-(void) updateCell:(UITableViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	BBGSearchResult * result = (BBGSearchResult*) [items objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, result.primaryTitle];
	cell.textLabel.adjustsFontSizeToFitWidth = NO;
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSString * imagePath = [appDelegate buildImageThumbFilePathForGameId:result.gameId];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
	
	if(fileExists == NO && result.imageURL != nil)
		[self startLoadingImageForResult:result];
	
	if (imagePath != nil && fileExists )
		cell.imageView.image = [UIImage imageWithContentsOfFile: imagePath];
	else
		cell.imageView.image = nil;
}

#pragma mark Public

-(id) init
{
	if((self = [super init]) != nil)
	{
		self.title = NSLocalizedString( @"Top 100", @"browse top 100 title" );
	}
	return self;
}

-(void) dealloc
{
	[imagesLoading release];
	
	[super dealloc];
}

@end
