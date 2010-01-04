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
#import "GameForumsViewController.h"
#import "BrowseTop100ViewController.h"
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
@synthesize authCookies;



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
	//CFStringRef urlString = 
	//CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL,  (CFStringRef)@"&?=", kCFStringEncodingUTF8);
	
	
	//[(NSString*)preprocessedString release];
	
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, NULL, kCFStringEncodingUTF8);
	
	
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
	
	
	
	RootViewController * rootView = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	
	navigationController = [[UINavigationController alloc] initWithRootViewController: rootView];
	navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0];
	
	
	
	[rootView release];
	
	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	
	// create html dir
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * tempFilePath = [documentsDirectory stringByAppendingPathComponent:  @"../tmp/h/" ];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	[fileManager createDirectoryAtPath:tempFilePath		attributes:nil];
	
	// create image dir
	tempFilePath = [documentsDirectory stringByAppendingPathComponent:  @"/imgs/" ];
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
		result.primaryTitle = NSLocalizedString( @"Loading..." , @"loading text while loading games" );
		result.gameId = resumeData;
		[result autorelease];
		[self loadGameFromSearchResult:result];
		
	}
	else if ( stateCodeInt == BGG_RESUME_GAMES_TO_PLAY_LIST ) {
		[self loadMenuItem:WANT_TO_PLAY_CHOICE];
	}	
	else if ( stateCodeInt == BGG_RESUME_GAMES_PLAYED_LIST ) {
		[self loadMenuItem:GAMES_PLAYED_MENU_CHOICE];
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
	else if ( stateCodeInt == BGG_RESUME_BROWSE_TOP_100_GAMES ) {
		[self loadMenuItem:BROWSE_TOP_100_MENU_CHOICE];
	}
	
}


- (void) loadGameFromSearchResult: (BBGSearchResult*) searchResult {
	
	
	[self saveResumePoint:BGG_RESUME_GAME withString:searchResult.gameId];
	
	UITabBarController * tabBarController = [[UITabBarController alloc] init];
	
	GameInfoViewController *gameInfo = [[[GameInfoViewController alloc] initWithNibName:@"GameInfo" bundle:nil] autorelease];
	gameInfo.title  = NSLocalizedString( @"Info", @"title for the info screen for a board game" );
	UITabBarItem * infoItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString( @"Info", @"title for the info screen for a board game" )	image:[UIImage imageNamed:@"info.png"] tag:0];
	gameInfo.tabBarItem = infoItem;
	[infoItem release];
	
	GameInfoViewController *gameStats = [[[GameInfoViewController alloc] initWithNibName:@"GameInfo" bundle:nil] autorelease];
	gameStats.title = NSLocalizedString( @"Stats", @"title for the stats screen for a board game" );
	UITabBarItem * statsItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString( @"Stats", @"title for the stats screen for a board game" )	image:[UIImage imageNamed:@"stats.png"] tag:0];
	gameStats.tabBarItem = statsItem;
	[statsItem release];
	
	
	CommentsUIViewController *gameComments = [[[CommentsUIViewController alloc] initWithNibName:@"GameComments" bundle:nil] autorelease];
	gameComments.title = NSLocalizedString( @"Comments", @"title for the comments screen for a board game");
	UITabBarItem * commentsItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString( @"Comments", @"title for the comments screen for a board game")	image:[UIImage imageNamed:@"comments.png"] tag:0];
	gameComments.tabBarItem = commentsItem;
	gameComments.gameId = searchResult.gameId;
	[commentsItem release];
	
	
	GameActionsViewController *gameActions  = [[[GameActionsViewController alloc] initWithNibName:@"GameActions" bundle:nil] autorelease];	
	gameActions.title = NSLocalizedString( @"Actions", @"title for the screen on a board game to do actions with that game");
	UITabBarItem * actionsItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString( @"Actions", @"title for the screen on a board game to do actions with that game")	image:[UIImage imageNamed:@"actions.png"] tag:0];
	gameActions.tabBarItem = actionsItem;
	[actionsItem release];
	
	GameForumsViewController *gameForums  = [[[GameForumsViewController alloc] init] autorelease];	
	gameForums.title = NSLocalizedString( @"Forums", @"title for the screen on a board game to do forums with that game");
	UITabBarItem * forumsItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString( @"Forums", @"title for the screen on a board game to do forums with that game") image:[UIImage imageNamed:@"comments.png"] tag:0];
	gameForums.tabBarItem = forumsItem;
	[forumsItem release];
	

	tabBarController.viewControllers = [NSArray arrayWithObjects:gameInfo, gameStats, gameComments, gameActions, gameForums, nil];
	//[tabBarController setViewControllers: [NSArray arrayWithObjects:gameActions, gameInfo, nil] animated:NO];
	
	
	tabBarController.title = searchResult.primaryTitle;
	[self.navigationController pushViewController:tabBarController		animated:YES];
	[tabBarController release];
	
	
	
	DownloadGameInfoOperation *dl = [self cancelExistingCreateNewDownloadGameInfoOperation];
	dl.infoController = gameInfo;
	dl.statsController = gameStats;
	dl.actionsController = gameActions;
	dl.forumsController = gameForums;
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

