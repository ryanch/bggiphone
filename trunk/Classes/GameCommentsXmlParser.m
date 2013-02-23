//
//  GameCommentsXmlParser.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameCommentsXmlParser.h"
#import "BGGAppDelegate.h"
#import	"PlistSettings.h"
#import "HtmlTemplate.h"

#define MAX_COMMENTS 50

@implementation GameCommentsXmlParser

@synthesize writeToPath;

- (BOOL)parseXMLAtURL:(NSURL *)URL parseError:(NSError **)error {
	

	currentUserComments = [[NSMutableString alloc] initWithCapacity:10*1024];
	
	otherUserComments = [[NSMutableString alloc] initWithCapacity:25*1024];	
	
	commentCount = 0;
	
	
	
	inCommentTag = NO;
	
	stringBuffer = [NSMutableString string];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    BOOL success = [parser parse];
    
    if (!success) {
		if ( error != nil ) {
			*error =  [parser parserError];
		}
    }
    else {
	
		
		NSString * template = [ NSString stringWithFormat:@"%@/comment_template.html", [ [NSBundle mainBundle] bundlePath]  ];
		HtmlTemplate * commentsTemplate = [[HtmlTemplate alloc] initWithFileName:template];			   
	
		NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithCapacity:20];
		
		[params setObject: currentUserComments forKey:@"#!currentUserComments#"];
		[params setObject: otherUserComments forKey:@"#!otherComments#"];		
		
		NSString * pageText = [commentsTemplate allocMergeWithData:params];
		

		
		currentUserComments = nil;	
		
		otherUserComments = nil;		
		
	
		success =[pageText writeToFile:writeToPath	atomically:YES encoding:NSUTF8StringEncoding error:nil];
		

	
	}	
	
	
	
	pageBuffer = nil;
		
	return success;
	
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	

	
	inCommentTag = NO;
	
	if (qName) {
        elementName = qName;
    }
	
	if ( [elementName isEqualToString:@"comment"] ) {
		

		
		
		
		author = (NSString*) [attributeDict objectForKey:@"username"];
		inCommentTag = YES;
		[stringBuffer setString:@""];
	}
	
	
} // end start element method


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	

	
	if ( inCommentTag ) {
		[stringBuffer appendString:string];
	}

}
 

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
	

	
	if (qName) {
        elementName = qName;
    }
	

		if ( [elementName isEqualToString:@"comment"] ) {
			
			NSString *comments  = [ [NSString alloc] initWithString: stringBuffer]; 
			
			[self addComment:comments author:author];
			
			
			inCommentTag = NO;
		}
	
}




- (void) addHTMLHeader {
	pageBuffer = nil;
	pageBuffer = [[NSMutableString alloc] initWithCapacity:35*1024];
	[pageBuffer appendString:@"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0; user-scalable=no; width=device-width;\">"];
	[pageBuffer appendString:@"<style> .comment{border-bottom: 1px solid silver; padding-top: 5px; padding-bottom: 5px; }   * {font-family: helvetica;} .sttitle { font-weight: bold; text-align: right;} </style></head><body>"];
	[pageBuffer appendString: [NSString stringWithFormat: @"<center><i>First %d comments.</i></center>",MAX_COMMENTS] ];
}

- (void) addComment: (NSString *) comment author: (NSString*)authorText {
	
	
	
	
	BOOL isCurrentUser = NO;
	
	NSMutableString * buffer = nil;
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSString * currentUsername = [appDelegate getCurrentUserName];
	
	if ( currentUsername != nil && [authorText isEqualToString: currentUsername] ) {
		buffer = currentUserComments;
		isCurrentUser = YES;
	}	
	else {
		
		if ( commentCount > MAX_COMMENTS ) {
			return;
		}
		
		commentCount++;
		
		buffer = otherUserComments;
	}
	
	
	[buffer appendString:@"<div class=\"comment\">"];
	
	
	[buffer appendString:@"<b>"];
	
	if ( isCurrentUser  ) {
		[buffer appendString:@"<u>"];
	}
	
	[buffer appendString:[authorText stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"] ];
	
	if ( isCurrentUser  ) {
		[buffer appendString:@"</u>"];
	}	
	
	[buffer appendString:@"</b>: "];
	
	
	NSString * commentUpdated = [ comment stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;" ];
	commentUpdated = [ commentUpdated stringByReplacingOccurrencesOfString: @"\n" withString: @"<p/>" ];
	
	[buffer appendString:commentUpdated ];
	
	[buffer appendString:@"</div>"];
}

- (void) addHTMLFooter {
	[pageBuffer appendString:@"</html></body>"];
}




@end
