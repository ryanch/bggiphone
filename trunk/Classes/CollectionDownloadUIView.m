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
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[NSThread detachNewThreadSelector:@selector(startLoading) toTarget:self withObject:nil];
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
		
		NSArray *results = [appDelegate initGameSearchResults:search	withError:&error isForOwnedGames:YES];
		
		BOOL hadResults = YES;
		if ( results == nil ) {
			hadResults = NO;
		}

		[results release];
		[search release];

		if ( !hadResults ) {
			errorMessage = NSLocalizedString( @"No games were found as owned. Check your username- is it entered correctly? Do you you have games listed as owned?", @"error no games listed as owned, check your username" );
			[errorMessage retain];
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
	FullGameInfo * gameInfo  = [appDelegate.dbAccess initNextMissingGameForCollection];
	while( gameInfo != nil && !isCanceled) {
		
		[message release];
		message = gameInfo.title;
		[message retain];
		[gameInfo release];
		gameInfo = nil;
		
		percentComplete = 1- (float)[appDelegate.dbAccess fetchTotalMissingGameInfoFromCollection] / (float)startCount;
		
		[self performSelectorOnMainThread:@selector(updateUser) withObject:self waitUntilDone:YES];	
		
		
		[NSThread sleepForTimeInterval:0.1];
		
		if ( !isCanceled ) {
			gameInfo = [appDelegate.dbAccess initNextMissingGameForCollection];
		}
	}
	
	
	[gameInfo release];
	
	
	
	
}	
	
- (void) startLoading {
	
		
	
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	
	
	[self startLoadingHelper];
	

	
	[autoreleasepool release];
	
	[self performSelectorOnMainThread:@selector(allDone) withObject:self waitUntilDone:YES];	
	
}

- (void) updateUser {
	
	progressView.progress = percentComplete;
	
	 
	
	currentItemLabel.text = message;
}

- (void) allDone {
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if ( errorMessage != nil ) {
		[NSThread sleepForTimeInterval:1.0]; 
		
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"No results were found.")
														message:errorMessage
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
		
		
		[parentNav popViewControllerAnimated:YES];
		
	
		
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[errorMessage release];
	[message	 release];
	[parentNav release];
	[currentItemLabel release];
	[progressView release];
	
    [super dealloc];
}


@end
