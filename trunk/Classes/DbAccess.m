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
//  DbAccess.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DbAccess.h"

#import "FullGameInfo.h"
#import "BBGSearchResult.h"



#import "FMDatabase.h"
#import "FMResultSet.h"
#import  "BGGAppDelegate.h"


@implementation DbAccess





//- (NSArray*) searchOwnedGames

- (NSArray*) searchGamesOwnedPlayers: (NSInteger) player withWeight: (NSInteger) weight withTime: (NSInteger) time {
	
	BGGAppDelegate * appDelegate = (BGGAppDelegate*) [[UIApplication sharedApplication] delegate];
	NSString * username = [appDelegate getCurrentUserName];
	
	NSString * playersQuery;
	if (player < 0 ) {
		playersQuery = @" 1=1 ";
	}
	else if ( player >= 10 ) {
		playersQuery = @" GameInfo.maxPlayers >= 10";
	}
	else {
		playersQuery = [NSString stringWithFormat:	@" GameInfo.maxPlayers >= %d AND %d >= GameInfo.minPlayers ", player, player ];
	}
	
	NSString * weightQuery;
	if (weight < 0 ) {
		weightQuery = @" 1=1 ";
	}
	else if ( weight == 5 ) {
			weightQuery = @" GameInfo.averageweight >= 4.75 ";
	}
	else {
		
		// avg weight is 3.3
		// pick 3
		// avg weight 4 
		
		
		weightQuery = [NSString stringWithFormat:	@" GameInfo.averageweight BETWEEN %d and %f  ", weight, (weight+0.75) ];
	}
	
	NSString * timeQuery;
	if (time < 0  ) {
		timeQuery = @" 1=1 ";
	}
	else {
		timeQuery = [NSString stringWithFormat:	@" GameInfo.playingTime <= %d ", time ];
	}
	
	
	//NSString * countQuery = @"select count(*) as c from GameInfo where own=1";
	
	//NSString * count 
	//[self 
	
	NSString * query = [NSString  stringWithFormat: @"select * from GameInfo,GameOwnList where GameOwnList.gameId=GameInfo.gameId and GameOwnList.username=?  and %@ and %@ and %@ ORDER BY GameInfo.title", playersQuery, weightQuery, timeQuery];
	
#ifdef __DEBUGGING__
	NSLog( @"search query: %@", query );
#endif
	

	
	int totalCount = [self countGamesInList:LIST_TYPE_OWN forUser: username ];
	
	
	if ( totalCount == 0 ) {
		return nil;
	}
	
	NSMutableArray * items = [[NSMutableArray alloc] initWithCapacity:totalCount];
	
	FMResultSet* rs = [database executeQuery:query, username];
	
	if ([database hadError]) {
		NSLog(@"error doing game search %d: %@", [database lastErrorCode], [database lastErrorMessage]);
	}	
	
	
    while ([rs next]) {
		
		BBGSearchResult * result = [[BBGSearchResult alloc] init];
		
		FullGameInfo * fullGameInfo = [self buildFullGameInfoFromResultRow:	rs];
		
		result.primaryTitle = fullGameInfo.title;
		result.gameId = fullGameInfo.gameId;
		
		
#ifdef __DEBUGGING__
		NSLog( @"search query result title: %@", result.primaryTitle );
#endif
		
		
		[items addObject:result];
		[result release];
		
    }
    [rs close]; 
	
	[items autorelease];
	return items;
	
	
	
}

- (void) cleanupForShutdown {
	
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	// delete old db
	NSString *oldNutsLocalDb = [documentsDirectory stringByAppendingPathComponent:@"bgg.db"];
	
	if ( [fileManager fileExistsAtPath:oldNutsLocalDb ] ) {
		[fileManager removeItemAtPath:oldNutsLocalDb	error:nil];
	}
	
	// delete old dbs
	oldNutsLocalDb = [documentsDirectory stringByAppendingPathComponent:@"bgg11.db"];
	
	if ( [fileManager fileExistsAtPath:oldNutsLocalDb ] ) {
		[fileManager removeItemAtPath:oldNutsLocalDb	error:nil];
	}	
	
	// delete old dbs
	oldNutsLocalDb = [documentsDirectory stringByAppendingPathComponent:@"bgg12.db"];
	
	if ( [fileManager fileExistsAtPath:oldNutsLocalDb ] ) {
		[fileManager removeItemAtPath:oldNutsLocalDb	error:nil];
	}	
	
}


