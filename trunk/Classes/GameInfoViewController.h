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
//  GameInfoViewController.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FullGameInfo;

#define STATS_MODE 1
#define INFO_MODE 2
#define COMMENTS_MODE 3

@interface GameInfoViewController : UIViewController <UIWebViewDelegate > {
	IBOutlet UIWebView * webView;
	IBOutlet UIActivityIndicatorView * loadingView;
	FullGameInfo * gameInfo;
	NSInteger displayMode;
}

- (void) updateForGameInfo: (FullGameInfo*) newGameInfo;
- (void) updateForGameStats: (FullGameInfo*) newGameInfo;


@property (nonatomic, retain)  UIWebView * webView;
@property (nonatomic, retain)  UIActivityIndicatorView * loadingView;
@property (nonatomic, retain)  FullGameInfo * gameInfo;

@end
