//
//  CommentsUIViewController.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentsUIViewController : UIViewController {
	IBOutlet UIWebView * webView;
	IBOutlet UIActivityIndicatorView * loadingView;
	BOOL pageIsLoaded;
	BOOL workingOnLoading;
	NSString * pageToLoad;
	NSString * gameId;
}


-(void) startLoadingPage;
-(void) loadComplete;

@property (nonatomic, strong) NSString *  gameId;
@property (nonatomic, strong)  UIWebView * webView;
@property (nonatomic, strong)  UIActivityIndicatorView * loadingView;

@end
