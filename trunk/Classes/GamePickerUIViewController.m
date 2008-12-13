//
//  GamePickerUIViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GamePickerUIViewController.h"
#import "BoardGameSearchResultsTableViewController.h"
#import "DbAccess.h"
#import "BGGAppDelegate.h"

@implementation GamePickerUIViewController

@synthesize gamePicker;
@synthesize showAllMatchesButton;
@synthesize shakeForRandomButton;

+(GamePickerUIViewController*) buildGamePickerUIViewController {
	

		GamePickerUIViewController * controller = [[GamePickerUIViewController alloc] initWithNibName:@"GamePicker" bundle:nil];
		controller.title = NSLocalizedString( @"Search Owned Game", @"Game Picker title" );
		[controller autorelease];
		return controller;
	
	
}


// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
		playersChoices = [NSArray arrayWithObjects:@"Any", @"1 player", @"2 Players", 
						  @"3 Players", @"4 Players", @"5 Players", @"6 Players", 
						  @"7 Players", @"8 Players", @"9 Players", @"10+ Players", nil];
		[playersChoices retain];
		
		
		timeChoices = [NSArray arrayWithObjects:@"Any", @"< 30 min", 
						  @"< 45 min",@"< 60 min",  @"< 90 min", @"< 120 min", @"< 150 min", nil];
		[timeChoices retain];
		
		weightChoices = [NSArray arrayWithObjects:@"Any", @"Light", 
					   @"Med. L.",@"Med",  @"Med. H.", @"Heavy", nil];
		[weightChoices retain];
		
    }
    return self;
}

- (NSInteger) valueFromPickerForComponent: (NSInteger) comp {
	NSInteger row = [gamePicker selectedRowInComponent:comp];
	
	if ( row == 0 ) {
		return -1;
	}
	
	// players
	if ( comp == 0 ) {

		return row;
		
	}
	// time
	else if ( comp == 1 ) {
		
		if ( row == 1 ) {
			return 30;
		}
		else if ( row == 2 ) {
			return 45;
		}	
		else if ( row == 3 ) {
			return 60;
		}				
		else if ( row == 4 ) {
			return 90;
		}	
		else if ( row == 5 ) {
			return 120;
		}	
		else if ( row == 6 ) {
			return 150;
		}		
		
	}
	
	
	//weight
	else if ( comp == 2 ) {
		
		return row;
		
	}
	
	// whoops
	return -1;
	
}



/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if ( component == 0 ) {
		return (NSString*) [playersChoices objectAtIndex:row];
	}
	else if ( component == 1) {
		return (NSString*) [timeChoices objectAtIndex:row];
	}
	else if ( component == 2) {
		return  (NSString*) [weightChoices objectAtIndex:row];
	}	
	return @"broken";
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if ( component == 0 ) {
		return [playersChoices count];
	}
	else if ( component == 1) {
		return [timeChoices count];
	}
	else if ( component == 2) {
		return [weightChoices count];
	}
	return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 3;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	UIImage *newImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage *newPressedImage = [[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	
	
	[shakeForRandomButton setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	[showAllMatchesButton setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	
	[shakeForRandomButton setBackgroundImage:newImage forState:UIControlStateNormal];
	[showAllMatchesButton setBackgroundImage:newImage forState:UIControlStateNormal];
	
	gamePicker.delegate = self;
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
	[ showAllMatchesButton release];
	[ shakeForRandomButton release];
	[playersChoices release];
	[timeChoices release];
	[weightChoices release];
	[gamePicker release];
    [super dealloc];
}


- (NSArray*) doSearch {
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	
	NSInteger playerCount = [self valueFromPickerForComponent: 0];
	NSInteger searchTime = [self valueFromPickerForComponent: 1];
	NSInteger searchWeight =  [self valueFromPickerForComponent: 2];
	
	
	
	
	NSArray * results = [appDelegate.dbAccess searchGamesOwnedPlayers: playerCount 
						 withWeight: searchWeight
						 withTime: searchTime];
	
	if ( results == nil || [results count] == 0  ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results", @"No results were found.")
														message:NSLocalizedString(@"No results were found.", @"No results were found.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
		return nil;
	}
	
	return results;
}

- (IBAction) showAllMachesClick {
	
	NSArray * results = [self doSearch];
	
	if ( results == nil ) {
		return;
	}	
	
	
	BoardGameSearchResultsTableViewController * resultsDisplay = [ [BoardGameSearchResultsTableViewController alloc] initWithStyle:UITableViewStylePlain ];
	resultsDisplay.resultsToDisplay = results;
	[resultsDisplay buildSectionTitlesForResults:results];
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate.navigationController pushViewController:resultsDisplay	animated:YES];
	
	
	[resultsDisplay release];
}


- (IBAction) pickRandom {
	NSArray * results = [self doSearch];
	
	if ( results == nil ) {
		return;
	}	
	
	NSInteger count = [results count];
	
	BBGSearchResult * result = nil;
	
	if (count == 1 ) {
		result = (BBGSearchResult*)[results objectAtIndex:0];
	}
	else {
		NSInteger index = RANDOM_INT( 0, [results count] -1 );
		result = (BBGSearchResult*)[results objectAtIndex:index];
	}
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate loadGameFromSearchResult: result];
	
}


@end