- (void) setupDatabase {
	
	
	
	
	// build a file name for the index
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *noNutsLocalDb = [documentsDirectory stringByAppendingPathComponent:@"bgg13.db"];
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	

	
	
	
	if ( ![fileManager fileExistsAtPath:noNutsLocalDb ] ) {
		
		// local copy does not exist, so copy from bundle
		NSString *pathToDbInBundle = [[NSBundle mainBundle] pathForResource:@"bgg13" ofType:@"db"];
		
		if ( ![fileManager copyItemAtPath:pathToDbInBundle   toPath:noNutsLocalDb error: nil] ) {
			[self showError: NSLocalizedString( @"Error preparing database, make sure your device has some free space.", @"erorr shown when trying to load database." ) withTitle:@"DB Error"];
			return;
		}
		
	}
	
	
	
	
	FMDatabase* db = [FMDatabase databaseWithPath:noNutsLocalDb];
	
#ifdef __DEBUGGING__
	//[db setTraceExecution:YES];
#endif
	
	
	database = db;
	[db retain];
	if (![db open]) {
        [self showError:@"Error opening database." withTitle:@"DB Error"];
        return;
    }
	
	
}


- (NSInteger) fetchTotalMissingGameInfoFromCollection {
	
	BGGAppDelegate * appDelegate = (BGGAppDelegate*) [[UIApplication sharedApplication] delegate];
	NSString * username = [appDelegate getCurrentUserName];
	
	NSString * countQuery = @"select count(*) as c from GameInfo,GameOwnList  where GameOwnList.gameId=GameInfo.gameId  and GameOwnList.username=? and GameInfo.isCached=0";
	
	int totalCount = 0;
	FMResultSet *rs = [database executeQuery:countQuery, username];
	
	if ([database hadError]) {
		NSLog(@"error looking for games in collection %d: %@", [database lastErrorCode], [database lastErrorMessage]);
	}	
	
    if ([rs next]) {
		totalCount = [rs intForColumn:@"c"];
    }
    [rs close]; 
	
	if ([database hadError]) {
		NSLog(@"error looking for games in collection %d: %@", [database lastErrorCode], [database lastErrorMessage]);
	}	
	
	return totalCount;
	
}

- (FullGameInfo *) initNextMissingGameForCollection {

	BGGAppDelegate * appDelegate = (BGGAppDelegate*) [[UIApplication sharedApplication] delegate];
	NSString * username = [appDelegate getCurrentUserName];	
	
	NSString * getNextGameQuery = @"select GameInfo.gameId from GameInfo,GameOwnList where GameInfo.isCached=0 and GameOwnList.gameId=GameInfo.gameId and GameOwnList.username=? LIMIT 1";
	
	NSString * gameId = nil;
	

	FMResultSet *rs = [database executeQuery:getNextGameQuery, username];
	
	if ([database hadError]) {
		NSLog(@"error for a game to download %d: %@", [database lastErrorCode], [database lastErrorMessage]);
	}	
	
    if ([rs next]) {
		gameId = [rs stringForColumn:@"gameId"];
    }
    [rs close]; 	
	
	if ( gameId == nil ) {
		return nil;
	}
	

	FullGameInfo * gameInfo = [appDelegate initFullGameInfoByGameIdFromBGG:gameId];
	return gameInfo;
	
	
}


- (BOOL) checkIfCollectionIsLoaded {
	
	
	if ( ![self hasOwnedGamesCached] ) {
		return false;
	}
	
	 
	NSInteger totalCount = [self fetchTotalMissingGameInfoFromCollection];
	
	if ( totalCount == 0 ) {
		return YES;
	}
	else {
		return NO;
	}
		
}


- (id) init
{
	self = [super init];
	if (self != nil) {
		[self setupDatabase];
	}
	return self;
}

- (void) dealloc {
	
	[database dealloc];
	
	[super dealloc];
}


- (void) showError: (NSString*) errorMessage withTitle:(NSString*) title {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:errorMessage
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];	
}


