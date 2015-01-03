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
#import "BGGHTMLScraper.h"

@implementation LoadingTableViewController

#pragma mark LoadingViewController overrides

-(void) updateViews
{
	[self.tableView reloadData];
}


-(void) showRefreshButton
{
    
    refreshEnabled = YES;
    if ([self respondsToSelector:@selector(setRefreshControl:)]) {
        [self.refreshControl endRefreshing];
    }
    
}

-(void) disableRefreshButton
{
	refreshEnabled = NO;
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
	{
		if(items != nil && [items count] == 0) // No items
			return 1;
		else
			return [items count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ( self.isLoading) {
		UIViewController * loadingCell = [[UIViewController alloc] initWithNibName:@"LoadingCell" bundle:nil];
		
		UITableViewCell * cell = (UITableViewCell*) loadingCell.view;
		//[[cell retain] autorelease];
		
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	
	if(items != nil && [items count] == 0) // No items
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.text = NSLocalizedString(@"No items.", @"empty list text for no items.");
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:[self cellStyle] reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	[self updateCell:cell forItemAtIndexPath:indexPath];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.isLoading) // Do nothing when loading.
		return;
	if(items != nil && [items count] == 0) // Do nothing when there are no items.
		return;
	
	[self tappedAtItemAtIndexPath:indexPath];
}

#pragma mark UIViewController overrides

/*
-(void) loadView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
	
	tableView.dataSource = self;
	tableView.delegate = self;
    
  

	self.view = tableView;
}
 */

#pragma mark Public

-(UITableView *) tableView
{
	return (UITableView *) self.view;
}


#pragma mark loading view methods shared with loading view

@synthesize loading;

#pragma mark Private


-(void) loadFailed:(NSError *)error
{
	loading = NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error title.")
													message:[NSString stringWithFormat:NSLocalizedString(@"Download failed: %@.", @"download failed error."), [error localizedDescription]]
												   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"okay button") otherButtonTitles: nil];
	[alert show];
	
	[self updateViews];
	
	[self showRefreshButton];
}

-(void) processingFailed
{
	loading = NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error title.")
													message:[NSString stringWithFormat:NSLocalizedString(@"Error processing markup from BGG site.", @"Error reading markup from BGG site.")]
												   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"okay button") otherButtonTitles: nil];
	[alert show];
	
	[self updateViews];
	
	[self showRefreshButton];
}

- (void) userRequestedReload {
	items = nil;
	[self clearCachedData];
	[self startLoading];
	[self updateViews];
}

-(void) takeResults:(id)results
{
	loading = NO;
	
	items = results;
	
	[self updateViews];
}

-(void) didFinishLoadingWithResults:(id)results
{
	[self takeResults:results];
    
    
	// add a reload button to right nav bar
	// see if we have reload button
	if ( self.navigationItem.rightBarButtonItem == nil )
	{
		UIBarButtonItem * nextButton = [[UIBarButtonItem alloc]
                                        initWithTitle:NSLocalizedString(@"More", @"more games toolbar button") style: UIBarButtonItemStyleBordered  target:self action:@selector(userWantsMore)];
		
		[self.navigationItem setRightBarButtonItem:nextButton animated:YES];
		
	}
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
    
	
	[self showRefreshButton];
}

