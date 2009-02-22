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
//  XmlGameInfoReader.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "XmlGameInfoReader.h"
#import "FullGameInfo.h"


@implementation XmlGameInfoReader

@synthesize gameInfo, stringBuffer;

- (BOOL)parseXMLAtURL:(NSURL *)URL parseError:(NSError **)error {

	gameInfo = [[FullGameInfo alloc] init];
	captureChars = NO;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    BOOL success = [parser parse];
    
    if (!success && error != nil ) {
        *error =  [parser parserError];
    }
    
    [parser release];
	
	
	return success;
	
}



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	
	captureGameTitle = NO;
	
	if (qName) {
        elementName = qName;
    }
	
	if ( [elementName isEqualToString:@"description" ] ) {
		[stringBuffer setString:@""];
		captureChars = YES;
	}
	
	else if ( [elementName isEqualToString:@"thumbnail" ]  ) {
		[stringBuffer setString:@""];
		captureChars = YES;
	}
	

	else if ( [elementName isEqualToString:@"usersrated" ] ||[elementName isEqualToString:@"name" ] ||
			 [elementName isEqualToString:@"minplayers" ] ||
			 [elementName isEqualToString:@"maxplayers" ] ||
			 [elementName isEqualToString:@"playingtime" ] ||
			 [elementName isEqualToString:@"average" ] ||
			 [elementName isEqualToString:@"bayesaverage" ] ||
			 [elementName isEqualToString:@"rank" ] ||
			 [elementName isEqualToString:@"numweights" ] ||
			 [elementName isEqualToString:@"averageweight" ] ||
			 [elementName isEqualToString:@"owned" ] || 
			 [elementName isEqualToString:@"trading" ] ||
			 [elementName isEqualToString:@"wanting" ] ||
			 [elementName isEqualToString:@"wishing" ]
		
			 ) {
		[stringBuffer setString:@""];
		captureChars = YES;
	}
	
	
	NSString * primary = (NSString*) [ attributeDict objectForKey:@"primary"];
	
	if (  primary != nil && [primary isEqualToString:@"true"] && [elementName isEqualToString:@"name" ]) {
		captureGameTitle = YES;
	}
	 
	
} // end start element method

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
	
	if (qName) {
        elementName = qName;
    }
	
	if ( [elementName isEqualToString:@"description" ] ) {
		NSString *desc = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.desc = desc;
		[desc release];
	}
	
	else if ( [elementName isEqualToString:@"thumbnail" ]  ) {
		NSString *thumb = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.imageURL = thumb;
		[thumb	release];
	}
	
	else if ( [elementName isEqualToString:@"usersrated" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.usersrated = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"average" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.average = value;
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"bayesaverage" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.bayesaverage = value;
		[value	release];
	}
	
	
	else if ( [elementName isEqualToString:@"playingtime" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.playingTime = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"maxplayers" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.maxPlayers = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"minplayers" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.minPlayers = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"rank" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.rank = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"numweights" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.numweights = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"averageweight" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.averageweight = value;
		[value	release];
	}
	
	
	else if ( captureGameTitle == YES && [elementName isEqualToString:@"name" ]  ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.title = value;
		[value	release];
	}
	
	
	else if ( [elementName isEqualToString:@"owned" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.owned = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"trading" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.trading = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"wanting" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.wanting = [value intValue];
		[value	release];
	}
	
	else if ( [elementName isEqualToString:@"wishing" ] ) {
		NSString *value = [ [NSString alloc] initWithString: stringBuffer]; 
		gameInfo.wishing = [value intValue];
		[value	release];
	}
	
	
	
	captureChars = NO;

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	
	if ( captureChars ) {
		[stringBuffer appendString:string];
	}
	
}


// setup a new instance
- init {
	if (self = [super init]) {
		gameInfo = nil;
		captureChars = NO;
		self.stringBuffer = [NSMutableString string];
	}
	return self;
}


- (void)dealloc {
	[gameInfo release];
	[stringBuffer release];
	[super dealloc];
}



@end
