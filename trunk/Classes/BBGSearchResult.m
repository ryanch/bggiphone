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
//  BBGSearchResult.m
//  iBBG
//
//  Created by RYAN CHRISTIANSON on 9/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBGSearchResult.h"


@implementation BBGSearchResult

@synthesize primaryTitle;
@synthesize gameId;
@synthesize yearPublished;
@synthesize alternateNames;
@synthesize imageURL = imageURL;



-(id) init {
	if (self = [super init]) {
		yearPublished = 0;
	}
	return self;
}


- (void) dealloc
{
	[primaryTitle release];
	[gameId release];
	[alternateNames release];
	[imageURL release];
	[super dealloc];
}


@end
