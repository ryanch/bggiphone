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
	
	//! unexepected content
	BAD_CONTENT =4,
};
typedef NSInteger BGGConnectResponse;




typedef NSInteger BGGConnectWishListState;


@interface BGGConnect : NSObject {
	NSString * username;
	NSString * password;
	NSArray * authCookies;
	NSString * gameCollectionId;
}


@property (nonatomic, retain) NSString *  username;
@property (nonatomic, retain) NSString *  password;
@property (nonatomic, retain) NSArray *  authCookies;



//! Connect and get a auth key from bgg
- (void) connectForAuthKey;


//! Log a play, with simple params
- (BGGConnectResponse) simpleLogPlayForGameId: (NSInteger) gameId forDate: (NSDate *) date numPlays: (NSInteger) plays;

- (BGGConnectResponse) createDbGameEntryForGameId:(NSInteger) gameId;

- (BGGConnectResponse) fetchGameCollectionId:(NSInteger) gameId;

- (BGGConnectResponse) saveCollectionForGameId: (NSInteger) gameId withParams: (NSDictionary*) paramsToSave;

@end
