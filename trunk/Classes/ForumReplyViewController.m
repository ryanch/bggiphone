//
//  ForumReplyViewController.m
//  BGG
//
//  Created by Christianson, Ryan on 2/22/13.
//
//

#import "ForumReplyViewController.h"
#import "BGGAppDelegate.h"
#import "BGGConnect.h"
#import "PlistSettings.h"


@interface ForumReplyViewController ()

@end

@implementation ForumReplyViewController


@synthesize messageId;
@synthesize subject;
@synthesize body;
@synthesize subjectTitle;
@synthesize actvityView;


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


- (void) viewWillAppear:(BOOL)animated {
    
    
    [self addSendButton];
    
    [self.subject setText:self.subjectTitle];
    
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated  {
    
    [body becomeFirstResponder];
    
    [super viewDidAppear:animated];
}


- (IBAction) send {
    //[self.navigationController popViewControllerAnimated:YES];
    
    //UIAlertView * alert = – initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:
    
    
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Discard" otherButtonTitles:@"Continue writing", @"Submit", nil ];
    
    [action showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ( buttonIndex == 0 ) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (buttonIndex == 2 ) {
        
        self.actvityView.hidden = NO;
        [self.body setEditable: NO];
        
        
        [NSThread detachNewThreadSelector:@selector(doSubmitReply) toTarget:self withObject:nil];
    }
}

- (void) doSubmitReply {

        //BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    
     
            
            BGGConnect * bggConnect = [[BGGConnect alloc] init];
            
            
            //bggConnect.username = [appDelegate.appSettings.dict objectForKey:@"username"];
            //bggConnect.password = [appDelegate.appSettings.dict objectForKey:@"password"];
    
            [bggConnect pullDefaultUsernameAndPassword];
    
    
    BGGConnectResponse response = [bggConnect postForumReply:self.messageId  withSubject:self.subject.text withBody: self.body.text];
    
   
            
            if ( response == SUCCESS ) {
                // no work todo
            }
            else if ( response == CONNECTION_ERROR ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Doing Forum Post", @"Error Doing Forum Post")
                                                                message:NSLocalizedString(@"Check your password, and network connection. I think the error is your network.", @"No data was returned when logged. Check your password, and network connection.")
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else if ( response == AUTH_ERROR ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Doing Forum Post", @"Error Doing Forum Post")
                                                                message:NSLocalizedString(@"Check your password, and network connection. I think the error is your password.", @"No data was returned when logged. Check your password, and network connection.")
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
			
            
            
            
            [self performSelectorOnMainThread:@selector(submitDone) withObject:self waitUntilDone:YES];
            
        

        
          
}

- (void) submitDone {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void) addSendButton {
	
	// see if we have reload button
	if ( self.navigationItem.rightBarButtonItem != nil ) {
		return;
	}
	
	UIBarButtonItem * button = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(send )];
    
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	
	
}




@end
