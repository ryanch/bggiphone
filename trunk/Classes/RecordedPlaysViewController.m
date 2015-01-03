//
//  RecordedPlaysViewController.m
//  BGG
//
//  Created by Steve Moak on 9/24/14.
//
//

#import "RecordedPlaysViewController.h"
#import "BGGHTMLScraper.h"
#import "BGGAppDelegate.h"
#import "PlistSettings.h"
#import "BGGRecordedPlay.h"
#import "RecordedPlaysXMLParser.h"

@implementation RecordedPlaysViewController

- (void) doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LoadingViewController overrides

-(NSString *) cacheFileName
{
    return nil;
}

-(NSString *) urlStringForLoading
{
    if(self.gameId == nil)
        return nil;
    
    BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *username = [appDelegate.appSettings.dict objectForKey:@"username"];
    
    
    NSString * url = [NSString stringWithFormat:@"http://boardgamegeek.com/xmlapi2/plays?username=%@&id=%@", username, self.gameId];

    return url;
}

-(id) resultsFromDocument:(NSString *)document withHTMLScraper:(BGGHTMLScraper *)htmlScraper
{
    NSArray *results = nil;
    
    RecordedPlaysXMLParser *parser = [[RecordedPlaysXMLParser alloc] init];
    if ([parser parseXML:document parseError:nil])
    {
        results = parser.recordedPlays;
    
        // Append play count to title
        NSInteger playCount = 0;
        for (int i = 0; i < results.count; i++)
        {
            BGGRecordedPlay *play = results[i];
            playCount += play.numPlays;
        }
    
        [self setTitle:[self.title stringByAppendingFormat:@" (%ld)", (long)playCount]];
    }
    
    return results;
}

-(void) updateCell:(UITableViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BGGRecordedPlay *play = [items objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    cell.textLabel.text = [formatter stringFromDate:play.date];
    if (play.numPlays > 1)
    {
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@" x%ld", (long)play.numPlays];
    }
    
    if (play.location.length > 0)
    {
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@" (%@)", play.location];
    }
    
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    cell.detailTextLabel.text = play.comments;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleSubtitle;
}

@end