- (FullGameInfo* ) buildFullGameInfoFromResultRow:(FMResultSet*) rs {
	FullGameInfo * fullGameInfo = [[FullGameInfo alloc] init];
	[fullGameInfo autorelease];
	
	
	fullGameInfo.title = [rs stringForColumn:@"title"];
	fullGameInfo.imageURL = [rs stringForColumn:@"imageURL"];
	fullGameInfo.gameId = [rs stringForColumn:@"gameId"];
	fullGameInfo.desc = [rs stringForColumn:@"desc"];
	fullGameInfo.usersrated = [rs intForColumn:@"usersrated"];
	fullGameInfo.average = [rs stringForColumn:@"average"];
	fullGameInfo.bayesaverage = [rs stringForColumn:@"bayesaverage"];
	fullGameInfo.rank = [rs intForColumn:@"rank"];
	fullGameInfo.numweights = [rs intForColumn:@"numweights"];
	fullGameInfo.averageweight = [rs stringForColumn:@"averageweight"];
	fullGameInfo.owned = [rs intForColumn:@"owned"];
	fullGameInfo.minPlayers = [rs intForColumn:@"minPlayers"];
	fullGameInfo.maxPlayers = [rs intForColumn:@"maxPlayers"];
	fullGameInfo.playingTime = [rs intForColumn:@"playingTime"];
	
	// 1.2 features
	fullGameInfo.wanting = [rs intForColumn:@"wanting"];
	fullGameInfo.wishing = [rs intForColumn:@"wishing"];
	fullGameInfo.trading = [rs intForColumn:@"trading"];
	fullGameInfo.isCached = ([rs intForColumn:@"isCached"] == 1);
	
	/*
	NSString * own = [rs stringForColumn:@"own"];
	if ( own != nil && [own isEqualToString:@"1"] ) {
		fullGameInfo.ownedByUser = YES;	
	}
	else {
		fullGameInfo.ownedByUser = NO;	
	}
	 */
	
	
	return fullGameInfo;
}


/*
 #define LIST_TYPE_OWN 1
 #define LIST_TYPE_WISH 2
 #define LIST_TYPE_RECENT 3
 #define LIST_TYPE_TOPLAY 4
 */

// check if a game is in a list
- (BOOL) checkIfGameInList:(NSInteger) gameId list: (NSInteger) listType forUser: (NSString *) username {
	
	NSString* tableName = nil;
	
	
	if ( LIST_TYPE_OWN == listType ) {
		tableName = @"GameOwnList";
	}
	else if ( LIST_TYPE_WISH == listType ) {
		tableName = @"GameWantList";
	}	
	else if ( LIST_TYPE_TOPLAY == listType ) {
		tableName = @"GameToPlayList";
	}	
	else if ( LIST_TYPE_RECENT == listType ) {
		tableName = @"RecentGameList";
	}	
	
	NSString * query = [NSString stringWithFormat:@"select * from %@ where gameId=%d and username=?", tableName, gameId];
	
	FMResultSet * rs = [database executeQuery:query,username];
	
	BOOL result = NO;
	if ([rs next]) {
		result = YES;
	}
	[rs close];
	
	return result;
	

}


- (NSInteger) countGamesInList: (NSInteger) listType forUser: (NSString*) username {
	
	NSString * tableName;
	
	if ( LIST_TYPE_OWN == listType ) {
		tableName = @"GameOwnList";
	}
	else if ( LIST_TYPE_WISH == listType ) {
		tableName = @"GameWantList";
	}	
	else if ( LIST_TYPE_TOPLAY == listType ) {
		tableName = @"GameToPlayList";
	}	
	else if ( LIST_TYPE_RECENT == listType ) {
		tableName = @"RecentGameList";
		
		
	}	
	
	NSString * countQuery = [NSString stringWithFormat:@"select count(*) as c from %@ where username=?", tableName];
	
	NSInteger count = 0;
	FMResultSet * rs = [database executeQuery:countQuery, username];
	if ( [rs next] ) {
		count = [rs intForColumn:@"c"];
	}
	[rs close];
	
	return count;
	
}

