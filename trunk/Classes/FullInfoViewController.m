//
//  FullInfoViewController.m
//  BGG
//
//  Created by Christianson, Ryan on 2/25/13.
//
//

#import "FullInfoViewController.h"


#import "BGGHTMLScraper.h"
#import "HtmlTemplate.h"
#import "BGGConnect.h"
#import "SettingsUIViewController.h"


@interface FullInfoViewController ()

@end

@implementation FullInfoViewController


@synthesize webView;
@synthesize gameId;
@synthesize loadingView;


#pragma mark LoadingViewController overrides

-(void) updateViews
{
    
    // note items will be a list of array with 1 item
    
	if ( items == nil )
	{
		webView.hidden = YES;
		[loadingView startAnimating];
		loadingView.hidden = NO;
        
	}
	else
	{
		NSString *templateFilePath = [NSString stringWithFormat:@"%@/full_info_template.html", [[NSBundle mainBundle] bundlePath]];
		
				
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		
        
        
		[params setObject:[items objectAtIndex:0] forKey:@"#!info#"];
		
		HtmlTemplate *messagesTemplate = [[HtmlTemplate alloc] initWithFileName:templateFilePath];
		
		NSString * pageHTML = [messagesTemplate allocMergeWithData:params];
	
		[loadingView stopAnimating];
		loadingView.hidden = YES;
		webView.hidden = NO;
		
		
		// set the web view to load it
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSURL *baseURL = [NSURL fileURLWithPath:path];
		
		[webView loadHTMLString:pageHTML baseURL:baseURL];
	}
}




-(NSString *) urlStringForLoading
{
    return [NSString stringWithFormat:@"http://boardgamegeek.com/boardgame/12333/%d", gameId ];
}

-(id) resultsFromDocument:(NSString *)document withHTMLScraper:(BGGHTMLScraper *)htmlScraper
{
	return [htmlScraper scrapeFullInfoFromDocument:document];
}

-(NSString *) cacheFileName
{
    return [NSString stringWithFormat:@"full-page-id_%d.html", gameId ];
}

#pragma mark Public

-(id) init
{
	if((self = [super initWithNibName:@"GameInfo" bundle:nil]) != nil)
	{
		pageNumber = 1;
	}
	return self;
}






@end
