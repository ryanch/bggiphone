/*
 Copyright 2008 Ryan Christianson
 
 Licensed under the Apache License, Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed under the 
 License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
 either express or implied. See the License for the specific 
 language governing permissions and limitations under the License. 
 */ 

//
//  FetchURLData.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FetchURLData.h"


@implementation FetchURLData


@synthesize mode;

- (void) startRequest: (NSURLRequest *) request {
	[receivedData release];
	[theConnection release];
	receivedData=[[NSMutableData data] retain];	
	
	
	theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) cancel {
	[theConnection cancel];
	[theConnection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[theConnection release];
	[receivedData release];
	NSLog( [error localizedDescription] );
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	if ( mode == FETCH_URL_MODE_SEARCH_RESULTS ) {
		[self handleSearchResults];
	}
	
	
	[connection release];
    [receivedData release];
}


- (void) dealloc
{
	[receivedData release];
	[super dealloc];
}

- (void) handleSearchResults {
		
	
}



@end
