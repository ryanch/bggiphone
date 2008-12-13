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
//  DbAccess.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMDatabase;
@class FullGameInfo;
@class FMResultSet;

#define LIST_TYPE_OWN 1
#define LIST_TYPE_WISH 2
#define LIST_TYPE_RECENT 3
#define LIST_TYPE_TOPLAY 4


@interface DbAccess : NSObject {
	FMDatabase * database;

}


- (NSInteger) fetchTotalMissingGameInfoFromCollection;

- (NSArray*) searchGamesOwnedPlayers: (NSInteger) player withWeight: (NSInteger) weight withTime: (NSInteger) time;

- (BOOL) checkIfCollectionIsLoaded;

- (BOOL) hasOwnedGamesCached;


- (void) cleanupForShutdown;

// count number of games in a list for a user
- (NSInteger) countGamesInList: (NSInteger) listType forUser: (NSString*) username;

// check if a game is in a list
- (BOOL) checkIfGameInList:(NSInteger) gameId list: (NSInteger) listType forUser: (NSString *) username;

// get all of the games in a list
- (NSArray*) getAllGamesInListByType: (NSInteger) listType forUser: (NSString *) username;

// save a game in a list, or remove from a list
- (void) saveGameInList: (NSInteger) gameId list: (NSInteger) listType inList: (BOOL) isInList forUser: (NSString *) username;

- (FullGameInfo *) initNextMissingGameForCollection;

- (FullGameInfo* ) buildFullGameInfoFromResultRow:(FMResultSet*) rs;

-(void) setupDatabase;

-(void) showError: (NSString*) errorMessage withTitle:(NSString*) title;

-(FullGameInfo*) fetchFullGameInfoByGameId: (NSInteger) gameId;

-(void) saveFullGameInfo: (FullGameInfo * ) fullgameInfo;

-(void) clearDB;

// get a list of all of the games in a list, as SearchResult objects.
- (NSArray*) getAllGamesInListByTypeAsSearchResults: (NSInteger) listType forUser: (NSString *) username;


// save a game as owned by the current user in the owned list
- (void) saveGameAsOwnedGameId: (NSInteger) gameId title: (NSString*) title;

// save a game in the list requested for the current user
- (void) saveGameForListGameId: (NSInteger) gameId title: (NSString*) title list: (NSInteger) listType;


@end
