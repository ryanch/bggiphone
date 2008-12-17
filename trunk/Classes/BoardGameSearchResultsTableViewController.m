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
//  BoardGameSearchResultsTableViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BoardGameSearchResultsTableViewController.h"
#import "BBGSearchResult.h"
#import "XmlSearchReader.h"
#import "BGGAppDelegate.h"
#import "GameInfoViewController.h"
#import "GameActionsViewController.h"
#import "FullGameInfo.h"
#import	 "XmlGameInfoReader.h"
#import "DownloadGameInfoOperation.h"
#import "DbAccess.h"

@implementation BoardGameSearchResultsTableViewController

@synthesize resultsToDisplay;
@synthesize currentSearch;
@synthesize searchGameType;


- (void) userRequestedReload {
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSString * username = [appDelegate handleMissingUsername];
	if ( username == nil ) {
		return;
	}
	
	
	
	// dump current results
	[resultsToDisplay release];
	resultsToDisplay = nil;
	
	// reload the table
	[self.tableView reloadData];
	
	// see what type of search it is, if its something
	// we cache, then clear it from db

	NSInteger listId = 0;
	if ( searchGameType == BGG_SEARCH_OWNED ) {
		listId = LIST_TYPE_OWN;
	}
	else if ( searchGameType == BGG_SEARCH_WISH ) {
		listId = LIST_TYPE_WISH;
	}
	
	if ( listId != 0 ) {
		[appDelegate.dbAccess removeAllGamesInList: listId forUser: username];
	}
		
	XmlSearchReader* newSearch = [self.currentSearch initCopyForReload];
	
	
	[self doSearch:newSearch];
	
}

- (void) addReloadResultsButton {
	
	// see if we have reload button
	if ( self.navigationItem.rightBarButtonItem != nil ) {
		return;
	}
	
	UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] 
									  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(userRequestedReload)];

	[self.navigationItem setRightBarButtonItem:refreshButton animated:YES];
	
	[refreshButton release];
	
	
}
									   
// this is called when we should start a search
- (void) doSearch: (XmlSearchReader*) search {
	[parseErrorMessage release];
	parseErrorMessage = nil;
	[currentSearch release];
	currentSearch = nil;
	self.currentSearch = search;
	
	//[self thrSearch];
	[NSThread detachNewThreadSelector:@selector(thrSearch) toTarget:self withObject:nil];
}

// this is called by the thread
- (void) thrSearch {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	
	[resultsToDisplay release];
	resultsToDisplay = nil;
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSError * parseError = nil;
	resultsToDisplay = [appDelegate initGameSearchResults: currentSearch withError: &parseError searchGameType: searchGameType];
	if ( resultsToDisplay == nil ) {
		parseErrorMessage = [[parseError localizedDescription] retain];
		[NSThread sleepForTimeInterval:1.0]; 
	}
	
	
	/*
	// see if we can  use the ownded games cache
	if ( searchingOwnedGames == YES ) {
		self.resultsToDisplay = [appDelegate.dbAccess findGamesOwned];
	}
	
	// check the cache
	if (resultsToDisplay == nil) {
		

	
		NSError * parseError = nil;
		
		
		BOOL success = [currentSearch parseXMLAtSearchURLWithError:&parseError]; 
		

		
		if ( success &&  currentSearch.searchResults != nil && [ currentSearch.searchResults count ] > 0 ) {
			self.resultsToDisplay = currentSearch.searchResults;
			
			// update ownership
			if ( searchingOwnedGames == YES ) {
				for ( NSInteger i = 0; i < [self.resultsToDisplay count]; i++ ) {
					BBGSearchResult * result = (BBGSearchResult*) [self.resultsToDisplay objectAtIndex:i];
					[appDelegate.dbAccess saveGameAsOwnedGameId:[result.gameId intValue] title:result.primaryTitle];
				}
			}
			
		}
		
		if ( success ) {
			if ( [resultsToDisplay count] == 0 ) {

				
					// wait one second for cpu to settle from error
					[NSThread sleepForTimeInterval:1.0];
			}
		}
		else {
			parseErrorMessage = [[parseError localizedDescription] retain];
			//[parseError release];
			
			// wait one second to let the cpu settle from the error
			[NSThread sleepForTimeInterval:1.0];

			
		}
		
		
		
	}
	 */
	
	
	[self buildSectionTitlesForResults:resultsToDisplay];

	

	
	
	[self performSelectorOnMainThread:@selector(doneSearch) withObject:self waitUntilDone:YES];
	
	

	[autoreleasepool release];
	
	//[self doneSearch];
	
}

