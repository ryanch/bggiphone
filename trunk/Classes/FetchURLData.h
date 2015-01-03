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
//  FetchURLData.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FETCH_URL_MODE_SEARCH_RESULTS  1

@interface FetchURLData : NSObject {
	NSMutableData * receivedData;
	NSURLConnection *theConnection;
	NSInteger mode;
}

@property NSInteger mode;

- (void) startRequest: (NSURLRequest *) request;

- (void) cancel;

- (void) handleSearchResults;


@end
