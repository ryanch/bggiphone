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

///
/// this class wraps access to the SQLLite database
///
@interface DbAccess : NSObject {
	FMDatabase * database;

}

///
/// this method returns the number of games that are in the users collection, but are not cached. 
/// so OWNED, but isCache=0 
///
- (NSInteger) fetchTotalMissingGameInfoFromCollection;

///
/// search the current players collection for 
/// games that match the critera selected
/// 
- (NSArray*) searchGamesOwnedPlayers: (NSInteger) player withWeight: (NSInteger) weight withTime: (NSInteger) time;

///
/// return YES if the user has any games in their collection
/// and fetchTotalMissingGameInfoFromCollection == 0
- (BOOL) checkIfCollectionIsLoaded;

///
/// return YES is there is any data about the current users collection
///
- (BOOL) hasOwnedGamesCached;

///
/// clean up database before the app shutsdown
///
- (void) cleanupForShutdown;

///
/// count number of games in a list for a user
///
- (NSInteger) countGamesInList: (NSInteger) listType forUser: (NSString*) username;

///
/// remove all games in the list of type for user
///
- (void) removeAllGamesInList: (NSInteger) listType forUser: (NSString*) username;

///
/// check if a game is in a list
///
- (BOOL) checkIfGameInList:(NSInteger) gameId list: (NSInteger) listType forUser: (NSString *) username;

///
/// get all of the games in a list
///
- (NSArray*) getAllGamesInListByType: (NSInteger) listType forUser: (NSString *) username;

///
/// save a game in a list, or remove from a list
///
- (void) saveGameInList: (NSInteger) gameId list: (NSInteger) listType inList: (BOOL) isInList forUser: (NSString *) username;

///
/// find a game in the users collection that is missing data. fetch all of the data for that
/// game and return it, and save to db.
///
- (FullGameInfo *) initNextMissingGameForCollection;


///
/// given a result row from the GameInfo table, build a 
/// FullGameInfo object
///
- (FullGameInfo* ) buildFullGameInfoFromResultRow:(FMResultSet*) rs;

///
/// should be called at startup. open the db
///
-(void) setupDatabase;

///
/// show an error to the user in a pretty dialog
///
-(void) showError: (NSString*) errorMessage withTitle:(NSString*) title;

///
/// given a game id, fetch the game from the db
///
-(FullGameInfo*) fetchFullGameInfoByGameId: (NSInteger) gameId;


///
/// save a game to the db. if the game already exists delete it
/// and replace with this game
///
-(void) saveFullGameInfo: (FullGameInfo * ) fullgameInfo;

///
/// remove all data from the db
///
-(void) clearDB;

///
/// get a list of all of the games in a list, as SearchResult objects.
///
- (NSArray*) getAllGamesInListByTypeAsSearchResults: (NSInteger) listType forUser: (NSString *) username;

///
/// save a game as owned by the current user in the owned list
///
- (void) saveGameAsOwnedGameId: (NSInteger) gameId title: (NSString*) title;

///
/// save a game in the list requested for the current user
///
- (void) saveGameForListGameId: (NSInteger) gameId title: (NSString*) title list: (NSInteger) listType;

///
/// do search in the local db for the game, return the a list of BBGSearchResult objects
///
- (NSArray*) localDbSearchByName: (NSString*) gameName;


@end
