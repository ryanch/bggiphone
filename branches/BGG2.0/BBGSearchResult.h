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
//  BBGSearchResult.h
//  iBBG
//
//  Created by RYAN CHRISTIANSON on 9/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

///
/// This class is used to represent the results of a search.
/// This is used in places where the full board game search result
/// would not make sense.
///
@interface BBGSearchResult : NSObject {

	 //! the primary title found in the search
	NSString * primaryTitle;
	
	//! the game id from boardgamegeek.com
	NSString * gameId;
	
	//! the year the game was published -- note this is not used.
	int yearPublished;
	
	//! other names this game goes by -- note this is not used currently
	NSArray * alternateNames;
	
	//! thumbnail image URL
	NSString * imageURL;
}

@property (nonatomic, copy) NSString * primaryTitle;
@property (nonatomic, retain) NSString *  gameId;
@property int yearPublished;
@property (nonatomic, retain) NSArray * alternateNames;
@property (nonatomic, readwrite, retain) NSString *imageURL;
@end
