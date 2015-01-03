//
//  CollectionDownloadUIView.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CollectionDownloadUIView : UIViewController {
	IBOutlet UILabel * currentItemLabel;
	UINavigationController * parentNav;
	BOOL isCanceled;
	NSString *message;
	NSString *errorMessage;
	IBOutlet UIProgressView * progressView;
	float percentComplete;
	IBOutlet UIButton * cancelButton;
	IBOutlet UILabel * directionsLabel;
}


@property (nonatomic, strong) UILabel * currentItemLabel;
@property (nonatomic, strong) UINavigationController *parentNav;
@property (nonatomic, strong) UIProgressView * progressView;
@property (nonatomic, strong) UIButton * cancelButton;
@property (nonatomic, strong) UILabel * directionsLabel;

- (void) startLoading;

- (void) updateUser;

- (void) allDone;

- (IBAction) cancelSync;



@end
