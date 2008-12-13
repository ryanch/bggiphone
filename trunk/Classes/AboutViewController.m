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
//  AboutViewController.m
//  NoPeanut
//
//  Created by RYAN CHRISTIANSON on 10/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "Beacon.h"

@implementation AboutViewController

@synthesize webView;
@synthesize pageToLoad;

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

/*
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSString *host = [request URL].host;
	
	if ( [host isEqualToString: @"phobos.apple.com"] ) {
		
		
		
		return NO;
	}
	
	
	return YES;
}
 */

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	if ( [ [request.URL host] hasPrefix:@"phobos"] ) {
		[[Beacon shared] startSubBeaconWithName:@"about page phobos click" timeSession:NO];
	}
	
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	
	
	
	NSString *path = [[NSBundle mainBundle] pathForResource:pageToLoad ofType:@"html"];
	
	NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL fileURLWithPath: path  ] ];
	
	self.webView.delegate = self;
	[self.webView loadRequest: url ];
	
    [super viewDidLoad];
	
	
	[[Beacon shared] startSubBeaconWithName:@"about page" timeSession:NO];
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
	[pageToLoad release];
	[webView release];
    [super dealloc];
}


@end
