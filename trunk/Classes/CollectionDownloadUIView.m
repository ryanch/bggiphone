//
//  CollectionDownloadUIView.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CollectionDownloadUIView.h"
#import "BGGAppDelegate.h"
#import "XmlSearchReader.h"
#import "DbAccess.h"
#import "FullGameInfo.h"

@implementation CollectionDownloadUIView


@synthesize  currentItemLabel;
@synthesize parentNav;
@synthesize progressView;
@synthesize cancelButton;
@synthesize directionsLabel;

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		isCanceled = NO;
		errorMessage = nil;
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	
	//cancelButton.title = NSLocalizedString( @"Cancel", @"Cancel button text" );
	directionsLabel.text = NSLocalizedString( @"In order to enable some features the games that you own need to be downloaded. Please wait.", @"directions for the download your collection page." );
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[NSThread detachNewThreadSelector:@selector(startLoading) toTarget:self withObject:nil];
	//[self startLoading];
}



- (void) startLoadingHelper {
	
	percentComplete = 0.1;
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	
	
	
	NSString * username = [appDelegate handleMissingUsername];
	if ( username == nil ) {
		return;
	}
	
	if ( ![appDelegate.dbAccess hasOwnedGamesCached] ) {
		XmlSearchReader * search = [[XmlSearchReader alloc] init];
		search.parseItemFormat = YES;
		
		
		NSString * urlStr = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi/collection/%@?own=1", username ];
		
		
		
		
		NSURL *url = [NSURL URLWithString: urlStr	];
		search.searchURL = url;
		
		NSError * error = nil;
		
		NSArray *results = [appDelegate getGameSearchResults:search	withError:&error searchGameType: BGG_SEARCH_OWNED];
		
		BOOL hadResults = YES;
		if ( results == nil ) {
			hadResults = NO;
		}

	

		if ( !hadResults ) {
			errorMessage = NSLocalizedString( @"No games were found as owned. Check your username- is it entered correctly? Do you you have games listed as owned? Also check your network connection.", @"error no games listed as owned, check your username" );
			return;
		}
	}
	
	
	if ( isCanceled ) {
		return;
	}
	
	
	NSInteger startCount  = [appDelegate.dbAccess fetchTotalMissingGameInfoFromCollection];
	
	if ( startCount == 0 ) {
		return;
	}
	
	// try to download al lgames
	FullGameInfo * gameInfo  = [appDelegate.dbAccess getNextMissingGameForCollection];
	while( gameInfo != nil && !isCanceled) {
		
		message = gameInfo.title;
		//[gameInfo release];
		gameInfo = nil;
		
		percentComplete = 1- (float)[appDelegate.dbAccess fetchTotalMissingGameInfoFromCollection] / (float)startCount;
		
		[self performSelectorOnMainThread:@selector(updateUser) withObject:self waitUntilDone:YES];	
		
		
		[NSThread sleepForTimeInterval:0.1];
		
		if ( !isCanceled ) {
			gameInfo = [appDelegate.dbAccess getNextMissingGameForCollection];
		}
	}
	
	
	//[gameInfo release];
	
	startCount  = [appDelegate.dbAccess fetchTotalMissingGameInfoFromCollection];
	
	// if start count is more than 0 and we didnt cancel then 
	// we were not able to download all of the games.
	if ( startCount > 0 && !isCanceled ) {
		errorMessage = NSLocalizedString( @"Not able to download all the games in your collecton. Check your username, and your network connection.", @"error no games listed as owned, check your username" );
	}
	
	
	
	
}	
	
- (void) startLoading {
	
		
	
	@autoreleasepool {
	
	// this is here to prevent a bug in the uinav controller
		[NSThread sleepForTimeInterval:1.0]; 
		
		[self startLoadingHelper];
	

	
	}
	
	[self performSelectorOnMainThread:@selector(allDone) withObject:self waitUntilDone:YES];	
	
	
}

- (void) updateUser {
	
	progressView.progress = percentComplete;
	
	 
	
	currentItemLabel.text = message;
}

- (void) allDone {
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if ( errorMessage != nil ) {
		
		
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error dialog title")
														message:errorMessage
													   delegate:self cancelButtonTitle: NSLocalizedString( @"OK", @"okay button") otherButtonTitles: nil];
		[alert show];	
		
		
		
		//[parentNav popViewControllerAnimated:YES];
		[parentNav popToRootViewControllerAnimated:YES];
	
		
		//[parentNav.view setNeedsDisplay];
		
		
	}
	else {
	
		[parentNav popViewControllerAnimated:YES];
	
	}
	
}

- (IBAction) cancelSync {
	isCanceled = YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}




@end