- (void) buildSectionTitlesForResults:(NSArray*)results {
		
	
	if (results == nil || [results count] == 0 ) {
		return;
	}
	
	NSMutableArray * array = [ [NSMutableArray alloc] initWithCapacity:100];
	sectionTitles = array;
	
	sectionCountsDict =  [ [NSMutableDictionary alloc] initWithCapacity:100];
	
	NSInteger total = [results count];
	for( NSInteger i = 0; i< total; i++ ) {
		BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:i];
		if ( [result.primaryTitle length] == 0 ) {
			continue;
		}
		
		NSString * firstLetter = [ [result.primaryTitle substringToIndex:1] uppercaseString];
		
		
		NSMutableArray * titles = (NSMutableArray*) [sectionCountsDict objectForKey:firstLetter];
		
		if ( titles == nil ) {
			[array addObject:firstLetter];
			
			titles = [[NSMutableArray alloc] initWithCapacity:10];
			
			
			[sectionCountsDict setValue: titles forKey:firstLetter];
			[titles release];
			
			
		}
		
		[titles addObject:result];
		
		
		
	}
	
	
	
	
	
	
	
}


// this is called by the thread when done
- (void) doneSearch {
	
	if ( parseErrorMessage != nil ) {

	
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Fetching Data", @"error fetching data title error message")
															message:[NSString stringWithFormat: NSLocalizedString(@"Error parsing XML data. Check your username is correct. BGG could be down. Error message: %@", @"error message for bad xml parsing. The error will be placed where you put the %@"), parseErrorMessage ]
														   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"okay button") otherButtonTitles: nil];
			[alert show];	
			[alert release];		
			
		
		BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
		[appDelegate.navigationController popToRootViewControllerAnimated:YES];
		
			
	}
	else if ( resultsToDisplay == nil || [resultsToDisplay count] == 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results", @"no results title message")
														message:NSLocalizedString(@"There are no results for that list.",@"message shown when there are no games in a list that the user was looking up") 
													   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"okay button")  otherButtonTitles: nil];
		[alert show];	
		[alert release];		
		
		
		BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
		[appDelegate.navigationController popToRootViewControllerAnimated:YES];
	}
	else {
	
	
		[self.tableView reloadData];
		
		
	}
	
	[self addReloadResultsButton];
}




- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		resultsToDisplay = nil;
		
		
		sectionTitles = nil;
		
		sectionCountsDict = nil;
		
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view.
/*
- (void)viewDidLoad {
    [super viewDidLoad];
}
 */



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ( resultsToDisplay == nil || sectionTitles == nil ) {
		return 1;
	}
	
	return [sectionTitles count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {

	
	return sectionTitles;
}


/*
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

	NSInteger totalCount = [sectionTitles count];
	
	for( NSInteger i = 0; i < totalCount; i++ ) {
		NSString * sectionTitle = (NSString*) [sectionTitles objectAtIndex:i];
		if ( [title hasPrefix:sectionTitle] ) {
			return i;
		}
	}
	
	return 0;
	
	
}
 */


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	
	if ( resultsToDisplay == nil || sectionTitles == nil ) {
		return 1;
	}
	
	NSString * firstLetter	= (NSString*) [sectionTitles objectAtIndex:section];
	
	NSMutableArray * titles = (NSMutableArray*) [sectionCountsDict objectForKey:firstLetter];
	

	if ( titles == nil ) {
		return 0;
	}
	else {
		return [titles count];
	}
	
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if ( sectionTitles == nil ) {
		return nil;
	}
	
	return (NSString*) [sectionTitles objectAtIndex:section];
}








