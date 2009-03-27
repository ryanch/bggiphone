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
#import "HtmlTemplate.h"


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

	
	// generate contents from template
	
	NSString * template = [ NSString stringWithFormat:@"%@/stats_template.html", [ [NSBundle mainBundle] bundlePath]  ];
	HtmlTemplate * gameTemplate = [[HtmlTemplate alloc] initWithFileName:template];
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithCapacity:20];
	
	[params setObject: gameInfo.title forKey:@"#!gameTitle#"];
	
	[params setObject: [NSString stringWithFormat:@"%d", gameInfo.rank] forKey:@"#!rank#"];
	

	float avgRatingFloatValue = [gameInfo.average floatValue];
	NSString * avgRating = [NSString stringWithFormat:@"%1.2f", avgRatingFloatValue];	
	[params setObject: avgRating	forKey: @"#!avgRating#" ];
	
	
	
	[params setObject:  [self trimToDecimal:gameInfo.bayesaverage ]  forKey:@"#!bayAvg#"];
	
	[params setObject: [NSString stringWithFormat:@"%d", gameInfo.usersrated] forKey:@"#!usersRated#"];
	
	[params setObject: [self trimToDecimal:gameInfo.averageweight] forKey:@"#!avgWeight#"];
	
	[params setObject: [NSString stringWithFormat:@"%d", gameInfo.numweights] forKey:@"#!numWeights#"];

	[params setObject: [NSString stringWithFormat:@"%d", gameInfo.owned] forKey:@"#!copiesOwned#"];
	
	[params setObject: [NSString stringWithFormat:@"%d", gameInfo.trading] forKey:@"#!copiesForTrade#"];
	
	[params setObject: [NSString stringWithFormat:@"%d", gameInfo.wanting] forKey:@"#!copiesWanted#"];
	
	[params setObject: [NSString stringWithFormat:@"%d", gameInfo.wishing] forKey:@"#!copiesWishedFor#"];
	
	
	
	// Merge the template
	NSString * pageText = [gameTemplate allocMergeWithData:params];
	[gameTemplate release];

	[pageText writeToFile:tempFilePath	atomically:YES encoding:  NSUTF8StringEncoding error: nil];
	[pageText release];
	
	// hide and show
	[loadingView stopAnimating];
	loadingView.hidden = YES;
	webView.hidden = NO;
	
	
	
	// set the web view to load it
	//NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL fileURLWithPath: tempFilePath  ] ];
	//NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://google.com"  ] ];
	//[self.webView loadRequest: url ];
	//[url autorelease];
	
	
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
	
	
	NSString * fileContents = [NSString stringWithContentsOfFile:tempFilePath];
	
	
	[webView loadHTMLString:fileContents baseURL:  baseURL   ];	
	
	[params release];
	
}

- (void) updateForGameInfo: (FullGameInfo*) newGameInfo {
	
	displayMode = INFO_MODE;
	
	self.gameInfo = newGameInfo;
	
	
	// create a new html file for the game
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * tempFilePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"../tmp/h/%@.html", gameInfo.gameId] ];
	 
	NSString * template = [ NSString stringWithFormat:@"%@/game_template.html", [ [NSBundle mainBundle] bundlePath]  ];
	HtmlTemplate * gameTemplate = [[HtmlTemplate alloc] initWithFileName:template];
	
	NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithCapacity:20];
	
	[params setObject: gameInfo.title forKey:@"#!title#"];
	
	[params setObject: [NSString stringWithFormat:@"%d", gameInfo.rank] forKey:@"#!rank#"];
	
	NSString * players = [NSString stringWithFormat:@"%d-%d",gameInfo.minPlayers,gameInfo.maxPlayers];
	[params setObject:players forKey:@"#!players#"];
	
	NSString * gameTime = [NSString stringWithFormat:@"%d min",gameInfo.playingTime];
	[params setObject: gameTime	forKey: @"#!time#" ];
	

	
	float avgRatingFloatValue = [gameInfo.average floatValue];
	NSString * avgRating = [NSString stringWithFormat:@"%1.2f", avgRatingFloatValue];
	
	[params setObject: avgRating	forKey: @"#!rating#" ];
	
	NSString * star = @"star_yellow.gif";
	NSString * halfStar = @"star_yellowhalf.gif";
	NSString * noStar = @"star_white.gif";
	
	NSMutableString * starBuffer = [[NSMutableString alloc] initWithCapacity:200];

	for ( float i = 0; i < 10; i++ ) {
		if ( avgRatingFloatValue > 1+i ) {
			[starBuffer appendString: [NSString stringWithFormat:@"<img src=\"%@\">", star] ];
		}       
		else if ( avgRatingFloatValue > 0.2 + i ) {
			[starBuffer appendString: [NSString stringWithFormat:@"<img src=\"%@\">", halfStar] ];        
		}
		else {
			[starBuffer appendString: [NSString stringWithFormat:@"<img src=\"%@\">", noStar] ];  
		}
	}
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSString * gameImagePath = [appDelegate buildImageFilePathForGameId:gameInfo.gameId];
	
	NSString * imageTag = nil;
	if ( gameImagePath != nil ) {
        
		/*
		[stringBuffer appendString:@"<img src=\""];
		//[stringBuffer appendString:gameInfo.imageURL];
		
		
		
		
		NSURL * imageURL = [NSURL fileURLWithPath:gameImagePath];
		[stringBuffer appendString: [imageURL absoluteString] ];
		
		[stringBuffer appendString:@"\" align=\"left\"  />"];
		*/
		
		imageTag = [NSString stringWithFormat: @"<img src=\"%@\" align=\"left\" class=\"image\"  />",gameImagePath];
 
		
	}
	else {
			imageTag = @"";
	}
	[params setObject: imageTag	forKey: @"#!gameImage#" ];
	
	[params setObject: starBuffer	forKey: @"#!stars#" ];
	[starBuffer release];
	
	
	// stringByReplacingOccurrencesOfString:withString:
	
	NSString * desc = [ gameInfo.desc stringByReplacingOccurrencesOfString: @"\n" withString: @"<p/>" ];
	
	[params setObject: desc	forKey: @"#!gameBody#" ];
	
	// Merge the template
	NSString * pageText = [gameTemplate allocMergeWithData:params];
	[gameTemplate release];
	
	
	[pageText writeToFile:tempFilePath	atomically:YES encoding:  NSUTF8StringEncoding error: nil];
	[pageText release];
	

	
	// hide and show
	[loadingView stopAnimating];
	loadingView.hidden = YES;
	webView.hidden = NO;
	

	
	// set the web view to load it
	//NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL fileURLWithPath: tempFilePath  ] ];
	//NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://google.com"  ] ];
	//[self.webView loadRequest: url ];
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
	

	NSString * fileContents = [NSString stringWithContentsOfFile:tempFilePath];
	

	[webView loadHTMLString:fileContents baseURL:  baseURL   ];
	

	[params release];
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
