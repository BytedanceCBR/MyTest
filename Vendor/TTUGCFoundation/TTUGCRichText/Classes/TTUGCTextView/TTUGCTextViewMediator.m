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
    [self toolbarDidClickHashtagButton];
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

- (void)toolbarDidClickHashtagButton {
    self.textView.didInputTextHashtag = NO;

    [TTTrackerWrapper eventV3:@"hashtag_button_click" params:@{
        @"source" : self.textView.source ?: @"post",
        @"status" : self.textView.keyboardVisible ? @"keyboard" : @"no_keyboard",
    }];

    self.isSelectViewControllerVisible = YES;

    TTUGCSearchHashtagViewController *viewController = [[TTUGCSearchHashtagViewController alloc] init];
    viewController.hashtagSuggestOption = self.hashtagSuggestOption;
    viewController.delegate = self;
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:viewController];
    navigationController.ttNavBarStyle = @"White";
    navigationController.ttHideNavigationBar = NO;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.textView.navigationController presentViewController:navigationController animated:YES completion:nil];
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

        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil];

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
        atUserLink.userInfo = @{
            @"user_id": userModel.user.info.user_id ?: @""
        };
        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:@[atUserLink]];
    } else {
        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil];
    }

    [self.textView replaceRichSpanText:richSpanText inRange:range];

    self.textView.didInputTextAt = NO;
}


#pragma mark - TTUGCSearchHashtagTableViewDelegate

- (void)searchHashtagTableViewWillDismiss {
    if (self.textView.didInputTextHashtag) {
        NSString *text = @"#";
        NSRange range = self.textView.selectedRange;

        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil];

        [self.textView replaceRichSpanText:richSpanText inRange:range];
    }

    [self.textView becomeFirstResponder];
}

- (void)searchHashtagTableViewDidDismiss {

    self.isSelectViewControllerVisible = NO;

    // 为了让 toolbar 状态正确，保证键盘收起和弹出顺序
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView becomeFirstResponder];
    });
}

- (void)searchHashtagTableViewDidSelectedHashtag:(FRPublishPostSearchHashtagStructModel *)hashtagModel {
    NSString *schema = hashtagModel.forum.schema;
    NSString *forumName = hashtagModel.forum.forum_name;
    NSString *concernId = hashtagModel.forum.concern_id;
    NSString *text = forumName ? [NSString stringWithFormat:@"#%@# ", forumName] : @"";
    NSRange range = self.textView.selectedRange;

    TTRichSpanText *richSpanText;
    if (!isEmptyString(schema)) {
        TTRichSpanLink *hashtagLink = [[TTRichSpanLink alloc] initWithStart:0 length:forumName.length + 2 link:schema text:nil type:TTRichSpanLinkTypeHashtag];
        hashtagLink.userInfo = @{
            @"forum_name": forumName ?: @"",
            @"concern_id": concernId ?: @""
        };
        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:@[hashtagLink]];
    } else {
        richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil];
    }

    [self.textView replaceRichSpanText:richSpanText inRange:range];

    self.textView.didInputTextHashtag = NO;
}


@end
