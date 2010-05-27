//
//  URLGameListAction.m
//  BGG2.0
//
//  Created by rchristi on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "URLGameListAction.h"


@implementation URLGameListAction



/// this method is called in the ns operation queue
- (void) operationMain: (NSOperation*) theOperationObject {
	
	operation = theOperationObject;
	[operation retain];
	

	
	NSString * key = [self buildDataListKey];
	
	if ( key == nil ) {
		[NSException raise:@"error! should have returned a key from buildDataListKey" format: @"missing key" ];
	}
	
	NSString * dataURL = [self buildURLToFetch];
	
	
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
	
	[self saveRows];
	
	if ( [operation isCancelled] ) {
		return;
	}
	
	[self performSelectorOnMainThread:@selector(dataIsReady:) withObject:[self buildListTitle]  waitUntilDone:YES];
	
}


#pragma mark subclass must add these:

- (NSString*) buildURLToFetch {
	return nil;
}

- (void) saveRows {
	
}

- (NSString*) buildListTitle {
	return nil;
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
