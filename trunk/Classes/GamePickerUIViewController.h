//
//  GamePickerUIViewController.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GamePickerUIViewController : UIViewController <UIPickerViewDelegate> {
	IBOutlet UIPickerView *gamePicker;
	NSArray * playersChoices;
	NSArray * timeChoices;
	NSArray * weightChoices;
	IBOutlet UIButton * showAllMatchesButton;
	IBOutlet UIButton * shakeForRandomButton;
	IBOutlet UILabel * directionsLabel;
}

@property (nonatomic, strong ) UIPickerView *gamePicker;
@property (nonatomic, strong ) UIButton *showAllMatchesButton;
@property (nonatomic, strong ) UIButton *shakeForRandomButton;
@property (nonatomic, strong ) UILabel *directionsLabel;

- (NSInteger) valueFromPickerForComponent: (NSInteger) comp;

+(GamePickerUIViewController*) buildGamePickerUIViewController;

- (IBAction) showAllMachesClick;

- (IBAction) pickRandom;

@end
