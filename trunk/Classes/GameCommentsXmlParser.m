//
//  GameCommentsXmlParser.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameCommentsXmlParser.h"

#define MAX_COMMENTS 50

@implementation GameCommentsXmlParser

@synthesize writeToPath;

- (BOOL)parseXMLAtURL:(NSURL *)URL parseError:(NSError **)error {
	
	commentCount = 0;
	
	[self addHTMLHeader];
	
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
	
		[self addHTMLFooter];
		
	
		success =[pageBuffer writeToFile:writeToPath	atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		

	
	}	
	
	[parser release];
	[pageBuffer release];
		
	return success;
	
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	
	
	inCommentTag = NO;
	
	if (qName) {
        elementName = qName;
    }
	
	if ( [elementName isEqualToString:@"comment"] ) {
		
		if ( commentCount > MAX_COMMENTS ) {
			return;
		}
		
		commentCount++;
		
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
	[writeToPath release];
	[pageBuffer release];
	[author release];
	[stringBuffer release];
	[super dealloc];
}


- (void) addHTMLHeader {
	[pageBuffer release];
	pageBuffer = [[NSMutableString alloc] initWithCapacity:25*1024];
	[pageBuffer appendString:@"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0; user-scalable=no; width=device-width;\">"];
	[pageBuffer appendString:@"<style> .comment{border-bottom: 1px solid silver; padding-top: 5px; padding-bottom: 5px; }   * {font-family: helvetica;} .sttitle { font-weight: bold; text-align: right;} </style></head><body>"];
	[pageBuffer appendString: [NSString stringWithFormat: @"<center><i>First %d comments.</i></center>",MAX_COMMENTS] ];
}

- (void) addComment: (NSString *) comment author: (NSString*)authorText {
	
	[pageBuffer appendString:@"<div class=\"comment\">"];
	
	[pageBuffer appendString:@"<b>"];
	
	[pageBuffer appendString:[authorText stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"] ];
	
	[pageBuffer appendString:@"</b>: "];
	
	[pageBuffer appendString:[comment stringByReplacingOccurrencesOfString:@"<" withString: @"&lt;"] ];
	
	[pageBuffer appendString:@"</div>"];
}

- (void) addHTMLFooter {
	[pageBuffer appendString:@"</html></body>"];
}




@end
