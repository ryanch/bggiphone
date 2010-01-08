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
//  BGGAppDelegate.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/16/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>


#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))

#define SEARCH_MENU_CHOICE 0
#define BROWSE_TOP_100_MENU_CHOICE 1
#define OWNED_MENU_CHOICE 2
#define PICK_GAME_CHOICE 3
#define WISH_MENU_CHOICE 4
#define WANT_TO_PLAY_CHOICE 5
#define GAMES_PLAYED_MENU_CHOICE 6
#define SETTINGS_MENU_CHOICE 7
// this is also the total count since it is last
#define ABOUT_MENU_CHOICE 8

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

///
/// these are types of searches todo
///
enum {
	//! search games owned by current user
	BGG_SEARCH_OWNED = 1,
	//! search current user wish list
	BGG_SEARCH_WISH = 2,
	//! games to play list
	BGG_GAMES_TO_PLAY_LIST = 3,
	//! games played
	BGG_GAMES_PLAYED_LIST = 4,
	//! all games
	BGG_ALL_GAMES = 5
};
typedef NSInteger BGGSearchGameType;


///
/// these are states that the app can be saved in
///
enum {
		//! resume a board game view
		BGG_RESUME_GAME = 1,
	
		//! resume on the owned list
		BGG_RESUME_OWNED = 2,
	
		//! resume on the wish list
		BGG_RESUME_WISH = 4,
	
		//! resume on the about page
		BGG_RESUME_ABOUT = 5,
	
		//! resume on the search page
		BGG_RESUME_SEARCH = 6,
	
		//! resume on settings page
		BGG_RESUME_SETTINGS = 7,
	
		//! resume on the game picker page
		BGG_RESUME_PICK_GAME = 8,
	
		//! resume on the to play list
		BGG_RESUME_GAMES_TO_PLAY_LIST = 9,
	
		//! resume on the played list
		BGG_RESUME_GAMES_PLAYED_LIST = 10,
	
		//! resume on the browse top 100 games page
		BGG_RESUME_BROWSE_TOP_100_GAMES = 11,
};
typedef NSInteger BGGResumeState;

@class BBGSearchResult;
@class PlistSettings;
@class DownloadGameInfoOperation;
@class DbAccess;
@class FullGameInfo;
@class XmlSearchReader;

///
/// this is the app delegate for the app
///
@interface BGGAppDelegate : NSObject <UIApplicationDelegate> {
    
	//! current window
    UIWindow *window;
	
	//! our nav controller
    UINavigationController *navigationController;
	
	//! this manages our users settings, rembers the users state
	PlistSettings * appSettings;
	
	//! this is used to download game information
	DownloadGameInfoOperation * downloadOperation;
	
	//! this is our access layer to the SQLlite db
	DbAccess *dbAccess;
	
	// cached auth cookies
	NSArray * authCookies;
}

@property (nonatomic, retain) NSArray *authCookies;
@property (nonatomic, retain) DbAccess *dbAccess;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) PlistSettings * appSettings;
@property (nonatomic, retain) DownloadGameInfoOperation * downloadOperation;

//! url encode a value
+ (NSString*) urlEncode: (NSString*) str;

//! build a local path to an game image file
- (NSString*) buildImageFilePathForGameId: (NSString*) gameId;

//! build a local path to a game image file thumbnail
- (NSString*) buildImageThumbFilePathForGameId: (NSString*) gameId;

//! build a local path to an game image file, check if it exists
- (NSString*) buildImageFilePathForGameId: (NSString*) gameId checkIfExists: (BOOL) exists;

//! build a local path to a game image file thumbnail, check if it exists
- (NSString*) buildImageThumbFilePathForGameId: (NSString*) gameId checkIfExists: (BOOL) exists;


//! cache a games image, creating a thumbail as well
-(void) cacheGameImage: (FullGameInfo*) fullGameInfo;
-(void) cacheGameImageAtURL:(NSString *)imageURLString gameID:(NSString *)gameId;
-(void) cacheGameImageData:(NSData *)imageData gameID:(NSString *)gameId;

///
/// this will execute a game search specified in searchReader, unless it can find the search results in the local cache.
/// if not found in local cache, it will cache the results before returning.
- (NSArray*)  getGameSearchResults: (XmlSearchReader*) searchReader withError: (NSError**) parseError searchGameType: (BGGSearchGameType) searchType;

//! return the current username, or nil if not provided. If no user name it will pop a dialog and open the setting page
- (NSString*) handleMissingUsername;

//! cancel any current download operation, build a new DownloadGameInfoOperation object
- (DownloadGameInfoOperation*) cancelExistingCreateNewDownloadGameInfoOperation;

//! load the full game from a search result
- (void) loadGameFromSearchResult: (BBGSearchResult*) searchResult;

//! save a resume point. this is called to setup the user for next time they start to start here
- (void) saveResumePoint: (BGGResumeState) state withString: (NSString *) strData;

//! this is called at startup to resume the user where they were when they left the app
- (void) resumeFromSavedPoint;

//! this will load a full game from the db if found or from the web if not. if loaded from web, it will cache it locally before returning
- (FullGameInfo*) getFullGameInfoByGameIdFromBGG: (NSString*) gameId;

//! this will load the menu item that you requested
- (void) loadMenuItem:(NSInteger) menuItem;

//! this will return the current username, without checking if it is actually set
- (NSString*) getCurrentUserName;

- (BOOL) confirmUserNameAndPassAvailable;


@end

