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
//  BGGAppDelegate.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/16/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "BGGAppDelegate.h"
#import "RootViewController.h"
#import "PlistSettings.h"
#import "Beacon.h" 
#import "DownloadGameInfoOperation.h"
#import "DbAccess.h"
#import "GameViewTabController.h"
#import "GameInfoViewController.h"
#import "GameActionsViewController.h"
#import "BBGSearchResult.h"
#import "SearchUIViewController.h";
#import "SettingsUIViewController.h"
#import "AboutViewController.h"
#import "BoardGameSearchResultsTableViewController.h"
#import "XmlSearchReader.h"
#import "CommentsUIViewController.h"
#import "GamePickerUIViewController.h"
#import "FullGameInfo.h"
#import "XmlGameInfoReader.h"
#import "CollectionDownloadUIView.h"

@implementation BGGAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize appSettings;
@synthesize downloadOperation;
@synthesize dbAccess;



- (void) saveResumePoint: ( BGGResumeState ) state withString: (NSString *) strData {
	[appSettings.dict setObject: [NSNumber numberWithInt:state]	forKey: @"resumeState"];
	

	if (strData == nil ) {
		[appSettings.dict removeObjectForKey:@"resumeData"];
	}
	else {
		[appSettings.dict setObject: strData	forKey: @"resumeData"];	
	}
	
}

- (DownloadGameInfoOperation*) cancelExistingCreateNewDownloadGameInfoOperation {
	if ( downloadOperation != nil ) {
		[downloadOperation cancel];
		[downloadOperation release];
	}
	
	self.downloadOperation = [[DownloadGameInfoOperation alloc] init];
	return self.downloadOperation;
}

+ (NSString*) urlEncode: (NSString*) str {
	//CFStringRef preprocessedString =
	//CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)str, CFSTR(""), kCFStringEncodingUTF8);
	CFStringRef urlString =
	CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL,  (CFStringRef)@"&?=", kCFStringEncodingUTF8);
	
	//[(NSString*)preprocessedString release];
	
	NSString * result = (NSString*)urlString;
	[result autorelease];
	return result;
}
																										  
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	RANDOM_SEED();
	
	dbAccess = [[DbAccess alloc] init];
	
	downloadOperation = nil;
	
	NSString *applicationCode = @"6825067cd78da89cf8b5409da91ea9df";
	[Beacon initAndStartBeaconWithApplicationCode:applicationCode useCoreLocation:NO];
	
	
	appSettings = [[PlistSettings alloc] initWithSettingsNamed:@"settings"];
	
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	
	// create html dir
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * tempFilePath = [documentsDirectory stringByAppendingPathComponent:  @"../tmp/h/" ];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	[fileManager createDirectoryAtPath:tempFilePath		attributes:nil];
	
	// create image dir
	tempFilePath = [documentsDirectory stringByAppendingPathComponent:  @"../tmp/i/" ];
	[fileManager createDirectoryAtPath:tempFilePath		attributes:nil];
	
	// try to resume
	[self resumeFromSavedPoint];
}


- (void) resumeFromSavedPoint {
	
	if ( self.appSettings == nil ) {
		return;
	}
	
	NSNumber * stateCode = [self.appSettings.dict objectForKey:	@"resumeState"];
	if ( stateCode == nil ) {
		return;
	}
	
	NSString * resumeData = (NSString * ) [self.appSettings.dict objectForKey:	@"resumeData"];
	
	NSInteger stateCodeInt = [stateCode intValue];
	
	// resume a game
	if ( stateCodeInt == BGG_RESUME_GAME ) {
		if ( resumeData == nil ) {
			return;
		}
		
		BBGSearchResult * result = [[BBGSearchResult alloc] init];
		result.primaryTitle = @"Loading...";
		result.gameId = resumeData;
		[result autorelease];
		[self loadGameFromSearchResult:result];
		
	}
	else if ( stateCodeInt == BGG_RESUME_PICK_GAME ) {
		[self loadMenuItem:PICK_GAME_CHOICE];
	}
	else if ( stateCodeInt == BGG_RESUME_ABOUT ) {
		[self loadMenuItem:ABOUT_MENU_CHOICE];
	}
	else if ( stateCodeInt == BGG_RESUME_SEARCH ) {
		[self loadMenuItem:SEARCH_MENU_CHOICE];
	}	
	else if ( stateCodeInt == BGG_RESUME_OWNED ) {
		[self loadMenuItem:OWNED_MENU_CHOICE];
	}
	else if ( stateCodeInt == BGG_RESUME_WISH ) {
		[self loadMenuItem:WISH_MENU_CHOICE];
	}	
	else if ( stateCodeInt == BGG_RESUME_SETTINGS ) {
		[self loadMenuItem:SETTINGS_MENU_CHOICE];
	}
	
}