/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
 */

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ( resultsToDisplay == nil ) {
		return 1;
	}
    return [resultsToDisplay count];
}
 */


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if ( resultsToDisplay == nil ) {
		UIViewController * loadingCell = [[UIViewController alloc] initWithNibName:@"LoadingCell" bundle:nil];
		
		UITableViewCell * cell = (UITableViewCell*) loadingCell.view;
		[cell retain];
		[cell autorelease];
		
		[loadingCell release];
		
		return cell;
		
	}
	
	
#ifdef __DEBUGGING__
	NSLog( @"cellForRowAtIndexPath row: %d", indexPath.row );
#endif
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell
	//BBGSearchResult * result = (BBGSearchResult*) [resultsToDisplay objectAtIndex: indexPath.row];
	
	NSString * sectionTitle = (NSString*) [ sectionTitles objectAtIndex: indexPath.section];
	NSArray * results = (NSArray*) [ sectionCountsDict objectForKey:sectionTitle];
	BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:indexPath.row];
	
	
	cell.text = result.primaryTitle;
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSString * imagePath = [appDelegate buildImageThumbFilePathForGameId:result.gameId];
	if ( [[NSFileManager defaultManager] fileExistsAtPath:imagePath] ) {
		cell.image = [UIImage imageWithContentsOfFile: imagePath];
	}
	else {
		cell.image = nil;
	}
	
	
    return cell;
}


- (void) loadGameFromSearchResult: (BBGSearchResult*) searchResult {
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[appDelegate loadGameFromSearchResult: searchResult];
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
		
	
	//BBGSearchResult * result = (BBGSearchResult*) [resultsToDisplay objectAtIndex: indexPath.row];
	
	NSString * sectionTitle = (NSString*) [ sectionTitles objectAtIndex: indexPath.section];
	NSArray * results = (NSArray*) [ sectionCountsDict objectForKey:sectionTitle];
	BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:indexPath.row];
	
	
	[self loadGameFromSearchResult: result];
	


	
}


/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self setupAccelRandomPicker];	
}



- (void)viewWillDisappear:(BOOL)animated {
	[[UIAccelerometer sharedAccelerometer] setDelegate: nil];	
	[super viewWillDisappear:animated];
}


/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
	[sectionCountsDict release];
	[sectionTitles release];
	[parseErrorMessage release];
	[currentSearch release];
	[resultsToDisplay release];
    [super dealloc];
}



// Called when the accelerometer detects motion; random player select
- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	UIAccelerationValue				length,
	x,
	y,
	z;
	
	//Use a basic high-pass filter to remove the influence of the gravity
	myAccelerometer[0] = acceleration.x * kFilteringFactor + myAccelerometer[0] * (1.0 - kFilteringFactor);
	myAccelerometer[1] = acceleration.y * kFilteringFactor + myAccelerometer[1] * (1.0 - kFilteringFactor);
	myAccelerometer[2] = acceleration.z * kFilteringFactor + myAccelerometer[2] * (1.0 - kFilteringFactor);
	// Compute values for the three axes of the acceleromater
	x = acceleration.x - myAccelerometer[0];
	y = acceleration.y - myAccelerometer[0];
	z = acceleration.z - myAccelerometer[0];
	
	//Compute the intensity of the current acceleration 
	length = sqrt(x * x + y * y + z * z);
	// If above a given threshold, play the erase sounds and erase the drawing view
	if((length >= kEraseAccelerationThreshold) && (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)) {
		//[erasingSound play];
		//[drawingView erase];
		
		[self appWasShook];
		
		
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}


- (void) appWasShook {
	
	if ( [[UIAccelerometer sharedAccelerometer] delegate ] == nil ) {
		return;
	}
	
	
	[[UIAccelerometer sharedAccelerometer] setDelegate: nil];
	
	if ( resultsToDisplay == nil ) {
		return;
	}
	NSInteger totalCount = [resultsToDisplay count];
	if ( totalCount == 0 ) {
		return;
	}
	
	NSInteger index = RANDOM_INT(0,totalCount);
	
	BBGSearchResult * result = [resultsToDisplay objectAtIndex: index ];
	
	[self loadGameFromSearchResult: result];
}


- (void) setupAccelRandomPicker {
	//Configure and enable the accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate: self];	
}


@end

