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
                             NSLocalizedString(@"View in Safari", @"View in Safari"),
                             nil ];
    
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        [self openRecordAPlay];
    }
    else if ( buttonIndex == 1 ) {
        [self openGameInSafari];
    }

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
