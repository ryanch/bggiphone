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

@property (nonatomic, retain ) UIPickerView *gamePicker;
@property (nonatomic, retain ) UIButton *showAllMatchesButton;
@property (nonatomic, retain ) UIButton *shakeForRandomButton;
@property (nonatomic, retain ) UILabel *directionsLabel;

- (NSInteger) valueFromPickerForComponent: (NSInteger) comp;

+(GamePickerUIViewController*) buildGamePickerUIViewController;

- (IBAction) showAllMachesClick;

- (IBAction) pickRandom;

@end
