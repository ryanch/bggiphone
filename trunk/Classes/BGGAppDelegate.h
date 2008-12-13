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
#define OWNED_MENU_CHOICE 1
#define WISH_MENU_CHOICE 3
#define SETTINGS_MENU_CHOICE 4
#define ABOUT_MENU_CHOICE 5
#define PICK_GAME_CHOICE 2


enum {
		BGG_RESUME_GAME = 1,
		BGG_RESUME_OWNED = 2,
		BGG_RESUME_WISH = 4,
		BGG_RESUME_ABOUT = 5,
		BGG_RESUME_SEARCH = 6,
		BGG_RESUME_SETTINGS = 7,
		BGG_RESUME_PICK_GAME = 8
};
typedef NSInteger BGGResumeState;

@class BBGSearchResult;
@class PlistSettings;
@class DownloadGameInfoOperation;
@class DbAccess;
@class FullGameInfo;
@class XmlSearchReader;

@interface BGGAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	PlistSettings * appSettings;
	DownloadGameInfoOperation * downloadOperation;
	DbAccess *dbAccess;
}

@property (nonatomic, retain) DbAccess *dbAccess;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) PlistSettings * appSettings;
@property (nonatomic, retain) DownloadGameInfoOperation * downloadOperation;

+ (NSString*) urlEncode: (NSString*) str;

- (NSString*) buildImageFilePathForGameId: (NSString*) gameId;
- (NSString*) buildImageThumbFilePathForGameId: (NSString*) gameId;

-(void) cacheGameImage: (FullGameInfo*) fullGameInfo;

- (NSArray*)  initGameSearchResults: (XmlSearchReader*) searchReader withError: (NSError**) parseError isForOwnedGames: (BOOL) searchingOwnedGames;

- (NSString*) handleMissingUsername;

- (DownloadGameInfoOperation*) cancelExistingCreateNewDownloadGameInfoOperation;

- (void) loadGameFromSearchResult: (BBGSearchResult*) searchResult;

- (void) saveResumePoint: (BGGResumeState) state withString: (NSString *) strData;

- (void) resumeFromSavedPoint;


- (FullGameInfo*) initFullGameInfoByGameIdFromBGG: (NSString*) gameId;

- (void) loadMenuItem:(NSInteger) menuItem;

- (NSString*) getCurrentUserName;

@end