// get all of the games in a list
- (NSArray*) getAllGamesInListByType: (NSInteger) listType forUser: (NSString *) username  {
	NSString* tableName = nil;
	
	if ( LIST_TYPE_OWN == listType ) {
		tableName = @"GameOwnList";
	}
	else if ( LIST_TYPE_WISH == listType ) {
		tableName = @"GameWantList";
	}	
	else if ( LIST_TYPE_TOPLAY == listType ) {
		tableName = @"GameToPlayList";
	}	
	else if ( LIST_TYPE_RECENT == listType ) {
		tableName = @"RecentGameList";
		
		// for this list, we need to delete all old entries first
	
		NSDate* date = [[NSDate date] addTimeInterval: -(3*60*60*24) ];
		NSTimeInterval oldDate = [date timeIntervalSince1970];
		
		NSString * 	deleteQuery = [NSString stringWithFormat:@"delete from RecentGameList where  username=? and dateViewed < ?"];
		[database executeUpdate: deleteQuery,username, [NSNumber numberWithDouble:oldDate] ];
		
	}
	
	
	NSString * countQuery = [NSString stringWithFormat:@"select count(*) as c from %@ where username=?", tableName];
	
	// first get the count
	NSInteger count = 0;
	FMResultSet * rs = [database executeQuery:countQuery,username];
	if ( [rs next] ) {
		count = [rs intForColumn:@"c"];
	}
	[rs close];
	
	if ( count == 0 ) {
		return nil;
	}
	
	NSString * selectAllQuery = [NSString stringWithFormat:@"select gameId from %@ where username=?", tableName];
	rs = [database executeQuery:selectAllQuery,username];
	
	NSMutableArray * results = [[NSMutableArray alloc] initWithCapacity:count];
	
	
	
	NSMutableArray * gameIds = [[NSMutableArray alloc] initWithCapacity:count];
	
	while ( [rs next] ) {
		NSInteger gameId = [rs intForColumn:@"gameId"];
		[gameIds addObject: [NSNumber numberWithInt:gameId ] ];
	}
	[rs close];
	
	for (int i = 0; i < count; i++ ){
		NSNumber * gameIdNum = [gameIds objectAtIndex:i];
		NSInteger gameId = [gameIdNum intValue];
		FullGameInfo * gameInfo = [self fetchFullGameInfoByGameId:gameId];
		if ( gameInfo != nil ) {
			[results addObject:gameInfo];
		}
	}
	
	[gameIds release];
	

	[results autorelease]; 
	return results;
	
	
}


- (void) removeAllGamesInList: (NSInteger) listType forUser: (NSString*) username {
	
	NSString* tableName = nil;
	
	if ( LIST_TYPE_OWN == listType ) {
		tableName = @"GameOwnList";
	}
	else if ( LIST_TYPE_WISH == listType ) {
		tableName = @"GameWantList";
	}	
	else if ( LIST_TYPE_TOPLAY == listType ) {
		tableName = @"GameToPlayList";
	}	
	else if ( LIST_TYPE_RECENT == listType ) {
		tableName = @"RecentGameList";
	}	
	
	// delete from the db first
	NSString * 	deleteQuery = [NSString stringWithFormat:@"delete from %@ where username=?", tableName];
	[database executeUpdate: deleteQuery,username];
	
}

// save a game in a list, or remove from a list
- (void) saveGameInList: (NSInteger) gameId list: (NSInteger) listType inList: (BOOL) isInList forUser: (NSString *) username{
	
	NSString* tableName = nil;
	
	if ( LIST_TYPE_OWN == listType ) {
		tableName = @"GameOwnList";
	}
	else if ( LIST_TYPE_WISH == listType ) {
		tableName = @"GameWantList";
	}	
	else if ( LIST_TYPE_TOPLAY == listType ) {
		tableName = @"GameToPlayList";
	}	
	else if ( LIST_TYPE_RECENT == listType ) {
		tableName = @"RecentGameList";
	}	
	
	// delete from the db first
	NSString * 	deleteQuery = [NSString stringWithFormat:@"delete from %@ where gameId=%d and username=?", tableName, gameId];
	[database executeUpdate: deleteQuery,username];
	
	// if is in the db, then insert 
	if ( isInList ) {
		
		NSString * query = nil;
		
		if ( LIST_TYPE_RECENT == listType ) {
			query = [NSString stringWithFormat:@"insert into %@ (gameId,username,dateViewed) values (?,?,?)",tableName];
			[database executeUpdate: query,[NSNumber numberWithInt:gameId],username,[NSDate date]];
		}
		else {
			query = [NSString stringWithFormat:@"insert into %@ (gameId,username) values (?,?)",tableName];
			[database executeUpdate: query,[NSNumber numberWithInt:gameId],username];
		}
	}
	
	
}

