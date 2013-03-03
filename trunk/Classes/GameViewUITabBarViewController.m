//
//  GameViewUITabBarViewController.m
//  BGG
//
//  Created by Christianson, Ryan on 3/3/13.
//
//

#import "GameViewUITabBarViewController.h"
#import "WebViewController.h"
#import "LogPlayUIViewController.h"

#import "FullGameInfo.h"
#import "BGGAppDelegate.h"
#import "CollectionItemEditViewController.h"
#import "GameActionsViewController.h"


@interface GameViewUITabBarViewController  ()

@end

@implementation GameViewUITabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) gameActionButtonPressed {
    
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"cancel") destructiveButtonTitle:nil otherButtonTitles:
                             NSLocalizedString(@"Record A Play", @"record a play"),
                             NSLocalizedString(@"Manage Collection", @"manage collection"),
                             NSLocalizedString(@"Rate This Game", @"rate this game"),
                             NSLocalizedString(@"View in Safari", @"View in Safari"),
                             nil ];
    
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        [self openRecordAPlay];
    }
    else if ( buttonIndex == 1 ) {
        [self openCollectionManager];
    }
    else if ( buttonIndex == 2 ) {
        [self openRatings];
    }
    else if ( buttonIndex == 3 ) {
        [self openGameInSafari];
    }

}

- (void) openRatings {
    BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ( ![appDelegate confirmUserNameAndPassAvailable]  ) {
        return;
    }
    
    if ( self.fullGameInfo == nil ){
        return;
    }
    
    GameActionsViewController * ratingsView = [[GameActionsViewController alloc] initWithNibName:@"GameActions" bundle:nil];
    
    ratingsView.fullGameInfo = self.fullGameInfo;
    ratingsView.title =self.fullGameInfo.title;
    
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:ratingsView];
    ratingsView.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:ratingsView action:@selector(doneButtonPressed)];
    
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nav animated:YES completion:nil  ];
    
    
    
    
}

- (void) openCollectionManager {
    
    BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ( ![appDelegate confirmUserNameAndPassAvailable]  ) {
        return;
    }
    
    
    CollectionItemEditViewController * col = [[CollectionItemEditViewController alloc] initWithNibName:@"CollectionItemEdit" bundle:nil];
    col.gameId = [self.fullGameInfo.gameId intValue];
    col.gameTitle = self.fullGameInfo.title;
    

    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:col];
    col.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:col action:@selector(doneButtonPressed)];
    
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0];
    //nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nav animated:YES completion:nil  ];
    


    
    
    
}

- (void) openGameInSafari {
	if ( self.fullGameInfo == nil ) {
		return;
	}
	
	
	NSString * gameId = self.fullGameInfo.gameId;
	NSString  * urlString = [NSString stringWithFormat:@"http://www.boardgamegeek.com/boardgame/%@", gameId ];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
    
    
	/*
	//[[UIApplication sharedApplication] openURL: [NSURL URLWithString:urlString] ];
	
	WebViewController * web = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	[web setURL:urlString];
	web.title = @"Browser";
	
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:web];
    web.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:web action:@selector(doneButtonPressed)];
    
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nav animated:YES completion:nil  ];
    
	
	//BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	//[self.navigationController pushViewController: web animated: YES];
	*/
	
	
	
}

- (void) openRecordAPlay {
	
	if ( self.fullGameInfo == nil ) {
		return;
	}
	
    BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ( ![appDelegate confirmUserNameAndPassAvailable]  ) {
        return;
    }
    
    
	//BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
    LogPlayUIViewController * logPlay = [[LogPlayUIViewController alloc] initWithNibName:@"RecordPlay" bundle:nil];
    logPlay.gameId = self.fullGameInfo.gameId;
    logPlay.title = NSLocalizedString( @"Log A Play", @"log a play button title" );
    
    
        
        
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:logPlay];
        logPlay.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:logPlay action:@selector(doneButtonPressed)];
        
        nav.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:nav animated:YES completion:nil  ];
        

	
}



@end
