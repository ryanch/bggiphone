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
//  GameInfoViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameInfoViewController.h"
#import "FullGameInfo.h"
#import "BBGSearchResult.h"
#import "BGGAppDelegate.h"


@implementation GameInfoViewController

@synthesize webView;
@synthesize loadingView;
@synthesize gameInfo;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


- (NSString *) trimToDecimal: (NSString *) value {
	float floatValue = [value floatValue];
	return [NSString stringWithFormat:@"%1.2f", floatValue];
}

- (void) updateForGameStats: (FullGameInfo*) newGameInfo {
	
	displayMode = STATS_MODE;
	
	self.gameInfo = newGameInfo;
	
	
	// create a new html file for the game
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * tempFilePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"../tmp/h/%@_stats.html", gameInfo.gameId] ];

	
	//NSString * tempFilePath = [NSString stringWithFormat:@"%@/tmp/%@.html", [ [NSBundle mainBundle] resourcePath ], gameInfo.gameId];
	
	//NSString * tempFilePath = [NSString stringWithFormat:@"%@/%@.html",NSTemporaryDirectory(),gameInfo.gameId];
	
	NSMutableString *stringBuffer = [[NSMutableString alloc] initWithCapacity:10*1024];
	[stringBuffer appendString:@"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0; user-scalable=no; width=device-width;\">"];
	[stringBuffer appendString:@"<style>* {font-family: helvetica;} .sttitle { font-weight: bold; text-align: right;} </style></head><body>"];
	

	[stringBuffer appendString:@"<p  align=\"center\"  ><b style=\"font-size: 1.1em;\">"];
	[stringBuffer appendString:gameInfo.title];
	[stringBuffer appendString:@" "];
	[stringBuffer appendString:NSLocalizedString(@"Game Statistics",@"game statistics title for stats page") ];
	[stringBuffer appendString:@"</b></p><table>"];
	
	
	// rank
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Rank:",@"rank label for a game") ];
	[stringBuffer appendString:@"</td><td>"];
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.rank] ];
	[stringBuffer appendString:@"</td><tr>"];
		
	// average
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Average Rating:",@"Average Rating label for a game") ];
	[stringBuffer appendString:@"</td><td>"];
	
	[stringBuffer appendString: [NSString stringWithFormat:@"%@", [self trimToDecimal: gameInfo.average] ] ];
	[stringBuffer appendString:@"</td><tr>"];		
	
	// bayesaverage
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Bayesian Average:",@"Bayesian Average label for a game") ];
	[stringBuffer appendString:@"</td><td>"];
	
	
	[stringBuffer appendString: [NSString stringWithFormat:@"%@", [self trimToDecimal:gameInfo.bayesaverage ] ] ];
	[stringBuffer appendString:@"</td><tr>"];	
	
	// usersrated
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Users Rated:",@"Users Rated: label for a game, as in the number of users that rated it") ];
	[stringBuffer appendString:@"</td><td>"];
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.usersrated] ];
	[stringBuffer appendString:@"</td><tr>"];
	
	// averageweight
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Average Weight:",@"Average Weight: label for a game") ];
	[stringBuffer appendString:@"</td><td>"];
	[stringBuffer appendString: [NSString stringWithFormat:@"%@", [self trimToDecimal:gameInfo.averageweight] ] ];
	[stringBuffer appendString:@"</td><tr>"];		
	
	// numweights
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Number of Weights:",@"Number of Weights: label for a game") ];
	[stringBuffer appendString:@"</td><td>"];	
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.numweights] ];
	[stringBuffer appendString:@"</td><tr>"];	
	
	// owned
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Copies Owned:",@"Copies Owned: label for a game") ];
	[stringBuffer appendString:@"</td><td>"];		
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.owned] ];
	[stringBuffer appendString:@"</td><tr>"];	

	// trading
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Copies For Trade:",@"Copies For Trade: label for a game") ];
	[stringBuffer appendString:@"</td><td>"];		
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.trading] ];
	[stringBuffer appendString:@"</td><tr>"];		
	
	// wanting
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Copies Wanted:",@"Copies Wanted: label for a game") ];
	[stringBuffer appendString:@"</td><td>"];		
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.wanting] ];
	[stringBuffer appendString:@"</td><tr>"];		
	
	// wishing
	[stringBuffer appendString:@"<tr><td class=\"sttitle\">"];
	[stringBuffer appendString:NSLocalizedString(@"Copies Wished For:",@"Copies Wished For: label for a game") ];
	[stringBuffer appendString:@"</td><td>"];		
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.wishing] ];
	[stringBuffer appendString:@"</td><tr>"];		
	
	
	[stringBuffer appendString:@"</table>"];
	

	
	
	
	[stringBuffer appendString:@"</table>"];
	[stringBuffer appendString:@"</html></body>"];
	
	
	//NSLog( tempFilePath );
	//NSLog( stringBuffer );
	
	
	
	
	// write to file
	[stringBuffer writeToFile:tempFilePath	atomically:YES encoding:  NSUTF8StringEncoding error: nil];
	[stringBuffer release];
	
	
	// hide and show
	[loadingView stopAnimating];
	loadingView.hidden = YES;
	webView.hidden = NO;
	
	
	
	// set the web view to load it
	NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL fileURLWithPath: tempFilePath  ] ];
	//NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://google.com"  ] ];
	[self.webView loadRequest: url ];
	[url autorelease];
	
}

