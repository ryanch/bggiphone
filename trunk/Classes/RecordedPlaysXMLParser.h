//
//  RecordedPlaysXMLParser.h
//  BGG
//
//  Created by Steve Moak on 9/24/14.
//
//

#import <Foundation/Foundation.h>

@interface RecordedPlaysXMLParser : NSObject <NSXMLParserDelegate>

- (BOOL)parseXML:(NSString *)docment parseError:(NSError *)error;

@property (nonatomic, strong) NSMutableArray *recordedPlays;

@end
