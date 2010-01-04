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
	
	NSInteger row = [games indexOfObjectIdenticalTo:result];
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

-(void) loadFailed:(NSError *)error
{
	loading = NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error title.")
													message:[NSString stringWithFormat:NSLocalizedString(@"Error downloading games: %@.", @"error download top100."), error]
												   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"okay button") otherButtonTitles: nil];
	[alert show];	
	[alert release];
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void) takeResuts:(NSArray *)results
{
	loading = NO;
	
	[games release];
	games = [results retain];
	
	[self.tableView reloadData];
}

-(void) backgroundLoad
{
	if(cancelLoading)
		return;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:@"http://www.boardgamegeek.com/browse/boardgame"]];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if(responseData == nil)
	{
		NSLog(@"Download error '%@'.", error);
		[self performSelectorOnMainThread:@selector(downloadFailed:) withObject:error waitUntilDone:NO];
		return;
	}
	
	if(cancelLoading)
		return;
	
	NSString *document = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
	
	BGGHTMLScraper *htmlScraper = [[[BGGHTMLScraper alloc] init] autorelease];
	NSArray *results = [htmlScraper scrapeGamesFromTop100:document];
	
	if(cancelLoading)
		return;
	
	if(results == nil)
	{
		[self performSelectorOnMainThread:@selector(processingFailed) withObject:nil waitUntilDone:NO];
		return;
	}
	
	[self performSelectorOnMainThread:@selector(takeResuts:) withObject:results waitUntilDone:NO];
}

-(void) backgroundLoadThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self backgroundLoad];
	
	[pool release];
}

-(void) startLoadingTop100
{
	if(loading)
		return;
	
	cancelLoading = NO;
	loading = YES;
	
	[NSThread detachNewThreadSelector:@selector(backgroundLoadThread) toTarget:self withObject:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableViewActed numberOfRowsInSection:(NSInteger)section {
	if ( games == nil) {
		return 1;
	}
	else
	{
		return [games count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ( games == nil) {
		UIViewController * loadingCell = [[UIViewController alloc] initWithNibName:@"LoadingCell" bundle:nil];
		
		UITableViewCell * cell = (UITableViewCell*) loadingCell.view;
		[[cell retain] autorelease];
		
		[loadingCell release];
		
		return cell;
	}
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	
	BBGSearchResult * result = (BBGSearchResult*) [games objectAtIndex:indexPath.row];
	
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
	
	return cell;
}

- (void) loadGameFromSearchResult: (BBGSearchResult*) searchResult {
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[appDelegate loadGameFromSearchResult: searchResult];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BBGSearchResult * result = (BBGSearchResult*) [games objectAtIndex:indexPath.row];
	
	[self loadGameFromSearchResult: result];
}

#pragma mark UIViewController overrides

-(void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	cancelLoading = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	cancelLoading = NO;
	
	// save the current state
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate saveResumePoint:BGG_RESUME_BROWSE_TOP_100_GAMES withString:nil];
	
	[self.tableView reloadData];
}

-(void) viewDidLoad
{
	[super viewDidLoad];
	
	[self startLoadingTop100];
}

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
	[games release];
	[imagesLoading release];
	
	[super dealloc];
}


@end