- (void) loadGameFromSearchResult: (BBGSearchResult*) searchResult {
	
	
	[self saveResumePoint:BGG_RESUME_GAME withString:searchResult.gameId];
	
	UITabBarController * tabBarController = [[UITabBarController alloc] init];
	
	GameInfoViewController *gameInfo = [[[GameInfoViewController alloc] initWithNibName:@"GameInfo" bundle:nil] autorelease];
	gameInfo.title = @"Info";
	UITabBarItem * infoItem = [[UITabBarItem alloc] initWithTitle:@"Info"	image:[UIImage imageNamed:@"info.png"] tag:0];
	gameInfo.tabBarItem = infoItem;
	[infoItem release];
	
	GameInfoViewController *gameStats = [[[GameInfoViewController alloc] initWithNibName:@"GameInfo" bundle:nil] autorelease];
	gameStats.title = @"Stats";
	UITabBarItem * statsItem = [[UITabBarItem alloc] initWithTitle:@"Stats"	image:[UIImage imageNamed:@"stats.png"] tag:0];
	gameStats.tabBarItem = statsItem;
	[statsItem release];
	
	
	CommentsUIViewController *gameComments = [[[CommentsUIViewController alloc] initWithNibName:@"GameComments" bundle:nil] autorelease];
	gameComments.title = @"Comments";
	UITabBarItem * commentsItem = [[UITabBarItem alloc] initWithTitle:@"Comments"	image:[UIImage imageNamed:@"comments.png"] tag:0];
	gameComments.tabBarItem = commentsItem;
	gameComments.gameId = searchResult.gameId;
	[commentsItem release];
	
	
	GameActionsViewController *gameActions  = [[[GameActionsViewController alloc] initWithNibName:@"GameActions" bundle:nil] autorelease];	
	gameActions.title = @"Actions";
	UITabBarItem * actionsItem = [[UITabBarItem alloc] initWithTitle:@"Actions"	image:[UIImage imageNamed:@"actions.png"] tag:0];
	gameActions.tabBarItem = actionsItem;
	[actionsItem release];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:gameInfo, gameStats,gameComments, gameActions, nil];
	//[tabBarController setViewControllers: [NSArray arrayWithObjects:gameActions, gameInfo, nil] animated:NO];
	
	
	tabBarController.title = searchResult.primaryTitle;
	[self.navigationController pushViewController:tabBarController		animated:YES];
	[tabBarController release];
	
	
	
	DownloadGameInfoOperation *dl = [self cancelExistingCreateNewDownloadGameInfoOperation];
	dl.infoController = gameInfo;
	dl.statsController = gameStats;
	dl.actionsController = gameActions;
	dl.tabBarController = tabBarController;
	dl.searchResult = searchResult;
	
	[dl start];
	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	[[Beacon shared] endBeacon];
	
	// Save data if appropriate
	[appSettings saveSettings];
	
	// delete temp files
	NSFileManager * fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * tempFilePath = [documentsDirectory stringByAppendingPathComponent:  @"../tmp/h/" ];
	
	[fileManager removeItemAtPath:tempFilePath	error:nil];
	
	
	[dbAccess cleanupForShutdown];
	
}

- (NSString*) getCurrentUserName {
	NSString * username = [self.appSettings.dict objectForKey:@"username"];
	if ( username == nil || [username length] == 0 ) {
		return nil;
	}
	return username;
}

- (NSString *) handleMissingUsername {
	NSString * username = (NSString*)[self.appSettings.dict objectForKey:@"username"];
	
	if ( username == nil || [username length] == 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Need Username", @"ask user to provide username title")
														message:NSLocalizedString(@"Please enter your username, to view your data.", @"please give your username")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
		
		
		SettingsUIViewController * settings = [SettingsUIViewController buildSettingsUIViewController];
		
		[navigationController pushViewController:settings		animated:YES];
		
		return nil;
	}
	return username;
}


