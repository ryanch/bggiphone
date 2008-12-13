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
//  SearchUIViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SearchUIViewController.h"
#import	"BoardGameSearchResultsTableViewController.h"
#import "BGGAppDelegate.h"
#import "XmlSearchReader.h"
#import "DbAccess.h"
#import "Beacon.h"

@implementation SearchUIViewController

@synthesize searchBar;

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




// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	[searchBar becomeFirstResponder];
	
	
    [super viewDidLoad];
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {

	
	 [[Beacon shared] startSubBeaconWithName:@"search click" timeSession:NO];
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	BoardGameSearchResultsTableViewController * resultsViewer = [[BoardGameSearchResultsTableViewController alloc]  initWithStyle:UITableViewStylePlain];
	
	

	resultsViewer.title = NSLocalizedString(@"Search Results" , @"search results title" );


	[appDelegate.navigationController pushViewController:resultsViewer		animated:YES];
	
	XmlSearchReader * search = [[XmlSearchReader alloc] init];
	search.parseItemFormat = NO;
	
	
	NSString * searchText = [BGGAppDelegate urlEncode: self.searchBar.text];
	
	
	
	NSString * urlStr = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi/search?search=%@", searchText ];

	
	NSURL *url = [NSURL URLWithString: urlStr	];
	search.searchURL = url;
	[resultsViewer doSearch: search];
	
	[search release];
	[resultsViewer release];		
	
	
	
	
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
	[searchBar release];
    [super dealloc];
}

+ (SearchUIViewController*) buildSearchUIViewController {
	SearchUIViewController * controller = [[SearchUIViewController alloc] initWithNibName:@"Search" bundle:nil];
	controller.title = NSLocalizedString( @"Search", @"search title" );
	[controller autorelease];
	return controller;
}


@end
