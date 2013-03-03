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
//  DownloadGameInfoOperation.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameInfoViewController;
@class GameActionsViewController;
@class GameForumsViewController;
@class BBGSearchResult;
@class FullGameInfo;
@class GameViewUITabBarViewController;
@class CollectionItemEditViewController;

@interface DownloadGameInfoOperation : NSOperation {
	GameInfoViewController * statsController;
	GameInfoViewController * infoController;
	GameActionsViewController * actionsController;
	GameForumsViewController * forumsController;
	GameViewUITabBarViewController * tabBarController;
	
	BBGSearchResult * searchResult;
	BOOL isExe;
	BOOL isDone;
	FullGameInfo * fullGameInfo;
}

@property CollectionItemEditViewController * collectionManager;

@property (nonatomic, strong) UITabBarController * tabBarController;
@property (nonatomic, strong) GameInfoViewController * statsController;
@property (nonatomic, strong) GameInfoViewController * infoController;
@property (nonatomic, strong) GameInfoViewController * summaryController;



@property (nonatomic, strong) GameActionsViewController * actionsController;
@property (nonatomic, strong) GameForumsViewController * forumsController;
@property (nonatomic, strong) BBGSearchResult * searchResult;

- (void) doTheWork;

@end
