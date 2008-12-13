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
//  XmlSearchReader.h
//  iBBG
//
//  Created by RYAN CHRISTIANSON on 9/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#define MAX_SEARCH_RESULTS 100
#define MAX_GAME_NAMES 5

#import <UIKit/UIKit.h>
@class BBGSearchResult;

@interface XmlSearchReader : NSObject {
	NSMutableArray * searchResults;
	int numberGamesFound;
	BBGSearchResult * currentResult;
	NSMutableString *stringBuffer;
	NSMutableArray *gameNames;
	BOOL currentNameIsPrimary;
	BOOL inNameTag;
	BOOL parseItemFormat;
	NSURL *searchURL;
}


@property (nonatomic, retain) NSMutableArray *searchResults;
@property int numberGamesFound;
@property (nonatomic, retain) BBGSearchResult * currentResult;
@property (nonatomic, retain) NSMutableString * stringBuffer;
@property BOOL currentNameIsPrimary;
@property (nonatomic, retain) NSMutableArray *gameNames;
@property BOOL inNameTag;
@property BOOL parseItemFormat;
@property (nonatomic, retain ) NSURL * searchURL;

- (BOOL)parseXMLAtURL:(NSURL *)URL parseError:(NSError **)error;


- (BOOL)parseXMLAtSearchURLWithError:(NSError **)error;


@end
