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
#import "Top100ImageDownloadOperation.h"

@implementation BoardGameSearchResultsTableViewController

@synthesize resultsToDisplay;
@synthesize currentSearch;
@synthesize searchGameType;
@synthesize currentResumeState;


- (void) userRequestedReload {
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSString * username = [appDelegate handleMissingUsername];
	if ( username == nil ) {
		return;
	}
	
	// dump current results
	resultsToDisplay = nil;
	sectionTitles = nil;
	sectionCountsDict = nil;
	
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
	
}
									   
// this is called when we should start a search
- (void) doSearch: (XmlSearchReader*) search {
	parseErrorMessage = nil;
	currentSearch = nil;
	self.currentSearch = search;
	
	//[self thrSearch];
	[NSThread detachNewThreadSelector:@selector(thrSearch) toTarget:self withObject:nil];
}

// this is called by the thread
- (void) thrSearch {
	@autoreleasepool {
	
	
		resultsToDisplay = nil;
		
		BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
		
		NSError * parseError = nil;
		resultsToDisplay = [appDelegate getGameSearchResults: currentSearch withError: &parseError searchGameType: searchGameType];

		if ( resultsToDisplay == nil ) {
			parseErrorMessage = [parseError localizedDescription];
			[NSThread sleepForTimeInterval:1.0]; 
		}
		
		
		
		[self buildSectionTitlesForResults:resultsToDisplay];

		
		[self performSelectorOnMainThread:@selector(doneSearch) withObject:self waitUntilDone:YES];
	
	}
	
}


NSString* _scubTitleForSort( NSString* title ) {
	title = [title uppercaseString];
	NSRange range = [title rangeOfString:@"THE "];
	if ( range.location != NSNotFound && range.location == 0 ) {
		title = [title  substringFromIndex: range.length];
	}
	return title;
}

// this is the sort method
NSInteger gameSort(id obj1, id obj2, void *context) {
	
	
	BBGSearchResult * result1 = (BBGSearchResult*)obj1;
	BBGSearchResult * result2 = (BBGSearchResult*)obj2;
	
	NSString * title1 = _scubTitleForSort(result1.primaryTitle);
	NSString * title2 = _scubTitleForSort(result2.primaryTitle);
	

	return [title1 compare: title2];
	
	
}

- (void) buildSectionTitlesForResults:(NSArray*)results {
		
	
	if (results == nil || [results count] == 0 ) {
		return;
	}
	
	
	// sort the results first
	results = [results sortedArrayUsingFunction:gameSort context:NULL];
	
	NSMutableArray * array = [ [NSMutableArray alloc] initWithCapacity:100];
	sectionTitles = array;
	
	sectionCountsDict =  [ [NSMutableDictionary alloc] initWithCapacity:100];
	
	NSInteger total = [results count];
	for( NSInteger i = 0; i< total; i++ ) {
		BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:i];
		if ( [result.primaryTitle length] == 0 ) {
			continue;
		}
		
		//NSString * firstLetter = [ [result.primaryTitle substringToIndex:1] uppercaseString];

		NSString * sortTitle = _scubTitleForSort(result.primaryTitle);
		
	
		NSString * 	firstLetter = [sortTitle substringToIndex:1];
		
		
		
		NSMutableArray * titles = (NSMutableArray*) [sectionCountsDict objectForKey:firstLetter];
		
		if ( titles == nil ) {
			[array addObject:firstLetter];
			
			titles = [[NSMutableArray alloc] initWithCapacity:10];
			
			
			[sectionCountsDict setValue: titles forKey:firstLetter];
			
			
		}
		
		[titles addObject:result];
		
		
		
	}
	
	
	if ( [sectionTitles count] == 0 ) {
		sectionTitles = nil;
	}
	
	
	
	
}


