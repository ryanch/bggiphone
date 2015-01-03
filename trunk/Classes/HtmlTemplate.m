//
//  HtmlTemplate.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 3/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HtmlTemplate.h"


@implementation HtmlTemplate

-(void) _loadFile: (NSString*) fileName {

	NSError *error = nil;
	NSString * fileContents = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&error];
	
	if(fileContents == nil)
	{
		NSLog(@"ERROR: Couldn't load file at path '%@' because of error '%@'.", fileName, [error localizedDescription]);
		return;
	}
	
	NSMutableArray *tempParts = [[NSMutableArray alloc] initWithCapacity:100];
	unichar tempChars[3024];
	NSInteger tempIndex = 0;
	
	NSInteger count = [fileContents length];
	
	BOOL foundHolder = NO;
	
	
	NSString * hashBang = @"#!";
	unichar hash = [hashBang characterAtIndex:0];
	unichar bang = [hashBang characterAtIndex:1];
	
	for( NSInteger i = 0; i < count; i++ ) {
		unichar charFound = [fileContents characterAtIndex:i];
		
		if ( charFound == hash && tempIndex > 1 && tempChars[0] == hash && tempChars[1] == bang) {
			
			foundHolder = YES;
		}	
		else if ( charFound == hash ) {
			NSString * str = [[NSString alloc] initWithCharacters:tempChars length:tempIndex];
			[tempParts addObject: str  ];
			tempIndex = 0;
		}
		
		tempChars[tempIndex++] = charFound;
		
		if ( foundHolder ) {
			NSString * str = [[NSString alloc] initWithCharacters:tempChars length:tempIndex];
			[tempParts addObject: str  ];
			tempIndex = 0;
			foundHolder = NO;
		}

		
	}	
	
	if ( tempIndex != 0 ) {
		NSString * str = [[NSString alloc] initWithCharacters:tempChars length:tempIndex];
		[tempParts addObject: str  ];
	}
	
	parts = tempParts;
	
	
}

-(NSString*) allocMergeWithData: (NSDictionary*) data {
	NSMutableString * output = [[NSMutableString alloc] initWithCapacity:3024];
	
	NSString * hashBang = @"#!";
	unichar hash = [hashBang characterAtIndex:0];
	unichar bang = [hashBang characterAtIndex:1];	
	
	NSInteger count = [parts count];
	for ( NSInteger i = 0; i < count; i++ ) {
		NSString * part = [parts objectAtIndex:i];
		NSInteger length = [part length];
		if ( length == 0  ) {
			continue;
		}
		else if ( length < 3 ) {
			[output appendString:part];
		}
		
		else if ( [part characterAtIndex:0] == hash && [part characterAtIndex:1] == bang ) {
			
			NSString * value = [data objectForKey:part];
			if ( value == nil ) {
				[output appendString:part];
			}
			else {
				[output appendString:value];
			}
			
		}
		else {
			[output appendString:part];
		}
			
			
			
	}

	return output;
}


-(id) initWithFileName: (NSString*) fileName;
{
	self = [super init];
	if (self != nil) {
		
		[self _loadFile:fileName];
		
		
	}
	return self;
}




@end



