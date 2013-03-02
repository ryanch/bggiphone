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
//  FullGameInfo.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FullGameInfo.h"


@implementation FullGameInfo

@synthesize title,imageURL,gameId,desc;

@synthesize usersrated;
@synthesize average;
@synthesize bayesaverage;
@synthesize rank;
@synthesize numweights;
@synthesize averageweight;
@synthesize owned;
@synthesize minPlayers;
@synthesize maxPlayers;
@synthesize playingTime;

@synthesize infoItems;


@synthesize isCached;
@synthesize trading;
@synthesize wanting;
@synthesize wishing;



- (id) init
{
	self = [super init];
	if (self != nil) {
		title = @"";
		imageURL = @"";
		gameId = @"";
		desc = @"";
		usersrated = 0;
		average = @"0.0";
		bayesaverage = @"0.0";
		rank = 0;
		numweights = 0;
		averageweight = @"0.0";
		owned = 0;
		minPlayers =0;
		maxPlayers = 0;
		playingTime = 0;
		isCached = NO;
		 trading = 0;
		 wanting = 0;
		 wishing = 0;		
	}
	return self;
}




@end
