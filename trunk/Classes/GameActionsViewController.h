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
//  GameActionsViewController.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FullGameInfo;
@class CollectionItemData;
#import "BGGConnect.h"

@interface GameActionsViewController : UIViewController {
	FullGameInfo * fullGameInfo;
	IBOutlet UIButton * logPlayButton;
	IBOutlet UIButton * safariButton;
	IBOutlet UIButton * modifyButton;
    IBOutlet UISegmentedControl * rateControl;
    CollectionItemData * itemData;
    IBOutlet UIActivityIndicatorView * ratingActivityView;
    BGGConnectResponse saveResponse;
}


@property (nonatomic, strong ) FullGameInfo * fullGameInfo;

@property (nonatomic, strong ) UIButton * logPlayButton;
@property (nonatomic, strong ) UIButton * safariButton;
@property (nonatomic, strong ) UISegmentedControl * rateControl;


- (IBAction) openRecordAPlay;
- (IBAction) openGameInSafari;
- (IBAction) manageGameInCollection;
- (BOOL) confirmUserNameAndPassAvailable;
- (IBAction) segControlChanged: (UISegmentedControl *) control;


- (void) loadRating;
- (void) ratingLoaded;
- (void) saveRating;
- (void) ratingSaved;


@end
