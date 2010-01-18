//
//  Top100ImageDownloadOperation.m
//  BGG
//
//  Created by Ryan Christianson on 1/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Top100ImageDownloadOperation.h"
#import "BGGAppDelegate.h"

@implementation Top100ImageDownloadOperation

- (void) main {

	
	NSLog( @"starting operation for: %@", searchResult.imageURL );
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate cacheGameImageAtURL:searchResult.imageURL gameID:searchResult.gameId];
	
	[top100View performSelectorOnMainThread:@selector(nsOperationDidFinishLoadingResult:) withObject: searchResult waitUntilDone:YES];
	
	[pool release];	
	
}

- (id)initWithResult:(BBGSearchResult*)result forView: (BrowseTop100ViewController*) view
{
	self = [super init];
	if (self != nil) {
		
		searchResult = result;
		top100View = view;
		
		[searchResult retain];
		[top100View retain];
		
	}
	return self;
}

- (void)dealloc {
    [searchResult release];
	searchResult = nil;
	[top100View release]; 
	top100View = nil;
    [super dealloc];
}


@end
