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
//  XmlSearchReader.m
//  iBBG
//
//  Created by RYAN CHRISTIANSON on 9/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "XmlSearchReader.h"
#import "BBGSearchResult.h"


@implementation XmlSearchReader

@synthesize inNameTag, searchResults, numberGamesFound, currentResult, stringBuffer,currentNameIsPrimary,gameNames;
@synthesize parseItemFormat;
@synthesize searchURL;


- (XmlSearchReader*) initCopyForReload {
	XmlSearchReader* newCopy = [[XmlSearchReader alloc] init];
	
	newCopy.parseItemFormat = self.parseItemFormat;
	newCopy.searchURL = self.searchURL;
	
	return newCopy;
}

- (BOOL)parseXMLAtSearchURLWithError:(NSError **)error { 
	return [self parseXMLAtURL:searchURL parseError: error];
}


- (BOOL)parseXMLAtURL:(NSURL *)URL parseError:(NSError **)error {

	inNameTag = NO;

	
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
    
    [parser release];
	
	
	return success;
	
}



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	
	if (qName) {
        elementName = qName;
    }
	
	if ( parseItemFormat == YES ) {
		
		if ( [elementName isEqualToString:@"item"] ) {
			
			// make sure it is a board game
			NSString *type = [attributeDict valueForKey: @"objecttype" ];
			if ( [type isEqualToString: @"boardgame"] == NO ) {
				return;
			}
			
			
			// looks like an actual board game
			numberGamesFound++;
			
			// check for max matches
			/*
			if ( numberGamesFound > MAX_SEARCH_RESULTS ) {
				return;
			}
			*/
			 
			// make a container for the data 
			if ( currentResult != nil ) {
				[currentResult release];
			}	
			currentResult = [[BBGSearchResult alloc] init];
			
			// save the object id
			currentResult.gameId = [attributeDict valueForKey: @"objectid" ];

			[searchResults addObject:currentResult];
			
		}
		else if ( [elementName isEqualToString:@"name"] ) { 
		
			inNameTag = TRUE;
			[stringBuffer setString:@""];
		
		}
		
		
	} // of parse for ITEM tag
	else {
		
		
	
	
		// is it a <game> tag?
		if ( [elementName isEqualToString:@"game"] ) {
			numberGamesFound++;
			
			// clear old game names
			[gameNames removeAllObjects];
			
			// check if we have enough that we should not build any more
			if ( numberGamesFound > MAX_SEARCH_RESULTS ) {
				return;
			}
			
			if ( currentResult != nil ) {
				[currentResult release];
			}
			
			currentResult = [[BBGSearchResult alloc] init];
			
			// get the year published
			NSString *yearPublishedStr = [attributeDict valueForKey: @"yearpublished" ];
			if ( yearPublishedStr != nil ) {
				currentResult.yearPublished = [yearPublishedStr intValue];
			}
			
			// get the game id
			NSString *gameId = [attributeDict valueForKey:@"gameid"];
			if ( gameId != nil ) {
				currentResult.gameId = gameId;
			}
			
			
		}
		
		// check if it is a name tag
		else if ( [elementName isEqualToString:@"name"] ) {
			currentNameIsPrimary = NO;
			inNameTag = YES;
			
			
			[stringBuffer setString:@""];
			
			NSString * primary = [attributeDict valueForKey:@"primary"];
			if (primary != nil && [primary isEqualToString:@"true"] ) {
				currentNameIsPrimary = YES;
			}
			
		} // end if name tag
		
	} // end game tag
	

} // end start element method

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
	
	if (qName) {
        elementName = qName;
    }
	
	
	
	if ( parseItemFormat == YES ) {
		if ( [elementName isEqualToString:@"name"] ) {
			inNameTag = NO;
			
			NSString *currentName = [ [NSString alloc] initWithString: stringBuffer]; 
			
			currentResult.primaryTitle = currentName;
			
			[currentName release];
		}
		
	}
	else {
	
	// is it a </game> tag?
	if ( [elementName isEqualToString:@"game"] ) {
		if ( currentResult != nil ) {
			
			// see if we have game names
			if ( [gameNames count] > 0 ) {
				currentResult.alternateNames = [[NSArray alloc] initWithArray: gameNames];
			}
			
			// if we finished the current game, and 
			// we had a current result then add it to the
			// search results
			[searchResults addObject:currentResult];
			[currentResult release];
			currentResult = nil;
		}
	} // end item parse
	
	//is it a </name> tag?
	else if ( [elementName isEqualToString:@"name"] ) {
		
		inNameTag = NO;
		
		NSString *currentName = [ [NSString alloc] initWithString: stringBuffer]; 
		
		if ( currentNameIsPrimary ) {
			currentResult.primaryTitle = currentName;
		}
		else {
			
			if ( [gameNames count] < MAX_GAME_NAMES ) {
				[gameNames addObject:currentName];
			}

		}
		
	}
	
	
	
	/*
    if (qName) {
        elementName = qName;
    }
    
    if ([elementName isEqualToString:@"title"]) {
        self.currentEarthquakeObject.title = self.contentOfCurrentEarthquakeProperty;
        
    } else if ([elementName isEqualToString:@"updated"]) {
        self.currentEarthquakeObject.eventDateString = self.contentOfCurrentEarthquakeProperty;
        
    } else if ([elementName isEqualToString:@"georss:point"]) {
        self.currentEarthquakeObject.geoRSSPoint = self.contentOfCurrentEarthquakeProperty;
    }
	 */
		
	} //end game parse
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	
	if ( inNameTag ) {
		[stringBuffer appendString:string];
	}
	
	/*
    if (self.contentOfCurrentEarthquakeProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.contentOfCurrentEarthquakeProperty appendString:string];
    }
	 */
}


// setup a new instance
- init {
	if (self = [super init]) {
		numberGamesFound = 0;
		self.searchResults = [[NSMutableArray alloc] initWithCapacity: MAX_SEARCH_RESULTS];
		currentResult = nil;
		self.stringBuffer = [NSMutableString string];
		self.gameNames = [[NSMutableArray alloc] initWithCapacity:MAX_GAME_NAMES];
		inNameTag = NO;
		parseItemFormat = NO;
	}
	return self;
}


- (void)dealloc {
	[searchURL release];
	[searchResults release];
	[currentResult release];
	[stringBuffer release];
	[gameNames release];
	[super dealloc];
}


@end
