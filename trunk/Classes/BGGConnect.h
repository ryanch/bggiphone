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
	SUCCESS = 2,	
};
typedef NSInteger BGGConnectResponse;


///
/// these are collection flags
///
enum {
	OWN,
	PREV_OWN,
	FOR_TRADE,
	WANT_IN_TRADE,
	WANT_TO_BUY,
	WANT_TO_PLAY,
	NOTIFY_CONTENT,
	NOTIFY_SALES,
	NOTIFY_AUCTIONS,
	PREORDED
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
- (BGGConnectResponse) saveCollectionForGameId: (NSInteger) gameId flag: (BGGConnectCollectionFlag) flag setFlag: (BOOL) shouldSet forTarget:(id)target;

//! update game state in wishlist
- (BGGConnectResponse) saveWishListStateForGameId: (NSInteger) gameId flag: (BGGConnectWishListState) stateToSave forTarget:(id)target;




@end