- (BOOL) confirmUserNameAndPassAvailable {

	
	NSString * username = [self.appSettings.dict objectForKey:@"username"];
	NSString * password = [self.appSettings.dict objectForKey:@"password"];
	
	if ( username == nil || [username length] == 0 || password == nil || [password length] == 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Need Username and Password", @"ask user to provide username and pass title")
														message:NSLocalizedString(@"Please enter your username and password to modify your collection.", @"please give your username and password to modify your collection.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
		
		
		SettingsUIViewController * settings = [SettingsUIViewController buildSettingsUIViewController];
		
		[self.navigationController pushViewController:settings		animated:YES];
		
		return NO;
	}
	
	return YES;
	
}


- (NSString *) handleMissingUsername {
	NSString * username = (NSString*)[self.appSettings.dict objectForKey:@"username"];
	
	if ( username == nil || [username length] == 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Need Username", @"ask user to provide username title")
														message:NSLocalizedString(@"Please enter your username, to view your data.", @"please give your username")
													   delegate:self cancelButtonTitle:NSLocalizedString( @"OK", @"okay button") otherButtonTitles: nil];
		[alert show];	
		[alert release];	
		
		
		SettingsUIViewController * settings = [SettingsUIViewController buildSettingsUIViewController];
		
		[navigationController pushViewController:settings		animated:YES];
		
		return nil;
	}
	return username;
}


- (FullGameInfo*) getFullGameInfoByGameIdFromBGG: (NSString*) gameId {
	
	
	FullGameInfo* fullGameInfo = [self.dbAccess fetchFullGameInfoByGameId: [gameId intValue] ];
	if ( fullGameInfo != nil && fullGameInfo.isCached == YES  ) {
		//[fullGameInfo retain];
		return fullGameInfo;
	}
	
	// do the work
	XmlGameInfoReader *reader = [[XmlGameInfoReader alloc] init];
	
	NSString * urlStr = [NSString stringWithFormat:@"http://www.boardgamegeek.com/xmlapi/boardgame/%@?stats=1", gameId	];
	NSURL *url = [NSURL URLWithString: urlStr	];
	
	

	BOOL success = [reader parseXMLAtURL:url	parseError:nil];

	if ( !success ) {
		[reader release];	
		return nil;
	}
	
	fullGameInfo = reader.gameInfo;
	[fullGameInfo retain];
	[fullGameInfo autorelease];
	fullGameInfo.isCached = YES;

	fullGameInfo.gameId = gameId;

	//[fullGameInfo retain];
	
	// cache game image first
	[self cacheGameImage: fullGameInfo];
	
	// then save to db
	[self.dbAccess saveFullGameInfo:fullGameInfo];
	
	[reader release];
	
	
	return fullGameInfo;
}


//! build a local path to an game image file, check if it exists
- (NSString*) buildImageFilePathForGameId: (NSString*) gameId checkIfExists: (BOOL) exists {
	// create a new html file for the game
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"imgs/%@.jpg", gameId] ];
	
	if ( exists ) {
		NSFileManager * fileManager = [NSFileManager defaultManager];
		if ( [fileManager	 fileExistsAtPath:fullPath ] ) {
			return fullPath;
		}
		return nil;	
	}
	
	return fullPath;
	
	
}

//! build a local path to a game image file thumbnail, check if it exists
- (NSString*) buildImageThumbFilePathForGameId: (NSString*) gameId checkIfExists: (BOOL) exists {
	// create a new html file for the game
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fullPath =  [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"imgs/%@_t.png", gameId] ];
	
	if ( exists ) {
		NSFileManager * fileManager = [NSFileManager defaultManager];
		if ( [fileManager	 fileExistsAtPath:fullPath ] ) {
			return fullPath;
		}	
		
		return nil;
	}
	
	return fullPath;
}


