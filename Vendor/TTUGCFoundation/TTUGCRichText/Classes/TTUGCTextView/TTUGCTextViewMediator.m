//
//  TTUGCTextViewMediator.m
//  Article
//
//  Created by Jiyee Sheng on 28/11/2017.
//
//

#import "TTUGCTextViewMediator.h"
#import "TTNavigationController.h"
#import "TTRichSpanText+Emoji.h"
#import "TTTrackerWrapper.h"
#import "TTIndicatorView.h"
#import <TTStringHelper.h>
//#import <TTServiceProtocols/TTAccountProvider.h>
//#import <BDMobileRuntime/BDMobileRuntime.h>
//#import <TTRegistry/TTRegistryDefines.h>
#import "TTUGCHashtagModel.h"
#import "FHTopicListController.h"

@interface TTUGCTextViewMediator() <FHTopicListControllerDelegate>
@end

@implementation TTUGCTextViewMediator

#pragma mark - TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {
    
}

- (void)textViewDidBeginEditing:(TTUGCTextView *)textView {
    [self.toolbar markKeyboardAsVisible];
}

- (void)textViewDidInputTextAt:(TTUGCTextView *)textView {
    [self toolbarDidClickAtButton];
}

- (void)textViewDidInputTextHashtag:(TTUGCTextView *)textView {
    [self didInputTextHashTag];
}

#pragma mark - TTUGCToolbarDelegate

- (void)toolbarDidClickKeyboardButton:(BOOL)switchToKeyboardInput {
    if (switchToKeyboardInput) {
        [self.textView becomeFirstResponder];
    } else {
        [self.textView resignFirstResponder];

        [self.toolbar endEditing:YES];
    }
}

- (void)toolbarDidClickAtButton {
    self.textView.didInputTextAt = NO;

    [TTTrackerWrapper eventV3:@"at_button_click" params:@{
        @"source" : self.textView.source ?: @"post",
        @"status" : self.textView.keyboardVisible ? @"keyboard" : @"no_keyboard",
    }];

    self.isSelectViewControllerVisible = YES;

    TTUGCSearchUserViewController *viewController = [[TTUGCSearchUserViewController alloc] init];
    viewController.delegate = self;
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:viewController];
    navigationController.ttNavBarStyle = @"White";
    navigationController.ttHideNavigationBar = NO;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.textView.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)toolbarDidClickPictureButtonWithBanPicInput:(BOOL)banPicInput {
    if (!banPicInput) {
        [self.multiImageView presentMultiImagePickerView];
    }
}


-(void)didInputTextHashTag {
    
    self.textView.didInputTextHashtag = YES;
    self.isSelectViewControllerVisible = YES;
    
    if(self.hashTagBtnClickBlock) {
        self.hashTagBtnClickBlock(self.textView.didInputTextHashtag);
    }
}

- (void)toolbarDidClickHashtagButton {
    
    self.textView.didInputTextHashtag = NO;
    self.isSelectViewControllerVisible = YES;
    
    if(self.hashTagBtnClickBlock) {
        self.hashTagBtnClickBlock(self.textView.didInputTextHashtag);
    }
}

- (void)toolbarDidClickEmojiButton:(BOOL)switchToEmojiInput {
    if (switchToEmojiInput) {
        [TTTrackerWrapper eventV3:@"emoticon_click" params:@{
            @"source" : self.textView.source ?: @"post",
            @"status" : self.textView.keyboardVisible ? @"keyboard" : @"no_keyboard",
        }];

        [self.textView resignFirstResponder];
    } else {
        [TTTrackerWrapper eventV3:@"emoticon_keyboard" params:@{
            @"source" : self.textView.source ?: @"post",
            @"status" : self.textView.keyboardVisible ? @"keyboard" : @"no_keyboard",
        }];

        [self.textView becomeFirstResponder];
    }
}


#pragma mark - TTUGCSearchUserTableViewDelegate

- (void)searchUserTableViewWillDismiss {
    if (self.textView.didInputTextAt) {
        NSString *text = @"@";
        NSRange range = self.textView.selectedRange;

        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil imageInfoModelDictionary:nil];

        [self.textView replaceRichSpanText:richSpanText inRange:range];
    }

    [self.textView becomeFirstResponder];
}

- (void)searchUserTableViewDidDismiss {

    self.isSelectViewControllerVisible = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView becomeFirstResponder];
    });
}

- (void)searchUserTableViewDidSelectedUser:(FRPublishPostSearchUserStructModel *)userModel {
    NSString *schema = userModel.user.info.schema;
    NSString *userName = userModel.user.info.name;
    NSString *text = [NSString stringWithFormat:@"@%@ ", userName ?: @""];
    NSRange range = self.textView.selectedRange;

    TTRichSpanText *richSpanText;
    if (!isEmptyString(schema)) {
        TTRichSpanLink *atUserLink = [[TTRichSpanLink alloc] initWithStart:0 length:userName.length + 1 link:schema text:nil type:TTRichSpanLinkTypeAt];
        NSDictionary *colorInfo = nil;
        if (self.richSpanColorHexStringForDay && self.richSpanColorHexStringForNight) {
            colorInfo = @{
                         @"day": self.richSpanColorHexStringForDay,
                         @"night":self.richSpanColorHexStringForNight
                         };
        }
        if (colorInfo) {
            atUserLink.userInfo = @{
                                    @"user_id": userModel.user.info.user_id ?: @"",
                                    @"color_info": colorInfo
                                    };
        } else {
            atUserLink.userInfo = @{
                                    @"user_id": userModel.user.info.user_id ?: @"",
                                    };
        }
        
        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:@[atUserLink] imageInfoModelDictionary:nil];
    } else {
        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil imageInfoModelDictionary:nil];
    }

    [self.textView replaceRichSpanText:richSpanText inRange:range];

    self.textView.didInputTextAt = NO;
}


