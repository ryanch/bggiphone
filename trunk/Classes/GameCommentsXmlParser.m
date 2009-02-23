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

#define MAX_COMMENTS 50

@implementation GameCommentsXmlParser

@synthesize writeToPath;

- (BOOL)parseXMLAtURL:(NSURL *)URL parseError:(NSError **)error {
	

	[currentUserComments release];
	currentUserComments = [[NSMutableString alloc] initWithCapacity:10*1024];
	
	[otherUserComments release];
	otherUserComments = [[NSMutableString alloc] initWithCapacity:25*1024];	
	
	commentCount = 0;
	
	
	
	inCommentTag = NO;
	
	[stringBuffer release];
	stringBuffer = [NSMutableString string];
	[stringBuffer retain];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    BOOL success = [parser parse];
    
    if (!success) {
        *error =  [parser parserError];
    }
    else {
	
		
		[self addHTMLHeader];
		
		[pageBuffer appendString:currentUserComments];
		[currentUserComments release];
		currentUserComments = nil;
		
		
		[pageBuffer appendString:otherUserComments];
		[otherUserComments release];
		otherUserComments = nil;
		
		[self addHTMLFooter];
		
	
		success =[pageBuffer writeToFile:writeToPath	atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		

	
	}	
	
	[parser release];
	
	
	[pageBuffer release];
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
		

		
		
		
		[author release];
		author = (NSString*) [attributeDict objectForKey:@"username"];
		[author retain];
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
			
			[comments release];
			
			inCommentTag = NO;
		}
	
}


- (void) dealloc
{
	[otherUserComments release];
	[currentUserComments release];
	[writeToPath release];
	[pageBuffer release];
	[author release];
	[stringBuffer release];
	[super dealloc];
}


- (void) addHTMLHeader {
	[pageBuffer release];
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
	

	
	[buffer appendString:[comment stringByReplacingOccurrencesOfString:@"<" withString: @"&lt;"] ];
	
	[buffer appendString:@"</div>"];
}

- (void) addHTMLFooter {
	[pageBuffer appendString:@"</html></body>"];
}




@end
