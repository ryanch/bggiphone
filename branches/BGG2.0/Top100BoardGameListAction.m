//
//  Top100BoardGameListAction.m
//  BGG2.0
//
//  Created by rchristi on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Top100BoardGameListAction.h"


@implementation Top100BoardGameListAction

/// this should return the key for the list we build
- (NSString*) buildDataListKey {
	return ACTION_URL_TOP_100;
}


/// this method is called in the ns operation queue
- (void) operationMain: (NSOperation*) theOperationObject {
	
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
	
	// save to db
	[managedObjectContext refreshObject:list mergeChanges:YES];
	[managedObjectContext save:nil];
	
	
	NSString * dataURL = nil;
	
	// now start the url fetch
	isDone = NO;
	
	downloadedImage = nil;
	
	urlConnection = [NSMutableData data];
	[urlConnection retain];
	
	
    urlConnection = [[NSURLConnection alloc] initWithRequest:
					   [NSURLRequest requestWithURL:
						[NSURL URLWithString:dataURL]] delegate:self startImmediately:YES];
	
	[urlConnection start];
	
	
	if (urlConnection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!isDone && ![self isCancelled]);
	}		
	
	
	//[self performSelectorOnMainThread:@selector(dataIsReady:) withObject:list.listTitle  waitUntilDone:YES];
	
}



#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {	
	if ( [self isCancelled] ) {
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
	
// TODO parse the page and insert into 
	
	isDone = YES;
	
}

@end
