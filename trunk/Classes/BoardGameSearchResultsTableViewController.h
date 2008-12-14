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
//  BoardGameSearchResultsTableViewController.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGGAppDelegate.h"

#define kAccelerometerFrequency			25 //Hz
#define kFilteringFactor				0.1
#define kMinEraseInterval				1.0
#define kEraseAccelerationThreshold		2.0


@class BBGSearchResult;
@class XmlSearchReader;

///
/// this view is used to show a list of board games
///
@interface BoardGameSearchResultsTableViewController : UITableViewController <UIAccelerometerDelegate> {
	
	//! the games to display, this are BBGSearchResult objects
	NSArray * resultsToDisplay;
	
	//! this is the search that was used to get this list
	XmlSearchReader * currentSearch;
	
	//! this is the error message from a failed search
	NSString * parseErrorMessage;
	
	//! this is the type of search that are listing for
	BGGSearchGameType searchGameType;
	
	//! this is a list of titles used for the sections in the table view
	NSArray * sectionTitles;
	
	//! this dict tracks how many games are in each section
	NSDictionary * sectionCountsDict;
	
	//! this holds accelerometer data
	UIAccelerationValue	myAccelerometer[3];
	
	//! this holds the time since the last accell
	CFTimeInterval		lastTime;
}

//! start the search, show the animated loading icon, and call thrSearch
- (void) doSearch: (XmlSearchReader*) search;

//! this is called from a worker thread, this will do call the search method on the delegate, and when done, call doneSearch on the main thread
- (void) thrSearch;

//! either show the error from trying to load, or reload the table with the new data
- (void) doneSearch;

//! this calls the app delegate method with the same name
- (void) loadGameFromSearchResult: (BBGSearchResult*) searchResult;

//! this rebuilds the sectionTitles and sectionCountsDict based on the results passed in
- (void) buildSectionTitlesForResults:(NSArray*)results;
 
//! this is called when the results are loaded, and we want the user to be able to reload the results if they want
- (void) addReloadResultsButton;

//! this is called when the user clicks the reload button
- (void) userRequestedReload;

//! setup accel detect
- (void) setupAccelRandomPicker;

//! this is called when a shake is detected
- (void) appWasShook;

@property BGGSearchGameType searchGameType;

@property (nonatomic, retain ) NSArray * resultsToDisplay;

@property (nonatomic, retain ) XmlSearchReader * currentSearch;




@end
