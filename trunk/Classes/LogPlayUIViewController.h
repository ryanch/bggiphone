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
//  LogPlayUIViewController.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogPlayUIViewController : UIViewController {
	IBOutlet UISegmentedControl * playCountController;
	IBOutlet UIDatePicker * datePicker;
	IBOutlet UIActivityIndicatorView * loadingView;
	IBOutlet UILabel * playLogLabel;
	NSInteger playCount;
	NSString *gameId;
}

-(void) updatePicker;
- (IBAction) logPlayClicked;
- (IBAction) addPlayCount;
- (void) doLogPlay;
- (void) logPlayComplete;
- (BOOL) confirmUserNameAndPassAvailable;
- (void) doneButtonPressed;


@property (nonatomic,strong) UISegmentedControl * playCountController;
@property (nonatomic,strong)  UIDatePicker * datePicker;
@property (nonatomic,strong) NSString * gameId;
@property (nonatomic,strong) UIActivityIndicatorView * loadingView;
@property (weak, nonatomic) IBOutlet UITextView *commentText;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *playLogLabel;
@property (weak, nonatomic) IBOutlet UIControl *myControl;
@property (nonatomic) NSInteger kbScrolled;
@property (weak, nonatomic) IBOutlet UITextView *locationText;

@end