// this is called by the thread when done
- (void) doneSearch {
	
    [pathByGameId removeAllObjects];
    
	if ( parseErrorMessage != nil ) {

	
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Fetching Data", @"error fetching data title error message")
															message:[NSString stringWithFormat: NSLocalizedString(@"Error parsing XML data. Check your username is correct. BGG could be down. Error message: %@", @"error message for bad xml parsing. The error will be placed where you put the %@"), parseErrorMessage ]
														   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"okay button") otherButtonTitles: nil];
			[alert show];	
			
		
		BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
		[appDelegate.navigationController popToRootViewControllerAnimated:YES];
		
			
	}
	else if ( resultsToDisplay == nil || [resultsToDisplay count] == 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results", @"no results title message")
														message:NSLocalizedString(@"There are no results for that list.",@"message shown when there are no games in a list that the user was looking up") 
													   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"okay button")  otherButtonTitles: nil];
		[alert show];	
		
		
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

- (BBGSearchResult*) findResultForPath: (NSIndexPath *) indexPath {
    
    if ( resultsToDisplay == nil ) {
        return nil;
    }
    
	NSString * sectionTitle = (NSString*) [ sectionTitles objectAtIndex: indexPath.section];
	NSArray * results = (NSArray*) [ sectionCountsDict objectForKey:sectionTitle];
	BBGSearchResult * result = (BBGSearchResult*) [results objectAtIndex:indexPath.row];
    
    [pathByGameId setObject:indexPath forKey:result.gameId];
    
    return result;

}


-(void) updateCell:(UITableViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBGSearchResult * result = [self findResultForPath:indexPath];
    if (result == nil) {
        return;
    }
    
	cell.textLabel.text = result.primaryTitle;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.minimumFontSize = 12.0;
	cell.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	
	if ( result.yearPublished == 0 ) {
		cell.detailTextLabel.text = @"";
		
	}
	else {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"Published: %d", result.yearPublished];
	}
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSString * imagePath = [appDelegate buildImageThumbFilePathForGameId:result.gameId];
	if (imagePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:imagePath] ) {
		cell.imageView.image = [UIImage imageWithContentsOfFile: imagePath];
	}
	else {
        [self startLoadingImageForResult:result];
		cell.imageView.image = [UIImage imageNamed:@"loading.jpg"];
	}
    
}

- (NSIndexPath*) findPathforResult: (BBGSearchResult*) result {
    
    
    return [ pathByGameId objectForKey:result.gameId];
    
}


-(void) nsOperationDidFinishLoadingResult:(BBGSearchResult *)result
{
    
    // dont remove, we only want to try to load each once.
	// [imagesLoading removeObject:result.gameId];
    
	NSIndexPath * indexPath = [self findPathforResult:result];
    if ( indexPath == nil) {
        return;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [self updateCell:cell forItemAtIndexPath:indexPath];
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBGSearchResult * result = [self findResultForPath:indexPath];

    
    // if no results then show the loading cell
	if ( result == nil ) {
		UIViewController * loadingCell = [[UIViewController alloc] initWithNibName:@"LoadingCell" bundle:nil];
		
		UITableViewCell * cell = (UITableViewCell*) loadingCell.view;
		return cell;
	}
	
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell =  [[UITableViewCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    

    [self updateCell:cell forItemAtIndexPath:indexPath];
	

	
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

-(void) startLoadingImageForResult:(BBGSearchResult *)result
{
	if(result.gameId == nil) {
		return;
    }
	
	if([imagesLoading containsObject:result.gameId]) {
		return;
    }
    
	[imagesLoading addObject:result.gameId];
	
	Top100ImageDownloadOperation * operation = [[Top100ImageDownloadOperation alloc] initWithResult:result forSearchView:self];
	
	[imageDownloadQueue addOperation:operation];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self setupAccelRandomPicker];	
	
    
	imagesLoading = [[NSMutableSet alloc] init];
	imageDownloadQueue = [[NSOperationQueue alloc] init];
	[imageDownloadQueue setMaxConcurrentOperationCount:2];
    
    pathByGameId = [[NSMutableDictionary alloc] initWithCapacity:1000];
    
	//NSLog(@"show");
	
	// save the current state
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate saveResumePoint:currentResumeState withString:nil];
	
}



- (void)viewWillDisappear:(BOOL)animated {
	//[[UIAccelerometer sharedAccelerometer] setDelegate: nil];	
	[super viewWillDisappear:animated];
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
	//[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	//[[UIAccelerometer sharedAccelerometer] setDelegate: self];	
}


@end

