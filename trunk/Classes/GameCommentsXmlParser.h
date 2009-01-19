//
//  GameCommentsXmlParser.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 11/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameCommentsXmlParser : NSObject {
	NSMutableString *stringBuffer;
	NSMutableString *pageBuffer;
	BOOL inCommentTag;
	BOOL hitMaxComments;
	NSString *author;
	NSString * writeToPath;
	NSInteger commentCount;
}

@property (nonatomic,retain) NSString * writeToPath;

- (void) addHTMLHeader;
- (void) addComment: (NSString *) comment author: (NSString*)author;
- (void) addHTMLFooter;
- (BOOL)parseXMLAtURL:(NSURL *)URL parseError:(NSError **)error;

@end
