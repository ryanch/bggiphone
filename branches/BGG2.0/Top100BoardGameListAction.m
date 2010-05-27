//
//  Top100BoardGameListAction.m
//  BGG2.0
//
//  Created by rchristi on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Top100BoardGameListAction.h"
#import "BGGHTMLScraper.h"
#import "BGCore.h"
#import "BBGSearchResult.h"
#import "DataRow.h"
#import "DataList.h"

@implementation Top100BoardGameListAction

/// this should return the key for the list we build
- (NSString*) buildDataListKey {
	return ACTION_URL_TOP_100;
}


/// this method is called in the ns operation queue
- (void) operationMain: (NSOperation*) theOperationObject {
	
	operation = theOperationObject;
	[operation retain];
	
	NSManagedObjectContext * managedObjectContext = [bgCore managedObjectContext];
	
	
	NSString * key = [self buildDataListKey];
	
	if ( key == nil ) {
		[NSException raise:@"error! should have returned a key from buildDataListKey" format: @"missing key" ];
	}
	
	
	DataList * list = [bgCore getDataListForKey:key];
	
	if ( list == nil ) {
		list = [NSEntityDescription
				insertNewObjectForEntityForName:@"DataList"
				inManagedObjectContext:managedObjectContext];
	}
	
	list.key = key;
	list.listTitle = NSLocalizedString( @"Browse Top 100", @"Browse Top 100 screen title" );
	

	
	
	NSString * dataURL = @"http://www.boardgamegeek.com/browse/boardgame";
	
	// now start the url fetch
	isDone = NO;
	
	activeDownload = [NSMutableData data];
	[activeDownload retain];

	urlConnection = [NSMutableData data];
	[urlConnection retain];
	
	
    urlConnection = [[NSURLConnection alloc] initWithRequest:
					   [NSURLRequest requestWithURL:
						[NSURL URLWithString:dataURL]] delegate:self startImmediately:YES];
	
	[urlConnection start];
	
	
	// spin our wheels downloading
	if (urlConnection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!isDone && ![operation isCancelled]);
	}		
	
	// bail out if we got canceled
	if ( [operation isCancelled] ) {
		return;
	}	
	
	
	// create the string
	NSString * markup = [[NSString alloc] initWithData:activeDownload encoding:  NSUTF8StringEncoding];	
	
	//NSLog( @"markup: %@", markup );
	
	[markup autorelease];
	
	// don't need the data any more
	[activeDownload release];
    activeDownload = nil;
	
	// parse the markup data
	BGGHTMLScraper * scaper = [[BGGHTMLScraper alloc] init];
	NSArray * top100list = [scaper scrapeGamesFromTop100: markup];
	[scaper release];
	scaper = nil;
	
	
	
	if ( top100list == nil || [top100list count] == 0 ) {
		NSString * errorMsg = NSLocalizedString( @"Error loading top 100 from web site.", @"error loading" );
		[bgCore dataErrorForAction:[self buildDataListKey] withErrorString:errorMsg];
		return;
	}
	
	
	NSInteger count = [top100list count];
	NSMutableSet * newRows = [[NSMutableSet alloc] initWithCapacity:count];
	
	for ( NSInteger i = 0; i < count; i++ ) {
		BBGSearchResult * result = [top100list objectAtIndex:i];
		
		// add the menu items to the list
		DataRow * row = [NSEntityDescription
						 insertNewObjectForEntityForName:@"DataRow"
						 inManagedObjectContext:managedObjectContext];
		row.detailText = nil;
		row.imageURL = result.imageURL;
		row.topText = result.primaryTitle;
		row.actionURL = ACTION_URL_TOP_100;
		row.sortTitle = result.primaryTitle;
		
		[newRows addObject:row];		
		
	}
	
	// save the rows to the db
	list.rows = newRows;
	
	
	// save to db
	[managedObjectContext refreshObject:list mergeChanges:YES];
	[managedObjectContext save:nil];
	
	if ( [operation isCancelled] ) {
		return;
	}
	
	[self performSelectorOnMainThread:@selector(dataIsReady:) withObject:list.listTitle  waitUntilDone:YES];
	
}



#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {	
	if ( [operation isCancelled] ) {
		[urlConnection cancel];
		return;
	}	
	
    [activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	
	// TODO show the error, tell the core about the issue
	[bgCore dataErrorForAction: [self buildDataListKey] withError: error];
	
    // Clear the activeDownload property to allow later attempts
	[activeDownload release];
    activeDownload = nil;
    
    // Release the connection now that it's finished
	[urlConnection release];
    urlConnection = nil;
	
	isDone = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

	isDone = YES;
	
}


- (void) dealloc
{
	[operation release];
	[activeDownload release];
	[urlConnection release];
	[super dealloc];
}


@end