- (FullGameInfo*) initFullGameInfoByGameIdFromBGG: (NSString*) gameId {
	
	
	FullGameInfo* fullGameInfo = [self.dbAccess fetchFullGameInfoByGameId: [gameId intValue] ];
	if ( fullGameInfo != nil && fullGameInfo.isCached == YES  ) {
		[fullGameInfo retain];
		return fullGameInfo;
	}
	
	// do the work
	XmlGameInfoReader *reader = [[XmlGameInfoReader alloc] init];
	
	NSString * urlStr = [NSString stringWithFormat:@"http://www.boardgamegeek.com/xmlapi/game/%@?stats=1", gameId	];
	NSURL *url = [NSURL URLWithString: urlStr	];
	
	

	[reader parseXMLAtURL:url	parseError:nil];

	fullGameInfo = reader.gameInfo;
	fullGameInfo.isCached = YES;

	fullGameInfo.gameId = gameId;

	[fullGameInfo retain];
	
	// cache game image first
	[self cacheGameImage: fullGameInfo];
	
	// then save to db
	[self.dbAccess saveFullGameInfo:fullGameInfo];
	
	[reader release];
	
	
	return fullGameInfo;
}


- (NSString*) buildImageFilePathForGameId: (NSString*) gameId {
	
	// create a new html file for the game
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"../tmp/i/%@.jpg", gameId] ];
	
	
}

- (NSString*) buildImageThumbFilePathForGameId: (NSString*) gameId {
	
	// create a new html file for the game
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"../tmp/i/%@_t.jpg", gameId] ];
	
	
}




-(void) cacheGameImage: (FullGameInfo*) fullGameInfo {
	
	NSString * tempFilePath =[self buildImageFilePathForGameId: fullGameInfo.gameId];

	NSFileManager * fileManager = [NSFileManager defaultManager];
	if ( [fileManager	 fileExistsAtPath:tempFilePath ] ) {
		return;
	}
	
	NSURL * url = [NSURL URLWithString:fullGameInfo.imageURL];
	
	NSData * imageData = [[NSData alloc] initWithContentsOfURL: url];
	[imageData writeToFile:tempFilePath atomically:YES];
	
	// now resize and save again
	NSString * thumbImagePath = [self buildImageThumbFilePathForGameId: fullGameInfo.gameId];
	
	
	CGSize newSize = CGSizeMake( 40, 40 );
	
	UIImage * image = [[UIImage alloc] initWithData:imageData];
	
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSData * thumbData = UIImageJPEGRepresentation( newImage, 1.0f );
	[thumbData writeToFile:thumbImagePath atomically:YES];
	
	
	// clean up
	// NOTE newImage is autorelease
	//[thumbData release];
	[image release];
	[imageData release];
	
	
	
	
	
}

- (NSArray*)  initGameSearchResults: (XmlSearchReader*) searchReader withError: (NSError**) parseError isForOwnedGames: (BOOL) searchingOwnedGames  {
	
	NSArray * results = nil;
	
	// see if we can  use the ownded games cache

	if ( searchingOwnedGames ) {
		results = [self.dbAccess findGamesOwned];
	}
	
	if ( results != nil ) {
		[results retain];
		return results; 
	}
	
	
		
		
		BOOL success = [searchReader parseXMLAtSearchURLWithError:parseError]; 
		
		
		
		if ( success &&  searchReader.searchResults != nil && [ searchReader.searchResults count ] > 0 ) {
			results = searchReader.searchResults;
			
			// update ownership
			if ( searchingOwnedGames == YES ) {
				for ( NSInteger i = 0; i < [results count]; i++ ) {
					BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:i];
					[self.dbAccess saveGameAsOwnedGameId:[result.gameId intValue] title:result.primaryTitle];
				}
			}
			
		}
		
		if ( success ) {
			if ( [results count] == 0 ) {
				return nil;
			}
		}
		else {
			return nil;
		}
	
		[results retain];
		return results;		
	
	
}


