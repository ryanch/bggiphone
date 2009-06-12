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
//  GameActionsViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameActionsViewController.h"
#import "FullGameInfo.h"
#import "LogPlayUIViewController.h"
#import "BGGAppDelegate.h"
#import "SettingsUIViewController.h"
#import "PlistSettings.h"
#import "WebViewController.h"
#import "CollectionItemEditViewController.h"

@implementation GameActionsViewController

@synthesize fullGameInfo;
@synthesize logPlayButton;
@synthesize safariButton;



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
    [super viewDidLoad];
	
	// set the bg on the button
	UIImage *newImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[logPlayButton setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[logPlayButton setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	logPlayButton.backgroundColor = [UIColor clearColor];
	
	
	// set the bg on the button
	[safariButton setBackgroundImage:newImage forState:UIControlStateNormal];
	
	[safariButton setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	safariButton.backgroundColor = [UIColor clearColor];	
	
	// set the bg on the button
	[modifyButton setBackgroundImage:newImage forState:UIControlStateNormal];
	
	[modifyButton setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	modifyButton.backgroundColor = [UIColor clearColor];		
	
	
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
	[fullGameInfo release];
	[logPlayButton release];
	[safariButton release];
	[modifyButton release];
    [super dealloc];
}


- (IBAction) openGameInSafari {
	if ( fullGameInfo == nil ) {
		return;
	}
	
	
	NSString * gameId = fullGameInfo.gameId;
	NSString  * urlString = [NSString stringWithFormat:@"http://www.boardgamegeek.com/boardgame/%@", gameId ];

	
	//[[UIApplication sharedApplication] openURL: [NSURL URLWithString:urlString] ];
	
	WebViewController * web = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	[web setURL:urlString];
	web.title = @"Browser";
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate.navigationController pushViewController: web animated: YES];
	
	
	
	[web release];
	
}

- (IBAction) openRecordAPlay {
	
	if ( fullGameInfo == nil ) {
		return;
	}
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	LogPlayUIViewController * logPlay = [[LogPlayUIViewController alloc] initWithNibName:@"RecordPlay" bundle:nil];
	logPlay.gameId = fullGameInfo.gameId;
	logPlay.title = NSLocalizedString( @"Log A Play", @"log a play button title" );
	
	[appDelegate.navigationController pushViewController: logPlay animated: YES];
	
	[logPlay release];
}


- (IBAction) manageGameInCollection {
	
	if ( ![self confirmUserNameAndPassAvailable] ) {
		return;
	}
	
	CollectionItemEditViewController * col = [[CollectionItemEditViewController alloc] initWithNibName:@"CollectionItemEdit" bundle:nil];
	col.gameId = [fullGameInfo.gameId intValue];
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate.navigationController pushViewController: col animated: YES];
	
	[col release];
	
	
}


- (BOOL) confirmUserNameAndPassAvailable {
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSString * username = [appDelegate.appSettings.dict objectForKey:@"username"];
	NSString * password = [appDelegate.appSettings.dict objectForKey:@"password"];
	
	if ( username == nil || [username length] == 0 || password == nil || [password length] == 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Need Username and Password", @"ask user to provide username and pass title")
														message:NSLocalizedString(@"Please enter your username and password to modify your collection.", @"please give your username and password to modify your collection.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
		
		
		SettingsUIViewController * settings = [SettingsUIViewController buildSettingsUIViewController];
		
		[appDelegate.navigationController pushViewController:settings		animated:YES];
		
		return NO;
	}
	
	return YES;
	
}

@end
