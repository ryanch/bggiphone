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
//  LoadingViewController.m
//  BGG
//
//  Created by Petteri Kamppuri on 3.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "LoadingViewController.h"
#import "BGGHTMLScraper.h"
#import "BGGAppDelegate.h"


@implementation LoadingViewController

@synthesize loading;
@synthesize pageNumber;

#pragma mark Private


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0) {
        [self userRequestedReload];
    }
    else {
        [self userWantsNextPage];
    }
    
}

- (void) userWantsNextPage {
    
}


- (void) userWantsMoreOrReload {
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:
                             NSLocalizedString(@"Refresh", @"refresh"),
                             NSLocalizedString(@"More", @"more"),
                             nil ];
    
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
    
}

-(void) showRefreshButton
{
    
    refreshEnabled = YES;
    
    /*
	// add a reload button to right nav bar
	// see if we have reload button
	if ( self.navigationItem.rightBarButtonItem == nil && ([self hasCachedData] || items == nil) )
	{
		UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] 
										   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(userRequestedReload)];
		
		[self.navigationItem setRightBarButtonItem:refreshButton animated:YES];
		
	}	
	
	self.navigationItem.rightBarButtonItem.enabled = YES;

     */
    
	if ( self.navigationItem.rightBarButtonItem == nil && ([self hasCachedData] || items == nil) )
	{
		UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc]
										   initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(userWantsMoreOrReload)];
		
		[self.navigationItem setRightBarButtonItem:refreshButton animated:YES];
		
	}
    

}

-(void) disableRefreshButton
{
    refreshEnabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

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

-(void) updateViews
{
	// Intentionally empty implementation in abstract base class.
}

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

-(void) viewDidLoad
{
	[super viewDidLoad];
	
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