- (void) loadMenuItem:(NSInteger) menuItem {
	
	
    
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	if ( menuItem == SEARCH_MENU_CHOICE ) {
		
		[appDelegate saveResumePoint:BGG_RESUME_SEARCH withString:nil];
		
		[[Beacon shared] startSubBeaconWithName:@"search menu click" timeSession:NO];
		
		SearchUIViewController * search = [SearchUIViewController buildSearchUIViewController];
		[appDelegate.navigationController pushViewController:search		animated:YES];
	}
	
	else if ( menuItem == PICK_GAME_CHOICE ) {
		
		
		NSString * username = [self handleMissingUsername];
		if ( username == nil ) {
			return;
		}
		
		// see if we have cached games
		if ( ![dbAccess checkIfCollectionIsLoaded] ) {
			
			
			CollectionDownloadUIView * colDl = [[CollectionDownloadUIView	alloc] initWithNibName:@"CollectionDownload" bundle:nil];
			colDl.title = NSLocalizedString( @"Collection Download", @"Collection download title" );
			colDl.parentNav = appDelegate.navigationController;
			[appDelegate.navigationController pushViewController:colDl 		animated:YES];
			[colDl release];
			
			
			return;
			
		}
		
		
		[appDelegate saveResumePoint:BGG_RESUME_PICK_GAME withString:nil];
		
		[[Beacon shared] startSubBeaconWithName:@"pick game menu click" timeSession:NO];
		
		
		GamePickerUIViewController * gamePicker = [GamePickerUIViewController buildGamePickerUIViewController];
		
		[appDelegate.navigationController pushViewController:gamePicker 		animated:YES];
		
	}
	else if ( menuItem == SETTINGS_MENU_CHOICE ) {
		
		[appDelegate saveResumePoint:BGG_RESUME_SETTINGS withString:nil];
		
		
		[[Beacon shared] startSubBeaconWithName:@"settings menu click" timeSession:NO];
		
		SettingsUIViewController * settings = [SettingsUIViewController buildSettingsUIViewController];
		
		[appDelegate.navigationController pushViewController:settings		animated:YES];
	}
	else if ( menuItem == ABOUT_MENU_CHOICE ) {
		
		[appDelegate saveResumePoint:BGG_RESUME_ABOUT withString:nil];
		
		[[Beacon shared] startSubBeaconWithName:@"about page menu click" timeSession:NO];
		
		AboutViewController * about = [[AboutViewController alloc] initWithNibName:@"About" bundle:nil];
		about.pageToLoad = @"about";
		about.title = NSLocalizedString( @"About" , @"about menu item" );
		[appDelegate.navigationController pushViewController:about	animated:YES]; 
		[about release];
	}
	else if ( menuItem == OWNED_MENU_CHOICE || menuItem== WISH_MENU_CHOICE ) { 
		
		
		
		
		NSString * username = [self handleMissingUsername];
		if ( username == nil ) {
			return;
		}		

		
		// encode the username
		username = [BGGAppDelegate urlEncode:username];
		
		BoardGameSearchResultsTableViewController * resultsViewer = [[BoardGameSearchResultsTableViewController alloc]  initWithStyle:UITableViewStylePlain];
		
		
		if ( menuItem == OWNED_MENU_CHOICE ) {
			
			[appDelegate saveResumePoint:BGG_RESUME_OWNED withString:nil];
			
			[[Beacon shared] startSubBeaconWithName:@"games owned menu click" timeSession:NO];
			
			resultsViewer.title = NSLocalizedString(@"Games Owned" , @"games owned menu item" );
		}
		else {
			[appDelegate saveResumePoint:BGG_RESUME_WISH withString:nil];
			
			[[Beacon shared] startSubBeaconWithName:@"games on wish list menu click" timeSession:NO];
			
			resultsViewer.title = NSLocalizedString( @"Games On Wishlist" , @"games on wishlist menu item" );
		}
		
		//resultsViewer.resultsToDisplay = search.searchResults;
		
		[appDelegate.navigationController pushViewController:resultsViewer		animated:YES];
		
		XmlSearchReader * search = [[XmlSearchReader alloc] init];
		search.parseItemFormat = YES;
		
		
		
		
		
		NSString * urlStr = nil;
		
		resultsViewer.searchingOwnedGames = NO;
		
		if ( menuItem == OWNED_MENU_CHOICE ) {
			urlStr = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi/collection/%@?own=1", username ];
			resultsViewer.searchingOwnedGames = YES;
		}
		else {
			urlStr = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi/collection/%@?wishlist=1&notown=1", username ];
			resultsViewer.searchingOwnedGames = NO;
		}
		
		NSURL *url = [NSURL URLWithString: urlStr	];
		search.searchURL = url;
		[resultsViewer doSearch: search];
		
		[search release];
		[resultsViewer release];		
		
		
		
	}
	
}





- (void)dealloc {
	[dbAccess release];
	[navigationController release];
	[appSettings release];
	[window release];
	[downloadOperation release];
	[super dealloc];
}

@end
