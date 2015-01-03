//
//  RecordedPlaysXMLParser.m
//  BGG
//
//  Created by Steve Moak on 9/24/14.
//
//

#import "RecordedPlaysXMLParser.h"

#import "BGGRecordedPlay.h"

@interface RecordedPlaysXMLParser()

@property (nonatomic, strong) BGGRecordedPlay *currentPlay;

@property (nonatomic) BOOL inComments;

@end

@implementation RecordedPlaysXMLParser

- (BOOL)parseXML:(NSString *)document parseError:(NSError *)error
{
    self.recordedPlays = [[NSMutableArray alloc] init];
    self.currentPlay = nil;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[document dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    BOOL success = [parser parse];
    
    if (!success) {
        if ( error != nil ) {
            error =  [parser parserError];
        }
    }
    else {
        
        
    }	
    
    return success;
    
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.inComments = NO;
    
    if ([elementName isEqualToString:@"play"])
    {
        self.currentPlay = [[BGGRecordedPlay alloc] init];
        if (attributeDict[@"quantity"] != nil)
        {
            self.currentPlay.numPlays = [attributeDict[@"quantity"] intValue];
        }
        
        if (attributeDict[@"date"] != nil)
        {
            NSString *dateStr = attributeDict[@"date"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            
            self.currentPlay.date = [formatter dateFromString:dateStr];
        }
        
        self.currentPlay.location = attributeDict[@"location"];
        self.currentPlay.comments = [[NSString alloc] init];
    }
    else if ([elementName isEqualToString:@"comments"])
    {
        self.inComments = YES;
    }
    
} // end start element method


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.inComments && self.currentPlay != nil)
    {
        self.currentPlay.comments = [self.currentPlay.comments stringByAppendingString:string];
    }
    
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"play"])
    {
        [self.recordedPlays addObject:self.currentPlay];
        self.currentPlay = nil;
    }
    else if ([elementName isEqualToString:@"comments"])
    {
        self.inComments = NO;
    }
}

@end