- (NSString*) buildImageFilePathForGameId: (NSString*) gameId {
	
	return [self buildImageFilePathForGameId: gameId checkIfExists: YES];
	
}

- (NSString*) buildImageThumbFilePathForGameId: (NSString*) gameId {
	
	return [self buildImageThumbFilePathForGameId: (NSString*) gameId checkIfExists: YES];
	
}

-(void) cacheGameImageData:(NSData *)imageData gameID:(NSString *)gameId {
	
	// NOTE: This method can be called from background threads.
	
	NSString * tempFilePath = [self buildImageFilePathForGameId: gameId checkIfExists: NO];
	
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	if ( [fileManager	 fileExistsAtPath:tempFilePath ] ) {
		return;
	}
	
	[imageData writeToFile:tempFilePath atomically:YES];
	
	// now resize and save again
	NSString * thumbImagePath = [self buildImageThumbFilePathForGameId:gameId checkIfExists: NO];
	
	
	CGSize maxSize = CGSizeMake( 41, 41 );
	
	UIImage * image = [[UIImage alloc] initWithData:imageData];
	
	CGSize newSize = image.size;
	
	if(newSize.width > maxSize.width)
	{
		newSize.height = newSize.height * maxSize.width / newSize.width;
		newSize.width = maxSize.width;
	}
	if(newSize.height > maxSize.height)
	{
		newSize.width = newSize.width * maxSize.height / newSize.height;
		newSize.height = maxSize.height;
	}
	
	// UI* calls are not thread safe, but the code still uses UIImage and UIImagePNGRepresentation() because there doesn't seem to be a way to create JPEGs using purely Core Graphics.
	
	//UIGraphicsBeginImageContext( maxSize );
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmapContext = CGBitmapContextCreate(nil, maxSize.width, maxSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
	
	CGContextClearRect(bitmapContext, CGRectMake(0, 0, maxSize.width, maxSize.height));
	
	CGRect imageRect = CGRectMake((maxSize.width - newSize.width) / 2.0,
								  (maxSize.height - newSize.height) / 2.0,
								  newSize.width,
								  newSize.height);
	
	//[image drawInRect:CGRectIntegral(imageRect)];
	CGContextDrawImage(bitmapContext, imageRect, image.CGImage);
	
	//UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	//UIGraphicsEndImageContext();
	CGImageRef newCGImage = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease(bitmapContext);
	UIImage *newImage = [[[UIImage alloc] initWithCGImage:newCGImage] autorelease];
	CGImageRelease(newCGImage);
	
	NSData * thumbData = UIImagePNGRepresentation( newImage );
	[thumbData writeToFile:thumbImagePath atomically:YES];
	
	
	// clean up
	// NOTE newImage is autorelease
	[image release];
	[imageData release];
}


-(void) cacheGameImageAtURL:(NSString *)imageURLString gameID:(NSString *)gameId {
	
	NSURL * url = [NSURL URLWithString:imageURLString];
	
	NSData * imageData = [[NSData alloc] initWithContentsOfURL: url];
	
	[self cacheGameImageData:imageData gameID:gameId];
}


-(void) cacheGameImage: (FullGameInfo*) fullGameInfo {
	
	[self cacheGameImageAtURL:fullGameInfo.imageURL gameID:fullGameInfo.gameId];
	
}	



- (NSArray*)  getGameSearchResults: (XmlSearchReader*) searchReader withError: (NSError**) parseError searchGameType: (BGGSearchGameType) searchType {

	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];

	
	
	NSArray * results = nil;
	
	// see if we can  use the ownded games cache

	if ( searchType == BGG_SEARCH_OWNED ) {
		
		NSString * username = [appDelegate handleMissingUsername];
		if ( username == nil ) {
			return nil;
		}
		
		results = [self.dbAccess getAllGamesInListByTypeAsSearchResults:LIST_TYPE_OWN forUser:username];
	}
	else if ( searchType == BGG_SEARCH_WISH ) {
		
		NSString * username = [appDelegate handleMissingUsername];
		if ( username == nil ) {
			return nil;
		}
		
		results = [self.dbAccess getAllGamesInListByTypeAsSearchResults:LIST_TYPE_WISH forUser:username];
	}
	else if ( searchType == BGG_GAMES_TO_PLAY_LIST ) {
		
		NSString * username = [appDelegate handleMissingUsername];
		if ( username == nil ) {
			return nil;
		}
		
		results = [self.dbAccess getAllGamesInListByTypeAsSearchResults:LIST_TYPE_TOPLAY forUser:username];
	}	
	else if ( searchType == BGG_GAMES_PLAYED_LIST ) {
		
		NSString * username = [appDelegate handleMissingUsername];
		if ( username == nil ) {
			return nil;
		}
		
		results = [self.dbAccess getAllGamesInListByTypeAsSearchResults:LIST_TYPE_PLAYED forUser:username];
	}		
	
	
	if ( results != nil ) {
		//[results retain];
		return results; 
	}
	
	
		
		
		BOOL success = [searchReader parseXMLAtSearchURLWithError:parseError]; 
		
		
		
		if ( success &&  searchReader.searchResults != nil && [ searchReader.searchResults count ] > 0 ) {
			results = searchReader.searchResults;
			
			// update ownership
			if (  searchType == BGG_SEARCH_OWNED ) {
				for ( NSInteger i = 0; i < [results count]; i++ ) {
					BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:i];
					[self.dbAccess saveGameAsOwnedGameId:[result.gameId intValue] title:result.primaryTitle isInList: YES];
				}
			}
			else if ( searchType == BGG_SEARCH_WISH ) {
				for ( NSInteger i = 0; i < [results count]; i++ ) {
					BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:i];
					[self.dbAccess saveGameForListGameId:[result.gameId intValue] title:result.primaryTitle list: LIST_TYPE_WISH isInList: YES];
				}
			}
			else if ( searchType == BGG_GAMES_TO_PLAY_LIST ) {
				for ( NSInteger i = 0; i < [results count]; i++ ) {
					BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:i];
					[self.dbAccess saveGameForListGameId:[result.gameId intValue] title:result.primaryTitle list: LIST_TYPE_TOPLAY isInList: YES];
				}
			}
			else if ( searchType == BGG_GAMES_PLAYED_LIST ) {
				for ( NSInteger i = 0; i < [results count]; i++ ) {
					BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:i];
					[self.dbAccess saveGameForListGameId:[result.gameId intValue] title:result.primaryTitle list: LIST_TYPE_PLAYED isInList: YES];
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
	
		//[results retain];
		return results;		
	
	
}