-(void) backgroundLoad
{
	if(cancelLoading)
		return;
	
	NSString *urlString = [self urlStringForLoading];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *responseData = nil;
	BOOL loadedDataFromCache = NO;
	
	// First try to find cached data
	responseData = [self loadDataFromCache];
	if(responseData != nil)
		loadedDataFromCache = YES;
	
	if(responseData == nil)
		responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if(responseData == nil)
	{
		NSLog(@"Download error '%@'.", error);
		[self performSelectorOnMainThread:@selector(loadFailed:) withObject:error waitUntilDone:NO];
		return;
	}
	
	if(cancelLoading)
		return;
	
	NSString *document = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	BGGHTMLScraper *htmlScraper = [[BGGHTMLScraper alloc] init];
	NSArray *results = [self resultsFromDocument:document withHTMLScraper:htmlScraper];
	
	if(cancelLoading)
		return;
	
	if(results == nil)
	{
		[self performSelectorOnMainThread:@selector(processingFailed) withObject:nil waitUntilDone:YES];
		return;
	}
	
	if(loadedDataFromCache == NO)
		[self cacheResponseData:responseData results:results];
	
	[self performSelectorOnMainThread:@selector(didFinishLoadingWithResults:) withObject:results waitUntilDone:YES];
}

-(void) backgroundLoadThread
{
	@autoreleasepool {
        
		[self backgroundLoad];
        
	}
	
	[NSThread exit];
}

#pragma mark Protected



-(void) cacheResponseData:(NSData *)responseData results:(id)results
{
	NSString *cacheFilePath = [self pathForCachedFile];
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if ( [fileManager fileExistsAtPath:cacheFilePath ] )
		[fileManager removeItemAtPath:cacheFilePath error:NULL];
	
	[responseData writeToFile:cacheFilePath atomically:YES];
}

-(NSString *) urlStringForLoading
{
	// Intentionally empty implementation in abstract base class.
	return nil;
}

-(id) resultsFromDocument:(NSString *)document withHTMLScraper:(BGGHTMLScraper *)htmlScraper
{
	// Intentionally empty implementation in abstract base class.
	return nil;
}

-(NSString *) cacheFileName
{
	return nil;
}

-(NSString *) pathForCachedFile
{
	NSString *cacheFileName = [self cacheFileName];
	
	if(cacheFileName == nil)
		return nil;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *cacheFilePath = [documentsDirectory stringByAppendingPathComponent:cacheFileName];
	
	return cacheFilePath;
}

- (NSData *) loadDataFromCache
{
	NSString *cacheFilePath = [self pathForCachedFile];
	
	if ( cacheFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath ] )
		return [NSData dataWithContentsOfFile:cacheFilePath];
	else
		return nil;
}

- (BOOL) hasCachedData
{
	NSString *cacheFilePath = [self pathForCachedFile];
	
	if(cacheFilePath)
		return [[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath ];
	else
		return NO;
}

- (void) clearCachedData
{
	NSString *cacheFilePath = [self pathForCachedFile];
	
	if(cacheFilePath)
		[[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:NULL];
}

#pragma mark UIViewController overrides

-(void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	cancelLoading = YES;
	loading = NO;
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	cancelLoading = NO;
	
	[self startLoading];
	[self updateViews];
	
	// save the current state
	//BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	//FIXME! [appDelegate saveResumePoint:BGG_RESUME_GAME withString:self.fullGameInfo.gameId];
}

- (void) refreshRequestedByPullDown {
    if ( refreshEnabled ) {
        [self userRequestedReload];
    }
    
}

-(void) viewDidLoad
{
    
    
    
	[super viewDidLoad];
    
    refreshEnabled = NO;
    
    if ([self respondsToSelector:@selector(setRefreshControl:)]) {
    
        UIRefreshControl * refreshControler = [[UIRefreshControl alloc] init];
        [refreshControler addTarget:self action:@selector(refreshRequestedByPullDown)
                   forControlEvents:UIControlEventValueChanged];
        
        NSLog(@"setting controller on %@", self);
        self.refreshControl = refreshControler;
        
    }
	
	[self startLoading];
}

#pragma mark Public

-(void) startLoading
{
	if(items != nil)
		return;
	
	if(loading)
		return;
	
	if([self urlStringForLoading] == nil)
		return;
	
	cancelLoading = NO;
	loading = YES;
	
	[self disableRefreshButton];
	
	[NSThread detachNewThreadSelector:@selector(backgroundLoadThread) toTarget:self withObject:nil];
}




@end
