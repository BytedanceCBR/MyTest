//
//  FRPostCommonButton.h
//  Article
//
//  Created by zhaopengwei on 15/7/23.
//
//

//#import "FRImportTTHeader.h"
#import "FRLineView.h"
#import "TTDiggButton.h"
#import <TTNetworkManager.h>


typedef void(^FRPostCommentButtonHandle)();
typedef void(^FREmojiButtonHandle)();
typedef void(^FRDiggButtonHandle)();
typedef void(^FRShareButtonHandle)();

extern CGFloat fr_postCommentButtonHeight(void);

@interface FRPostCommonButton : SSThemedView

@property (strong, nonatomic) TTAlphaThemedButton *emojiButton;
@property (strong, nonatomic) TTDiggButton *diggButton;
@property (strong, nonatomic) SSThemedButton *button;
@property (strong, nonatomic) FRLineView *topLine;
@property (copy, nonatomic) FRPostCommentButtonHandle postCommentButtonClick;
@property (copy, nonatomic) FREmojiButtonHandle emojiButtonClick;
@property (copy, nonatomic) FRDiggButtonHandle diggButtonClick;
@property (copy, nonatomic) FRShareButtonHandle shareButtonClick;

- (void)setPlaceholderContent:(NSString *)placeholderContent;

@end