- (void) saveGameForListGameId: (NSInteger) gameId title: (NSString*) title list: (NSInteger) listType {
	
	// see if this game exists in the db already
	
	int totalCount = 0;
	FMResultSet *rs = [database executeQuery:@"select count(*) as c from GameInfo where gameId=?", [NSNumber numberWithInt:gameId] ];
    if ([rs next]) {
		totalCount = [rs intForColumn:@"c"];
    }
    [rs close]; 
	
	
	
	if ( totalCount == 0 ) {
		
		
		FullGameInfo *fullGame = [[FullGameInfo alloc] init];
		fullGame.gameId = [NSString stringWithFormat:@"%d", gameId];
		fullGame.title = title;
		
		[self saveFullGameInfo:fullGame];
		
		
		[fullGame release];
		
	}
	
	
	
	BGGAppDelegate * appDelegate = (BGGAppDelegate*) [[UIApplication sharedApplication] delegate];
	
	[self saveGameInList:gameId	list:listType	inList:YES forUser: [appDelegate getCurrentUserName]  ];
	
	
	if ([database hadError]) {
		NSLog(@"error updating list Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
	}		
	
	
}

- (void) saveGameAsOwnedGameId: (NSInteger) gameId title: (NSString*) title {
	
	[self saveGameForListGameId: gameId title: title list: LIST_TYPE_OWN];

	
}


- (FullGameInfo*) fetchFullGameInfoByGameId: (NSInteger) gameId {
	FullGameInfo * fullGameInfo = nil;
	FMResultSet * rs = [database executeQuery:@"select * from GameInfo where gameId=?",  [NSNumber numberWithInt:gameId] ];
	
	if ([database hadError]) {
        NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
		return nil;
    }
	
	if ( [rs next] ) {
		
		fullGameInfo = [self buildFullGameInfoFromResultRow:rs];
		
		
	}
	else {
#ifdef __DEBUGGING__  
		NSLog(@"did not find game with id %d", gameId	);
#endif
	}
	
	[rs close];
	
	
	return fullGameInfo;
	
	
}




- (void) saveFullGameInfo: (FullGameInfo * ) fullgameInfo {

	/*
	NSInteger ownerFlag = (fullgameInfo.ownedByUser) ? 1 : 0;
	
	if ( ownerFlag == 0 ) {
		if ( [self checkIfUserOwnsGame: [fullgameInfo.gameId intValue]] ) {
			ownerFlag = 1;
		}
	}
	 */
	
	
	
	
	// delete old if there is one
	NSString * query = [NSString stringWithFormat: @"delete from GameInfo WHERE gameId=%@", fullgameInfo.gameId ];
	[database executeUpdate:query];
	
	if ([database hadError]) {
        NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }
	
	// insert into db
	query = @"insert into GameInfo ( gameId,title,imageURL ,desc ,usersrated ,average ,bayesaverage ,rank ,numweights ,averageweight ,owned ,minPlayers ,maxPlayers ,playingTime, isCached,trading,wanting,wishing  ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	
#ifdef __DEBUGGING__
	NSLog( @"inserting full game info id: %d", [fullgameInfo.gameId intValue]	);
#endif
	
	[database executeUpdate:query ,	
	 
	 fullgameInfo.gameId ,
	 fullgameInfo.title,
	 fullgameInfo.imageURL,
	 fullgameInfo.desc,
	 [NSNumber numberWithInt:fullgameInfo.usersrated],
	 [NSNumber numberWithDouble: [fullgameInfo.average doubleValue]], 
	 [NSNumber numberWithDouble: [fullgameInfo.bayesaverage doubleValue]], 
	 [NSNumber numberWithInt: fullgameInfo.rank], 
	 [NSNumber numberWithInt: fullgameInfo.numweights], 
	 [NSNumber numberWithDouble: [fullgameInfo.averageweight doubleValue]], 
	 [NSNumber numberWithInt:fullgameInfo.owned], 
	 [NSNumber numberWithInt: fullgameInfo.minPlayers], 
	 [NSNumber numberWithInt: fullgameInfo.maxPlayers],
	 [NSNumber numberWithInt: fullgameInfo.playingTime], 
	 [NSNumber numberWithInt: fullgameInfo.isCached ? 1: 0 ],	
	 [NSNumber numberWithInt:fullgameInfo.trading],	
	 [NSNumber numberWithInt:fullgameInfo.wanting],	
	 [NSNumber numberWithInt:fullgameInfo.wishing]	
	 
	 ];
	
	
	if ([database hadError]) {
        NSLog(@"Err inserting game into db %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }
	
}

- (void) clearDB {
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[appDelegate.authCookies release];
	appDelegate.authCookies = nil;
	
	[database executeUpdate:@"delete from RecentGameList"];
	
	if ([database hadError]) {
        NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }		
	
	
	[database executeUpdate:@"delete from GameToPlayList"];
	
	if ([database hadError]) {
        NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }		
	
	
	[database executeUpdate:@"delete from GameWantList"];
	
	if ([database hadError]) {
        NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }	
	
	
	[database executeUpdate:@"delete from GameOwnList"];
	
	if ([database hadError]) {
        NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }
	
	[database executeUpdate:@"delete from GameInfo"];
	
	if ([database hadError]) {
        NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }	
	
}


- (BOOL) hasOwnedGamesCached {
	/*
	NSString * countQuery = @"select count(*) as c from GameInfo where own=1";
	
	int totalCount = 0;
	FMResultSet *rs = [database executeQuery:countQuery];
    if ([rs next]) {
		totalCount = [rs intForColumn:@"c"];
    }
    [rs close]; 
	
	return totalCount != 0;
	 */
	
	BGGAppDelegate * appDelegate = (BGGAppDelegate*) [[UIApplication sharedApplication] delegate];
	NSString * username = [appDelegate getCurrentUserName];
	
	NSInteger count = [self countGamesInList:LIST_TYPE_OWN	forUser:username];
	return count > 0;
	
	
}


- (NSArray*) getAllGamesInListByTypeAsSearchResults: (NSInteger) listType forUser: (NSString *) username  {
	
	NSArray * fullResults = [self getAllGamesInListByType:listType	forUser:username];
	
	if ( fullResults == nil ) {
		return nil;
	}
	
	
	NSInteger count = [fullResults count];
	
	if ( count == 0 ) {
		return nil;
	}
	
	NSMutableArray * searchResults = [[NSMutableArray alloc] initWithCapacity:count];
	
	for ( int i = 0; i < count; i++ ) {
		FullGameInfo * fullInfo = (FullGameInfo*) [fullResults objectAtIndex:i];
		BBGSearchResult * searchResult = [[BBGSearchResult alloc] init];
		
		searchResult.primaryTitle = fullInfo.title;
		searchResult.gameId = fullInfo.gameId;
		
		[searchResults addObject:searchResult];
		[searchResult release];
	}
	
	[searchResults autorelease];
	
	return searchResults;
}

- (NSArray*) localDbSearchByName: (NSString*) gameName {
	
	if (gameName == nil) {
		return nil;
	}
	
	if ( [gameName length] == 0 ) {
		return nil;
	}
	
	NSMutableArray * results = [[NSMutableArray alloc] initWithCapacity:50];
	
	NSString * searchString = [NSString stringWithFormat:@"%%%@%%", gameName];
	
	FMResultSet * rs = [database executeQuery:@"select GameInfo.title, GameInfo.gameId from GameInfo where GameInfo.title LIKE ?",  searchString ];
	
	if ([database hadError]) {
        NSLog(@"Err doing local db search by name %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }	
	
    while ([rs next]) {
		BBGSearchResult * result = [[BBGSearchResult alloc] init];
		result.primaryTitle = [rs stringForColumn:@"title"];
		result.gameId = [rs stringForColumn:@"gameId"];
		
#ifdef __DEBUGGING__
		NSLog(@"local search matched: %@ ", result.primaryTitle	);
#endif
		
		[results addObject:result];
		[result release];
    }
    [rs close]; 
	
	if ( [results count] == 0 ) {
		[results release];
		return nil;
	}
	else {
		[results autorelease];
		return results;
	}
	
}





@end
