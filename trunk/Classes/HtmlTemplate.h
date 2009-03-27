//
//  HtmlTemplate.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 3/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HtmlTemplate : NSObject {

	NSArray * parts;
	
}

-(void) _loadFile: (NSString*) fileName;

-(NSString*) allocMergeWithData: (NSDictionary*) data;

-(id) initWithFileName: (NSString*) fileName;

@end
