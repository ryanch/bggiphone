//
//  GameViewUITabBarViewController.h
//  BGG
//
//  Created by Christianson, Ryan on 3/3/13.
//
//

#import <UIKit/UIKit.h>

@class FullGameInfo;

@interface GameViewUITabBarViewController : UITabBarController <UIActionSheetDelegate>


- (void) gameActionButtonPressed;

- (void) openGameInSafari;
- (void) openRecordAPlay;


@property FullGameInfo * fullGameInfo;

@end
