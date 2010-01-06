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

#pragma mark Private

-(void) loadFailed:(NSError *)error
{
	loading = NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error title.")
													message:[NSString stringWithFormat:NSLocalizedString(@"Error downloading forums: %@.", @"error download forums."), error]
												   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"okay button") otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

-(void) processingFailed
{
	loading = NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error title.")
													message:[NSString stringWithFormat:NSLocalizedString(@"Error processing markup from BGG site.", @"Error reading markup from BGG site.")]
												   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"okay button") otherButtonTitles: nil];
	[alert show];	
	[alert release];
}



-(void) takeResults:(NSArray *)results
{
	loading = NO;
	
	[items release];
	items = [results retain];
	
	[self updateViews];
}

-(void) backgroundLoad
{
	if(cancelLoading)
		return;
	
	NSString *urlString = [self urlStringForLoading];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if(responseData == nil)
	{
		NSLog(@"Download error '%@'.", error);
		[self performSelectorOnMainThread:@selector(loadFailed:) withObject:error waitUntilDone:NO];
		return;
	}
	
	if(cancelLoading)
		return;
	
	NSString *document = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
	
	BGGHTMLScraper *htmlScraper = [[[BGGHTMLScraper alloc] init] autorelease];
	NSArray *results = [self resultsFromDocument:document withHTMLScraper:htmlScraper];
	
	if(cancelLoading)
		return;
	
	if(results == nil)
	{
		[self performSelectorOnMainThread:@selector(processingFailed) withObject:nil waitUntilDone:NO];
		return;
	}
	
	[self cacheResponseData:responseData results:results];
	
	[self performSelectorOnMainThread:@selector(takeResults:) withObject:results waitUntilDone:NO];
}

-(void) backgroundLoadThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self backgroundLoad];
	
	[pool release];
}

#pragma mark Protected

-(void) updateViews
{
	// Intentionally empty implementation in abstract base class.
}

-(void) cacheResponseData:(NSData *)responseData results:(id)results
{
	// Intentionally empty implementation in abstract base class.
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
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
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
	
	[NSThread detachNewThreadSelector:@selector(backgroundLoadThread) toTarget:self withObject:nil];
}

-(void) dealloc
{
	[items release];
	
	[super dealloc];
}

@end
