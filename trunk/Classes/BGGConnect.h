//
//  BGGConnect.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 1/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 
 [bggConnect logPlayForGameId: gameId plays:1 
 
 
 */



///
/// these are error responses
///
enum {
	//! authorization error
	AUTH_ERROR = 1,
	//! connection error
	CONNECTION_ERROR = 2,
	//! success
	SUCCESS = 3,	
};
typedef NSInteger BGGConnectResponse;


///
/// these are collection flags
///
enum {
	COLLECTION_FLAG_OWN,
	COLLECTION_FLAG_PREV_OWN,
	COLLECTION_FLAG_FOR_TRADE,
	COLLECTION_FLAG_WANT_IN_TRADE,
	COLLECTION_FLAG_WANT_TO_BUY,
	COLLECTION_FLAG_WANT_TO_PLAY,
	COLLECTION_FLAG_NOTIFY_CONTENT,
	COLLECTION_FLAG_NOTIFY_SALES,
	COLLECTION_FLAG_NOTIFY_AUCTIONS,
	COLLECTION_FLAG_PREORDED
};
typedef NSInteger BGGConnectCollectionFlag;

///
/// these are wishlist states
///
enum {
	MUST_HAVE,
	LOVE_TO_HAVE,
	LIKE_TO_HAVE,
	THINKING_ABOUT_IT,
	DONT_BUY_THIS,
	REMOVE_FROM_WISHLIST
};
typedef NSInteger BGGConnectWishListState;


@interface BGGConnect : NSObject {
	NSString * username;
	NSString * password;
	NSArray * authCookies;
}


@property (nonatomic, retain) NSString *  username;
@property (nonatomic, retain) NSString *  password;
@property (nonatomic, retain) NSArray *  authCookies;



//! Connect and get a auth key from bgg
- (void) connectForAuthKey;


//! Log a play, with simple params
- (BGGConnectResponse) simpleLogPlayForGameId: (NSInteger) gameId forDate: (NSDate *) date numPlays: (NSInteger) plays;


//! update game state in collection
- (BGGConnectResponse) saveCollectionForGameId: (NSInteger) gameId flag: (BGGConnectCollectionFlag) flag setFlag: (BOOL) shouldSet;

//! update game state in wishlist
- (BGGConnectResponse) saveWishListStateForGameId: (NSInteger) gameId flag: (BGGConnectWishListState) stateToSave;




@end
