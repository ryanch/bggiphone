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
//  LogPlayUIViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LogPlayUIViewController.h"
#import "FullGameInfo.h"
#import "BGGAppDelegate.h"
#import "PlistSettings.h"
#import "SettingsUIViewController.h"
//#import "Beacon.h"
#import "BGGConnect.h"
#import "PostWorker.h"

@implementation LogPlayUIViewController


@synthesize playCountController;
@synthesize logPlayButton;
@synthesize datePicker;
@synthesize gameId;
@synthesize loadingView;


/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
	[super loadView];
}


- (void) updatePicker {
	[datePicker setDate:[NSDate date] animated:YES];

}


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// set the bg on the button
	UIImage *newImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[logPlayButton setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[logPlayButton setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	logPlayButton.backgroundColor = [UIColor clearColor];
	
	// update the date on the date control
	//[datePicker setDate:[NSDate date] animated: YES];

	[self performSelector:@selector(updatePicker) withObject:nil afterDelay:0.1];
	
	
	playCount = 1;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void) doLogPlay {
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	@autoreleasepool {

		BGGConnect * bggConnect = [[BGGConnect alloc] init];
		

		bggConnect.username = [appDelegate.appSettings.dict objectForKey:@"username"];
		bggConnect.password = [appDelegate.appSettings.dict objectForKey:@"password"];
		
		BGGConnectResponse response = [bggConnect simpleLogPlayForGameId: [gameId intValue] forDate: datePicker.date numPlays: playCount ];
		
		if ( response == SUCCESS ) {
			/*
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success Play logged title")
															message:NSLocalizedString(@"Your play was logged.", @"Your play was logged")
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];		
			 */
			
			playLogLabel.hidden = NO;
			
		}
		else if ( response == CONNECTION_ERROR ) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging Play", @"Error Logging Play title")
															message:NSLocalizedString(@"Check your password, and network connection. I think the error is your network.", @"No data was returned when logged. Check your password, and network connection.")
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
		}
		else if ( response == AUTH_ERROR ) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging Play", @"Error Logging Play title")
															message:NSLocalizedString(@"Check your password, and network connection. I think the error is your password.", @"No data was returned when logged. Check your password, and network connection.")
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
		}

			
		
		
		
		[self performSelectorOnMainThread:@selector(logPlayComplete) withObject:self waitUntilDone:YES];
	
	}
	
	
	/*
	 
	 NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	 
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd"];
	NSString * datePlayedStr = [dateFormatter stringFromDate:datePicker.date];
	[dateFormatter release];
	 
	NSString * username = [appDelegate.appSettings.dict objectForKey:@"username"];
	NSString * password = [appDelegate.appSettings.dict objectForKey:@"password"];
	
	
	NSString * gotoURL = [NSString 
						 stringWithFormat:	@"http://www.boardgamegeek.com/geekplay.php?ajax=1&action=save&version=2&objecttype=boardgame&objectid=%@&playid=&action=save&playdate=%@&dateinput=%@&YUIButton=&location=&quantity=%d&length=&incomplete=0&nowinstats=0&comments=",
						 gameId, //game id
						 datePlayedStr, //date played
						 datePlayedStr, //date played
						 playCount // num of plays
						 ];
	

	
	NSString * logURL = [NSString stringWithFormat:@"http://www.boardgamegeek.com/login?&username=%@&password=%@&lasturl=%@", 
						 [BGGAppDelegate urlEncode:  username],
						 [BGGAppDelegate urlEncode:  password],
						 [BGGAppDelegate urlEncode:  gotoURL]];

	
	
#ifdef __DEBUGGING__
	NSLog( @"sending to: %@", logURL );
#endif
	
	
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:logURL]];
	

	NSError *error = nil;
	NSHTTPURLResponse *response = nil;
	BOOL looksGood = YES;
	
	NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	

	if ( result != nil ) {
		
		NSString * responseBody = [[NSString alloc] initWithData:result encoding:  NSASCIIStringEncoding];
		
#ifdef __DEBUGGING__		
		NSLog( responseBody );
#endif		
		
		if ( [responseBody length] > 300 ) {
			looksGood = NO;
		}
		
		
		[responseBody release];

	}
	 
	 
	 
	 if ( looksGood == NO ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging Play", @"Error Logging Play title")
														message:NSLocalizedString(@"Check your password, and network connection.", @"No data was returned when logged. Check your password, and network connection.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
	}
	else if ( result== nil || [response statusCode] != 200 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging Play", @"Error Logging Play title")
														message:NSLocalizedString(@"No data was returned when logged. Check your password, and network connection.", @"No data was returned when logged. Check your password, and network connection.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
	}
	else if ( error != nil ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging Play", @"Error Logging Play title")
														message:[error localizedDescription]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success Play logged title")
														message:NSLocalizedString(@"Your play was logged.", @"Your play was logged")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
	}
	 
	 
	 
	
	//[self logPlayComplete];
	[self performSelectorOnMainThread:@selector(logPlayComplete) withObject:self waitUntilDone:YES];
	
	[autoreleasepool release];
	 
	 */
}

- (void) logPlayComplete {
	logPlayButton.hidden = NO;
	loadingView.hidden = YES;
}


- (BOOL) confirmUserNameAndPassAvailable {
	
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	return [appDelegate confirmUserNameAndPassAvailable];
	
	
	
}

- (IBAction) logPlayClicked {
	
	if ( loadingView.hidden  == NO ) {
		return;
	}
	
	if ( gameId == nil ) {
		return;
	}
	
	if ( ![self confirmUserNameAndPassAvailable] ) {
		return;
	}
	
	logPlayButton.hidden = YES;
	loadingView.hidden = NO;
	
#ifdef PINCH_ENABLED
	 [[Beacon shared] startSubBeaconWithName:@"log play click" timeSession:NO];
#endif
	
	[NSThread detachNewThreadSelector:@selector(doLogPlay) toTarget:self withObject:nil];
	//[self doLogPlay];
	
}

- (IBAction) addPlayCount {
	
	if ( loadingView.hidden  == NO ) {
		return;
	}
	
	
	if ( playCountController.selectedSegmentIndex == 0 ) {
		playCount++;
	}
	else if ( playCountController.selectedSegmentIndex == 2 ) {
		playCount--;
	}
	
	if (playCount < 1 ) {
		playCount = 1;
	}
	
	[playCountController setTitle:[NSString stringWithFormat:@"Plays: %d",playCount] forSegmentAtIndex: 1];
	
}

- (void) doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
