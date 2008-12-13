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
}


@property (nonatomic, retain) UILabel * currentItemLabel;
@property (nonatomic, retain) UINavigationController *parentNav;
@property (nonatomic, retain) UIProgressView * progressView;


- (void) startLoading;

- (void) updateUser;

- (void) allDone;

- (IBAction) cancelSync;



@end