#pragma mark - TTUGCSearchHashtagTableViewDelegate

//- (void)searchHashtagTableViewWillDismiss {
//    if (self.textView.didInputTextHashtag) {
//        NSString *text = @"#";
//        NSRange range = self.textView.selectedRange;
//
//        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil imageInfoModelDictionary:nil];
//
//        [self.textView replaceRichSpanText:richSpanText inRange:range];
//    }
//
//    [self.textView becomeFirstResponder];
//}
//
//- (void)searchHashtagTableViewDidDismiss {
//
//    self.isSelectViewControllerVisible = NO;
//
//    // 为了让 toolbar 状态正确，保证键盘收起和弹出顺序
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.textView becomeFirstResponder];
//    });
//}
//
//- (void)searchHashtagTableViewDidSelectedHashtag:(TTUGCHashtagModel *)hashtagModel {
//    NSString *schema = hashtagModel.forum.schema;
//    NSString *forumName = hashtagModel.forum.forum_name;
//    NSString *concernId = hashtagModel.forum.concern_id;
//    NSString *text = forumName ? [NSString stringWithFormat:@"#%@# ", forumName] : @"";
//    NSRange range = self.textView.selectedRange;
//
//    TTRichSpanText *richSpanText;
//    if (!isEmptyString(schema)) {
//        TTRichSpanLink *hashtagLink = [[TTRichSpanLink alloc] initWithStart:0 length:forumName.length + 2 link:schema text:nil type:TTRichSpanLinkTypeHashtag];
//
//        NSDictionary *colorInfo = nil;
//        if (self.richSpanColorHexStringForDay && self.richSpanColorHexStringForNight) {
//            colorInfo = @{
//                         @"day": self.richSpanColorHexStringForDay,
//                         @"night":self.richSpanColorHexStringForNight
//                         };
//        }
//        if (colorInfo) {
//            hashtagLink.userInfo = @{
//                                     @"forum_name": forumName ?: @"",
//                                     @"concern_id": concernId ?: @"",
//                                     @"color_info": colorInfo,
//                                     @"forum_id": hashtagModel.forum.forum_id ?: @""
//                                     };
//        } else {
//            hashtagLink.userInfo = @{
//                                     @"forum_name": forumName ?: @"",
//                                     @"concern_id": concernId ?: @"",
//                                     @"forum_id": hashtagModel.forum.forum_id ?: @""
//                                     };
//        }
//
//        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:@[hashtagLink] imageInfoModelDictionary:nil];
//    } else {
//        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil imageInfoModelDictionary:nil];
//    }
//
//    [self.textView replaceRichSpanText:richSpanText inRange:range];
//
//    self.textView.didInputTextHashtag = NO;
//}

#pragma mark - FHTopicListControllerDelegate

- (void)didSelectedHashtag:(FHTopicListResponseDataListModel *)hashtagModel {
    
    NSString *schema = hashtagModel.schema;
    NSString *forumName = hashtagModel.forumName;
    NSString *concernId = hashtagModel.forumId;
    NSString *text = forumName ? [NSString stringWithFormat:@"#%@# ", forumName] : @"";
    NSRange range = self.textView.selectedRange;
    
    TTRichSpanText *richSpanText;
    if (!isEmptyString(schema)) {
        TTRichSpanLink *hashtagLink = [[TTRichSpanLink alloc] initWithStart:0 length:forumName.length + 2 link:schema text:nil type:TTRichSpanLinkTypeHashtag];
        
        NSDictionary *colorInfo = nil;
        if (self.richSpanColorHexStringForDay && self.richSpanColorHexStringForNight) {
            colorInfo = @{
                          @"day": self.richSpanColorHexStringForDay,
                          @"night":self.richSpanColorHexStringForNight
                          };
        }
        if (colorInfo) {
            hashtagLink.userInfo = @{
                                     @"forum_name": forumName ?: @"",
                                     @"concern_id": concernId ?: @"",
                                     @"color_info": colorInfo,
                                     @"forum_id": concernId ?: @""
                                     };
        } else {
            hashtagLink.userInfo = @{
                                     @"forum_name": forumName ?: @"",
                                     @"concern_id": concernId ?: @"",
                                     @"forum_id": concernId ?: @""
                                     };
        }
        
        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:@[hashtagLink] imageInfoModelDictionary:nil];
    } else {
        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil imageInfoModelDictionary:nil];
    }
    
    if(self.textView.didInputTextHashtag) {
        range.location = range.location - 1;
        range.length = range.length + 1;
    }
    
    [self.textView replaceRichSpanText:richSpanText inRange:range];
    
    self.textView.didInputTextHashtag = NO;
}

- (void)addHashtag:(FHTopicListResponseDataListModel *)hashtagModel {
    [self didSelectedHashtag:hashtagModel];
}
@end