- (void) updateForGameInfo: (FullGameInfo*) newGameInfo {
	
	displayMode = INFO_MODE;
	
	self.gameInfo = newGameInfo;
	
	
	// create a new html file for the game
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * tempFilePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"../tmp/h/%@.html", gameInfo.gameId] ];
	 
	
	//NSString * tempFilePath = [NSString stringWithFormat:@"%@/tmp/%@.html", [ [NSBundle mainBundle] resourcePath ], gameInfo.gameId];
	 
	//NSString * tempFilePath = [NSString stringWithFormat:@"%@/%@.html",NSTemporaryDirectory(),gameInfo.gameId];
	
	NSMutableString *stringBuffer = [[NSMutableString alloc] initWithCapacity:10*1024];
	[stringBuffer appendString:@"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0; user-scalable=no; width=device-width;\">"];
	[stringBuffer appendString:@"<style>* {font-family: helvetica;} </style></head><body>"];
	
	
	[stringBuffer appendString:@"<div align=\"center\"><b>"];
	[stringBuffer appendString:NSLocalizedString(@"Rank:", @"rank label for a game")];
	[stringBuffer appendString:@"</b> "];
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.rank] ];
	
	[stringBuffer appendString:@" <b>"];
	[stringBuffer appendString:NSLocalizedString(@"Players:", @"players label for a game")];
	[stringBuffer appendString:@"</b> "];
	[stringBuffer appendString: [NSString stringWithFormat:@"%d-%d", gameInfo.minPlayers, gameInfo.maxPlayers] ];
	
	
	[stringBuffer appendString:@" <b>"];
	[stringBuffer appendString:NSLocalizedString(@"Time:", @"time label for a game")];
	[stringBuffer appendString:@"</b> "];
	[stringBuffer appendString: [NSString stringWithFormat:@"%d", gameInfo.playingTime] ];
	[stringBuffer appendString:@" "];
	[stringBuffer appendString:NSLocalizedString(@"min", @"minutes abbreviation")];
	
	[stringBuffer appendString:@"</div>"];
	
	[stringBuffer appendString:@"<img src=\""];
	//[stringBuffer appendString:gameInfo.imageURL];
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSString * gameImagePath = [appDelegate buildImageFilePathForGameId:gameInfo.gameId];
	NSURL * imageURL = [NSURL fileURLWithPath:gameImagePath];
	[stringBuffer appendString: [imageURL absoluteString] ];
	
	[stringBuffer appendString:@"\" align=\"left\"  />"];
	
	[stringBuffer appendString:@"<p>"];
	[stringBuffer appendString:gameInfo.desc];
	[stringBuffer appendString:@"</p>"];
	[stringBuffer appendString:@"</html></body>"];
	
	
	//NSLog( tempFilePath );
	//NSLog( stringBuffer );
	
	
	
	
	// write to file
	[stringBuffer writeToFile:tempFilePath	atomically:YES encoding:  NSUTF8StringEncoding error: nil];
	[stringBuffer release];
	
	
	// hide and show
	[loadingView stopAnimating];
	loadingView.hidden = YES;
	webView.hidden = NO;
	

	
	// set the web view to load it
	NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL fileURLWithPath: tempFilePath  ] ];
	//NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://google.com"  ] ];
	[self.webView loadRequest: url ];
	[url autorelease];
	

	
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	

	
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {

		NSURL * url = [request URL];
		NSString * path = [url path];
		
		NSString * gamesPrefix = @"/game/";
		
		if ( [path hasPrefix:gamesPrefix] ) {
			
			NSString * gameId = [path substringFromIndex: [gamesPrefix length] ];
			
			BBGSearchResult * result = [[BBGSearchResult alloc] init];
			result.primaryTitle = NSLocalizedString( @"Loading...", @"loading text, as in content is loading" );
			result.gameId = gameId;
			[result autorelease];
			
			BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
			[appDelegate loadGameFromSearchResult:result];
			
			return NO;
		}
		
		
        
    }

	return YES;
	
	
}




// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {

	if ( gameInfo == nil ) {
		webView.hidden = YES;
		[loadingView startAnimating];
		loadingView.hidden = NO;
	}
	else {
		if ( displayMode == STATS_MODE ) {
			[self updateForGameStats: gameInfo];
		}
		else if (displayMode == INFO_MODE)  {
			[self updateForGameInfo: gameInfo];
		}
	}
	 
	
	webView.delegate = self;
	
    [super viewDidLoad];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[gameInfo release];
	[loadingView release];
	[webView release];
    [super dealloc];
}


@end