- (void) loadMenuItem:(NSInteger) menuItem {
	

	if ( menuItem == SEARCH_MENU_CHOICE ) {
		
		[self saveResumePoint:BGG_RESUME_SEARCH withString:nil];
		
		[[Beacon shared] startSubBeaconWithName:@"search menu click" timeSession:NO];
		
		SearchUIViewController * search = [SearchUIViewController buildSearchUIViewController];
		[navigationController pushViewController:search		animated:YES];
	}
	
	else if ( menuItem == BROWSE_TOP_100_MENU_CHOICE ) {
		
		[self saveResumePoint:BGG_RESUME_BROWSE_TOP_100_GAMES withString:nil];
		
		[[Beacon shared] startSubBeaconWithName:@"browse top 100 menu click" timeSession:NO];
		
		BrowseTop100ViewController *browseTop100 = [[[BrowseTop100ViewController alloc] init ] autorelease];
		[navigationController pushViewController:browseTop100 animated:YES];
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
			colDl.parentNav = navigationController;
			[navigationController pushViewController:colDl 		animated:YES];
			[colDl release];
			
			
			return;
			
		}
		
		
		[self saveResumePoint:BGG_RESUME_PICK_GAME withString:nil];
		
		[[Beacon shared] startSubBeaconWithName:@"pick game menu click" timeSession:NO];
		
		
		GamePickerUIViewController * gamePicker = [GamePickerUIViewController buildGamePickerUIViewController];
		
		[navigationController pushViewController:gamePicker 		animated:YES];
		
	}
	else if ( menuItem == SETTINGS_MENU_CHOICE ) {
		
		[self saveResumePoint:BGG_RESUME_SETTINGS withString:nil];
		
		
		[[Beacon shared] startSubBeaconWithName:@"settings menu click" timeSession:NO];
		
		SettingsUIViewController * settings = [SettingsUIViewController buildSettingsUIViewController];
		
		[navigationController pushViewController:settings		animated:YES];
	}
	else if ( menuItem == ABOUT_MENU_CHOICE ) {
		
		[self saveResumePoint:BGG_RESUME_ABOUT withString:nil];
		
		[[Beacon shared] startSubBeaconWithName:@"about page menu click" timeSession:NO];
		
		AboutViewController * about = [[AboutViewController alloc] initWithNibName:@"About" bundle:nil];
		about.pageToLoad = @"about";
		about.title = NSLocalizedString( @"About" , @"about menu item" );
		[navigationController pushViewController:about	animated:YES]; 
		[about release];
	}
	else if ( menuItem == OWNED_MENU_CHOICE || menuItem== WISH_MENU_CHOICE || menuItem == WANT_TO_PLAY_CHOICE || menuItem == GAMES_PLAYED_MENU_CHOICE) { 
		
		
		
		
		NSString * username = [self handleMissingUsername];
		if ( username == nil ) {
			return;
		}		

		
		// encode the username
		username = [BGGAppDelegate urlEncode:username];
		
		BoardGameSearchResultsTableViewController * resultsViewer = [[BoardGameSearchResultsTableViewController alloc]  initWithStyle:UITableViewStylePlain];
		
		
		if ( menuItem == OWNED_MENU_CHOICE ) {
			
			[self saveResumePoint:BGG_RESUME_OWNED withString:nil];
			
			[[Beacon shared] startSubBeaconWithName:@"games owned menu click" timeSession:NO];
			
			resultsViewer.title = NSLocalizedString(@"Games Owned" , @"games owned menu item" );
			resultsViewer.searchGameType = BGG_SEARCH_OWNED;
			resultsViewer.currentResumeState = BGG_RESUME_OWNED;
		}
		if ( menuItem == WANT_TO_PLAY_CHOICE ) {
			
			[self saveResumePoint:BGG_RESUME_GAMES_TO_PLAY_LIST withString:nil];
			
			[[Beacon shared] startSubBeaconWithName:@"games to play menu click" timeSession:NO];
			
			resultsViewer.title = NSLocalizedString(@"Games To Play" , @"games on to play list menu item" );
			resultsViewer.searchGameType = BGG_GAMES_TO_PLAY_LIST;
			resultsViewer.currentResumeState = BGG_RESUME_GAMES_TO_PLAY_LIST;
		}	
		if ( menuItem == GAMES_PLAYED_MENU_CHOICE ) {
			
			[self saveResumePoint:BGG_RESUME_GAMES_PLAYED_LIST withString:nil];
			
			[[Beacon shared] startSubBeaconWithName:@"games played menu click" timeSession:NO];
			
			resultsViewer.title = NSLocalizedString(@"Games Played" , @"games played menu item" );
			resultsViewer.searchGameType = BGG_GAMES_PLAYED_LIST;
			resultsViewer.currentResumeState = BGG_RESUME_GAMES_PLAYED_LIST;
		}			
		else if (  menuItem == WISH_MENU_CHOICE ) {
			[self saveResumePoint:BGG_RESUME_WISH withString:nil];
			
			[[Beacon shared] startSubBeaconWithName:@"games on wish list menu click" timeSession:NO];
			
			resultsViewer.title = NSLocalizedString( @"Games On Wishlist" , @"games on wishlist menu item" );
			
			resultsViewer.searchGameType = BGG_SEARCH_WISH;
			resultsViewer.currentResumeState = BGG_RESUME_WISH;
		}
		
		//resultsViewer.resultsToDisplay = search.searchResults;
		
		[navigationController pushViewController:resultsViewer		animated:YES];
		
		XmlSearchReader * search = [[XmlSearchReader alloc] init];
		search.parseItemFormat = YES;
		
		
		
		
		
		NSString * urlStr = nil;
		
		
		if ( menuItem == OWNED_MENU_CHOICE ) {
			urlStr = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi/collection/%@?own=1", username ];
	
		}
		else if (menuItem == WISH_MENU_CHOICE ) {
			urlStr = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi/collection/%@?wishlist=1&notown=1", username ];

		}
		else if (menuItem == WANT_TO_PLAY_CHOICE ) {
			urlStr = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi/collection/%@?wanttoplay=1", username ];
			
		}	
		else if (menuItem == GAMES_PLAYED_MENU_CHOICE ) {
			urlStr = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi/collection/%@?played=1", username ];
			
		}			
		
		NSURL *url = [NSURL URLWithString: urlStr	];
		search.searchURL = url;
		[resultsViewer doSearch: search];
		
		[search release];
		[resultsViewer release];		
		
		
		
	}
	
}





- (void)dealloc {
	[authCookies release];
	[dbAccess release];
	[navigationController release];
	[appSettings release];
	[window release];
	[downloadOperation release];
	[super dealloc];
}

@end
