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
@synthesize directionsLabel;

+(GamePickerUIViewController*) buildGamePickerUIViewController {
	

		GamePickerUIViewController * controller = [[GamePickerUIViewController alloc] initWithNibName:@"GamePicker" bundle:nil];
		controller.title = NSLocalizedString( @"Search Owned Game", @"Game Picker title" );
		//[controller autorelease];
		return controller;
	
	
}


// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
	
		playersChoices = [NSArray arrayWithObjects: 
						  NSLocalizedString( @"Any", "any number of players for game search" ), 
						   NSLocalizedString( @"1 Player", "1 player game search" ),
						   NSLocalizedString( @"2 Player", "2 player game search" ), 
						   NSLocalizedString( @"3 Player", "3 player game search" ), 
						   NSLocalizedString( @"4 Player", "4 player game search" ), 
						   NSLocalizedString( @"5 Player", "5 player game search" ), 
						   NSLocalizedString( @"6 Player", "6 player game search" ), 
						   NSLocalizedString( @"7 Player", "7 player game search" ), 
						   NSLocalizedString( @"8 Player", "8 player game search" ), 
						   NSLocalizedString( @"9 Player", "9 player game search" ), 
						   NSLocalizedString( @"10+ Player", "10+ player game search" ), 
						   nil];
		
		
		timeChoices = [NSArray arrayWithObjects:
						NSLocalizedString( @"Any", "any ammount of time game search" ), 
					   NSLocalizedString( @"< 30 min", "less than 30 min game search" ), 
					   NSLocalizedString( @"< 60 min", "less than 60 min game search" ), 
					   NSLocalizedString( @"< 90 min", "less than 90 min game search" ), 
					   NSLocalizedString( @"< 120 min", "less than 120 min game search" ), 
					   NSLocalizedString( @"< 150 min", "less than 150 min game search" ), 
					   nil];
		
		weightChoices = [NSArray arrayWithObjects:
						 NSLocalizedString( @"Any", "any ammount of time game weight" ), 
						 NSLocalizedString( @"Light", "light ammount of time game weight" ), 
						 NSLocalizedString( @"Med. L.", "medium light ammount of time game weight" ), 
						 NSLocalizedString( @"Med", "medium ammount of time game weight" ), 
						 NSLocalizedString( @"Med. H.", "Med. Heavy ammount of time game weight" ), 
						 NSLocalizedString( @"Heavy", "Heavy ammount of time game weight" )
						 , nil];
		
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
	
	
	//shakeForRandomButton.text = NSLocalizedString(@"Pick Random",@"pick a random result button text" );
	//showAllMatchesButton.text = NSLocalizedString(@"Show All Matches",@"show all games that match button text" );
	directionsLabel.text = NSLocalizedString( @"Use this control to find a game in your collection given the critieria that you select.", @"directions for for the collection game search" );
	
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
													   delegate:self cancelButtonTitle:NSLocalizedString( @"OK", @"okay button title") otherButtonTitles: nil];
		[alert show];	
		
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
