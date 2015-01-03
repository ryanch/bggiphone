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
//  FullGameInfo.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FullGameInfo : NSObject {
	NSString * title;
	NSString * imageURL;
	NSString * gameId;
	NSString * desc;
	NSInteger usersrated;
	NSString * average;
	NSString *  bayesaverage;
	NSInteger rank;
	NSInteger numweights;
	NSString *  averageweight;
	NSInteger owned;
	NSInteger minPlayers;
	NSInteger maxPlayers;
	NSInteger playingTime;
	
	// 1.2 new features
	BOOL isCached;
	NSInteger trading;
	NSInteger wanting;
	NSInteger wishing;
    
    NSArray * infoItems;
}

@property NSArray * infoItems;

@property NSInteger trading;
@property NSInteger wanting;
@property NSInteger wishing;
@property BOOL isCached;

@property NSInteger usersrated;
@property (nonatomic,strong) NSString *  average;
@property (nonatomic,strong) NSString *  bayesaverage;
@property NSInteger rank;
@property NSInteger numweights;
@property (nonatomic,strong)NSString *  averageweight;
@property NSInteger owned;
@property NSInteger minPlayers;
@property NSInteger maxPlayers;
@property NSInteger playingTime;



@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * imageURL;
@property (nonatomic,strong) NSString * gameId;
@property (nonatomic,strong) NSString * desc;

@end
