//
//  Top100ImageDownloadOperation.m
//  BGG
//
//  Created by Ryan Christianson on 1/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Top100ImageDownloadOperation.h"
#import "BGGAppDelegate.h"
#import "FullGameInfo.h"

@implementation Top100ImageDownloadOperation

- (void) main {

	
	//NSLog( @"starting operation to get image for: %@", searchResult.primaryTitle );
	
	@autoreleasepool {
	
		BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        
        if ( searchResult.imageURL == nil ) {
            
            //NSLog(@"fetch full data since no image for that list type for: %@", searchResult.primaryTitle);
            
            FullGameInfo * fullGame = [appDelegate getFullGameInfoByGameIdFromBGG: searchResult.gameId];
            
            if ( fullGame == nil) {
                NSLog(@"did not find data for game: %@", searchResult.primaryTitle);
                return;
            }
            
            searchResult.imageURL = fullGame.imageURL;
        }
        
        
		[appDelegate cacheGameImageAtURL:searchResult.imageURL gameID:searchResult.gameId];
		
        
        if ( searchView != nil ) {
            
            [searchView performSelectorOnMainThread:@selector(nsOperationDidFinishLoadingResult:) withObject: searchResult waitUntilDone:YES];
            
            
        }
        else {
        
		[top100View performSelectorOnMainThread:@selector(nsOperationDidFinishLoadingResult:) withObject: searchResult waitUntilDone:YES];
            
        }
	
	}
	
}

- (id)initWithResult:(BBGSearchResult*)result forSearchView: (BoardGameSearchResultsTableViewController*) view {
	self = [super init];
	if (self != nil) {
		
		searchResult = result;
		searchView = view;
		
		
	}
	return self;
}


- (id)initWithResult:(BBGSearchResult*)result forView: (BrowseTop100ViewController*) view
{
	self = [super init];
	if (self != nil) {
		
		searchResult = result;
		top100View = view;
		
		
	}
	return self;
}

- (void)dealloc {
	searchResult = nil;
	top100View = nil;
}


@end
