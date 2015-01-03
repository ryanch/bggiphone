//
//  FullInfoViewController.h
//  BGG
//
//  Created by Christianson, Ryan on 2/25/13.
//
//

#import "LoadingViewController.h"

@interface FullInfoViewController : LoadingViewController 
{
    IBOutlet UIWebView * webView;
    IBOutlet UIActivityIndicatorView * loadingView;

    NSInteger gameId;

}

@property NSInteger gameId;
@property (nonatomic, readwrite, strong) UIWebView * webView;
@property (nonatomic, readwrite, strong) UIActivityIndicatorView * loadingView;


@end