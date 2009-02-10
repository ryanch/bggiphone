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
#import "BBGSearchResult.h"

@implementation SearchUIViewController

@synthesize searchBar;
@synthesize tableView;

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

- (NSInteger)tableView:(UITableView *)tableViewActed numberOfRowsInSection:(NSInteger)section {
	if ( localDbSearchResults == nil ) {
		return 0;
	}
	else {
		return [localDbSearchResults count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableViewActed cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ( localDbSearchResults == nil ||  [localDbSearchResults count] == 0 ) {
		return nil;
	}

	
    static NSString *CellIdentifier = @"gameCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }	
	
	BBGSearchResult * result = (BBGSearchResult*) [localDbSearchResults objectAtIndex: indexPath.row];
	if ( result == nil ) {
		return nil;
	}
	
	cell.text = result.primaryTitle;
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSString * imagePath = [appDelegate buildImageThumbFilePathForGameId:result.gameId];
	if (imagePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:imagePath] ) {
		cell.image = [UIImage imageWithContentsOfFile: imagePath];
	}
	else {
		cell.image = nil;
	}
	
	return cell;
	
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ( localDbSearchResults == nil ||  [localDbSearchResults count] == 0 ) {
		return;
	}
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	BBGSearchResult * result = (BBGSearchResult*) [localDbSearchResults objectAtIndex:indexPath.row];
	
	
	[appDelegate loadGameFromSearchResult: result];
	
	
	
	
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

	
	BGGAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	
	
	// dump the current results
	[localDbSearchResults release];
	localDbSearchResults = nil;
	
	
	
	// do the local search
	NSArray* results = [appDelegate.dbAccess localDbSearchByName: searchText];
	
	// see if we have new results
	if ( results != nil ) {
		localDbSearchResults = results;
		[localDbSearchResults retain];
	}
	
	
	// reload no matter what - otherwise we could show matches that dont match
	[tableView reloadData];


	
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
	[localDbSearchResults release];
	[searchBar release];
	[tableView release];
    [super dealloc];
}

+ (SearchUIViewController*) buildSearchUIViewController {
	SearchUIViewController * controller = [[SearchUIViewController alloc] initWithNibName:@"Search" bundle:nil];
	controller.title = NSLocalizedString( @"Search", @"search title" );
	[controller autorelease];
	return controller;
}


@end
