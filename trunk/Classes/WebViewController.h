//
//  WebViewController.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
	IBOutlet UIWebView * webView;
	NSString * startingURL;
}

@property (nonatomic, retain ) UIWebView * webView;

- (void) setURL: (NSString*) urlString;

@end
