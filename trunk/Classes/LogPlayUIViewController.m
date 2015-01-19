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

@interface LogPlayUIViewController () <UITextFieldDelegate>

@end

@implementation LogPlayUIViewController


@synthesize playCountController;
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
- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}


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
		
	// update the date on the date control
	//[datePicker setDate:[NSDate date] animated: YES];

	[self performSelector:@selector(updatePicker) withObject:nil afterDelay:0.1];
	
	
	playCount = 1;
    
    self.commentText.layer.borderWidth = 1.0;
    self.commentText.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.commentText.layer.cornerRadius = 5;
    
    self.locationText.layer.borderWidth = 1.0;
    self.locationText.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.locationText.layer.cornerRadius = 5;
    
    //self.location.delegate = self;
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize frameSize = self.scrollView.frame.size;
    
    // On an IPad, there is a large margin at the top.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(-80.0, 0.0, 0.0, 0.0);
        self.scrollView.contentInset = contentInsets;
    }

    // For some reason, the inset is needed for smaller screens so the date picker is not
    // under the navigation bar.
    else if (frameSize.height < 450)
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(80.0, 0.0, 0.0, 0.0);
        self.scrollView.contentInset = contentInsets;
    }
    
    CGSize contSize = self.myControl.frame.size;
    contSize.height -= self.scrollView.contentInset.top;
    [self.scrollView setContentSize:contSize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
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
		
        BGGConnectResponse response = [bggConnect simpleLogPlayForGameId:[gameId intValue]
                                                                 forDate:datePicker.date
                                                                numPlays:playCount
                                                                location:self.locationText.text
                                                                comments:self.commentText.text];
		
		if ( response == SUCCESS ) {
			/*
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success Play logged title")
															message:NSLocalizedString(@"Your play was logged.", @"Your play was logged")
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];		
			 */
			
			self.playLogLabel.hidden = NO;
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
}

- (void) logPlayComplete {
	loadingView.hidden = YES;
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
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
	
	loadingView.hidden = NO;
	self.playLogLabel.hidden = YES;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbEndSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    
    if (kbSize.height == 0)
    {
        return;
    }
    
    if (self.kbScrolled != 0)
    {
        [self keyboardWillBeHidden:aNotification];
    }
    
    self.kbScrolled = kbEndSize.height;
    
    CGRect aRect = self.myControl.frame;
    aRect.size.height -= self.kbScrolled;
   
    UIEdgeInsets contentInsets = self.scrollView.contentInset;
    contentInsets.bottom += self.kbScrolled;
    self.scrollView.contentInset = contentInsets;
    
    UIEdgeInsets indInsets = self.scrollView.scrollIndicatorInsets;
    indInsets.bottom += self.kbScrolled;
    self.scrollView.scrollIndicatorInsets = indInsets;

    if (!CGRectContainsPoint(aRect, self.commentText.frame.origin) )
    {
        [self.scrollView scrollRectToVisible:self.commentText.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = self.scrollView.contentInset;
    contentInsets.bottom -= self.kbScrolled;
    self.scrollView.contentInset = contentInsets;

    UIEdgeInsets indInsets = self.scrollView.scrollIndicatorInsets;
    indInsets.bottom -= self.kbScrolled;
    self.scrollView.scrollIndicatorInsets = indInsets;
    
    self.kbScrolled = 0;
}

@end
