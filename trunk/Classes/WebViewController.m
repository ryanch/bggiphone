//
//  WebViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController


@synthesize webView;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	if ( startingURL != nil ) {
		//NSURL * url = [NSURL URLWithString:startingURL];
	
		//[webView loadRequest:[NSURLRequest requestWithURL: url]];
	
		NSString * html = [NSString stringWithFormat: @"<meta name=\"viewport\" content=\"initial-scale = 1.0; user-scalable=no; width=device-width;\"><center><b>Loading...</b></center><script>document.location = \"%@\";</script>", startingURL];
		
		[webView loadHTMLString:html  baseURL:nil ];
		
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) setURL: (NSString*) urlString {
	
	
	startingURL = urlString;
	[startingURL retain];

	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[startingURL release];
	[webView release];
    [super dealloc];
}


@end
