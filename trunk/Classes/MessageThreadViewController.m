/*
 Copyright 2010 Petteri Kamppuri
 
 Licensed under the Apache License, Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed under the 
 License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
 either express or implied. See the License for the specific 
 language governing permissions and limitations under the License. 
 */ 

//
//  MessageThreadViewController.m
//  BGG
//
//  Created by Petteri Kamppuri on 3.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "MessageThreadViewController.h"
#import "BGGThread.h"
#import "BGGMessage.h"
#import "BGGHTMLScraper.h"
#import "HtmlTemplate.h"
#import "ForumReplyViewController.h"
#import "BGGConnect.h"
#import "SettingsUIViewController.h"

@implementation MessageThreadViewController

@synthesize webView;
@synthesize loadingView;
@synthesize thread;


#pragma mark LoadingViewController overrides

-(void) updateViews
{
    
    webView.delegate = self;
    
	if ( items == nil )
	{
		webView.hidden = YES;
		[loadingView startAnimating];
		loadingView.hidden = NO;
        
	}
	else
	{
		NSString *templateFilePath = [NSString stringWithFormat:@"%@/thread_messages_template.html", [[NSBundle mainBundle] bundlePath]];
		
		NSMutableString *messagesHTML = [NSMutableString stringWithCapacity:3000];
		
		for(BGGMessage *message in items)
		{
			// TODO: Make a separate template for a single message
			
			[messagesHTML appendString:@"<div class=\"message\">"];
			
			[messagesHTML appendString:@"<div class=\"header\">"];
			[messagesHTML appendString:@"<span class=\"username\">"];
			if(message.username)
				[messagesHTML appendString:message.username];
			[messagesHTML appendString:@"</span>"];
			[messagesHTML appendString:@" (<span class=\"nickname\">"];
			if(message.nickname)
				[messagesHTML appendString:message.nickname];
			[messagesHTML appendString:@"</span>)<br>"];
            
            

            
            
			[messagesHTML appendString:@"<span class=\"postdate\">"];
			if(message.postDate)
				[messagesHTML appendString:message.postDate];
			[messagesHTML appendString:@"</span>"];
            

            
            
			[messagesHTML appendString:@"</div>"];
			
			[messagesHTML appendString:@"<div class=\"content\">"];
			if(message.contents)
				[messagesHTML appendString:message.contents];
			[messagesHTML appendString:@"</div>"];
            
            
            // add reply link
            [messagesHTML appendString:@"&#160;<a href=\"bggapp://reply/"];
            [messagesHTML appendString: message.messageId ];
            [messagesHTML appendString:@"\" class=\"replylink\" >Reply</a>"];
			
			[messagesHTML appendString:@"</div>"];
		}
		
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		
		[params setObject:self.thread.title forKey:@"#!title#"];
		[params setObject:messagesHTML forKey:@"#!messages#"];
		
		HtmlTemplate *messagesTemplate = [[HtmlTemplate alloc] initWithFileName:templateFilePath];
		
		NSString * pageHTML = [messagesTemplate allocMergeWithData:params];
		//[pageHTML autorelease]; // Against Cocoa conventions...
		
		
		[loadingView stopAnimating];
		loadingView.hidden = YES;
		webView.hidden = NO;
		
		
		// set the web view to load it
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSURL *baseURL = [NSURL fileURLWithPath:path];
		
		[webView loadHTMLString:pageHTML baseURL:baseURL];
	}
}


- (void) userWantsNextPage {
    
    MessageThreadViewController * more = [[MessageThreadViewController alloc] init];
    more.thread = self.thread;
    more.pageNumber = self.pageNumber + 1;
    
    [self.navigationController pushViewController:more animated:YES];
    
    
}

-(NSString *) urlStringForLoading
{
	NSString * url =  [@"http://www.boardgamegeek.com" stringByAppendingString:self.thread.threadURL];
    return [url stringByAppendingFormat:@"/page/%d", pageNumber ];
}

-(id) resultsFromDocument:(NSString *)document withHTMLScraper:(BGGHTMLScraper *)htmlScraper
{
	return [htmlScraper scrapeMessagesFromThread:document];
}

-(NSString *) cacheFileName
{
	if(self.thread == nil)
		return nil;
	
	return [NSString stringWithFormat:@"thread-%@-page-%d.cache.html", self.thread.threadId, self.pageNumber];
}

#pragma mark Public

-(id) init
{
	if((self = [super initWithNibName:@"GameInfo" bundle:nil]) != nil)
	{
		pageNumber = 1;
	}
	return self;
}



# pragma mark UIWebViewDelegate delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSURL * url = [request URL];
    NSString * prefix = @"bggapp";
    if ( [url.scheme hasPrefix:prefix] ) {
        
        BGGConnect * bggConnect = [[BGGConnect alloc] init];
        if ( ![bggConnect pullDefaultUsernameAndPassword]) {
            
            
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error dialog title")
                                                            message:NSLocalizedString(@"You must provide your username and password.", @"shown when username and password missing")
                                                           delegate:self cancelButtonTitle: NSLocalizedString( @"OK", @"okay button") otherButtonTitles: nil];
            [alert show];
            
            SettingsUIViewController * settings = [SettingsUIViewController buildSettingsUIViewController];
            
            [self.navigationController pushViewController:settings		animated:YES];
            */
            //[bggConnect confirmUserNameAndPassAvailable];
            
            BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate confirmUserNameAndPassAvailable];
             
            
        }
        else {
        
            // todo pull the id out.
            ForumReplyViewController * view = [[ForumReplyViewController alloc] initWithNibName:@"ForumReply" bundle:nil];
            view.messageId = [url lastPathComponent];
            view.subjectTitle = self.title;
            view.title = NSLocalizedString(@"Reply", @"reply title");
            [self.navigationController pushViewController:view animated:YES];
            return YES;
            
        }
        
    } // end if clicked on url

    return YES;
}



@end
