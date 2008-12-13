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

///
/// This class is used to process the xml of a game search on boardgamegeek.com 
///
@interface XmlSearchReader : NSObject {
	//! this stores the results, as BBGSearchResult obejcts 
	NSMutableArray * searchResults;
	
	//! this is the number of games found 
	int numberGamesFound;
	
	//! this is used when parsing, this is the current result that was found 
	BBGSearchResult * currentResult;
	
	//! this is used when parsing, this holds the current text that is accumulated 
	NSMutableString *stringBuffer;
	
	//! this is used when parsing,this is a list of game names found so far 
	NSMutableArray *gameNames;
	
	//! this is used when parsing, true if the current game name being parsed is the primary name 
	BOOL currentNameIsPrimary;
	
	//! this is used when parsing, tells us that we are in a name tag
	BOOL inNameTag;
	
	//! this tells the parser what type of xml to expect. bgg has 2 types, one has <item> tags
	BOOL parseItemFormat;
	
	//! this is the url that will be searched
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

///
/// start the search at the url that is passed in
/// overwritting the current value of searchURL
/// when this is done, it will return YES if all worked
/// if YES is returned then searchResults contains the results of the search.
///
- (BOOL)parseXMLAtURL:(NSURL *)URL parseError:(NSError **)error;

///
/// call parseXMLAtURL with the current value of the property
/// searchURL
/// 
- (BOOL)parseXMLAtSearchURLWithError:(NSError **)error;


@end
