//
//  CommentsUIViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CommentsUIViewController.h"
#import "GameCommentsXmlParser.h"


@implementation CommentsUIViewController

@synthesize webView;
@synthesize loadingView;
@synthesize gameId;


- (id) init
{
	self = [super init];
	if (self != nil) {
		pageIsLoaded = NO;
		workingOnLoading = NO;
	}
	return self;
}

// this method is done in a thread
-(void) startLoadingPage {
	
	@autoreleasepool {
	
	
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		pageToLoad = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"../tmp/h/%@_comment.html", gameId] ];
		
		NSFileManager * filemanager = [NSFileManager defaultManager];
		if ( ![filemanager fileExistsAtPath:pageToLoad] ) {
			
			GameCommentsXmlParser *comments  = [[GameCommentsXmlParser alloc] init];
			comments.writeToPath = pageToLoad;
			
			NSError *error;
			
			NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.boardgamegeek.com/xmlapi/boardgame/%@?comments=1", gameId]   ];
			
			BOOL success = [comments parseXMLAtURL:url parseError:&error];
			
			if ( !success ) {
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Loading Comments", @"Error Loading comments dialog title")
																message:NSLocalizedString(@"There was an error loading comments for this game. Check that you have a network connection.", @"error loading comments message" )
															   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"okay button") otherButtonTitles: nil];
				[alert show];	
				
				
				NSLog( @"error loading comments: %@", [error localizedDescription] );
			}
			
		}
	
	

	
	}
	
	// this is done to update the ui
	[self performSelectorOnMainThread:@selector(loadComplete) withObject:self waitUntilDone:YES];	
}	

-(void) loadComplete {
	
	
	// set the web view to load it
	//NSURLRequest * url = [[NSURLRequest alloc] initWithURL: [NSURL fileURLWithPath: pageToLoad  ] ];
	//[webView loadRequest: url ];
	//[url autorelease];
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
	NSError *error = nil;
	NSString * fileContents = [NSString stringWithContentsOfFile:pageToLoad encoding:NSUTF8StringEncoding error:&error];
	if(fileContents == nil)
	{
		NSLog(@"ERROR: Couldn't load file at path '%@' because of error '%@'.", pageToLoad, [error localizedDescription]);
		return;
	}
	
	[webView loadHTMLString:fileContents baseURL:  baseURL   ];	
	
	webView.hidden = NO;
	loadingView.hidden = YES;
	pageIsLoaded = YES;
}


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	
	if ( pageIsLoaded ) {
		[self loadComplete];
	}
	else {
		webView.hidden = YES;
		[loadingView startAnimating];
		loadingView.hidden = NO;
		
		if ( workingOnLoading == NO ) {
			workingOnLoading = YES;
			//[self startLoadingPage];
			[NSThread detachNewThreadSelector:@selector(startLoadingPage) toTarget:self withObject:nil];
		}
		
	}

	
	
	//webView.delegate = self;
	
    [super viewDidLoad];
}




@end
