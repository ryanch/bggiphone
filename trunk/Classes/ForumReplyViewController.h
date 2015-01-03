//
//  ForumReplyViewController.h
//  BGG
//
//  Created by Christianson, Ryan on 2/22/13.
//
//

#import <UIKit/UIKit.h>

@interface ForumReplyViewController : UIViewController <UIActionSheetDelegate> {

    IBOutlet UITextField * subject;
    IBOutlet UITextView  * body;
    IBOutlet UIActivityIndicatorView * actvityView;
    
    
}

- (IBAction) send;

@property (nonatomic, readwrite, strong) NSString *messageId;
@property (nonatomic, readwrite, strong) UITextField *subject;
@property (nonatomic, readwrite, strong) UITextView *body;
@property (nonatomic, readwrite, strong) NSString *subjectTitle;
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *actvityView;

- (void) addSendButton;
- (void) doSubmitReply;
- (void) submitDone;


@end
