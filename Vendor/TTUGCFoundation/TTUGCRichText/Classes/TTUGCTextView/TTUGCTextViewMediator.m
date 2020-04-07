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
#import "TTStringHelper.h"
//#import <TTServiceProtocols/TTAccountProvider.h>
//#import <BDMobileRuntime/BDMobileRuntime.h>
//#import <TTRegistry/TTRegistryDefines.h>
#import "TTUGCHashtagModel.h"
#import "FHTopicListController.h"
#import "UIColor+Theme.h"
#import "NSString+UGCUtils.h"
#import "TTAccountManager.h"
#import "FHEnvContext.h"

@interface TTUGCTextViewMediator() <FHTopicListControllerDelegate>
@end

@implementation TTUGCTextViewMediator

- (instancetype)init {
    self = [super init];
    if (self) {
        _richSpanColorHexStringForDay = [NSString hexStringWithColor:[UIColor themeRed3]];
        _richSpanColorHexStringForNight = [NSString hexStringWithColor:[UIColor themeRed3]];
    }
    return self;
}

#pragma mark - TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {
    
}

- (void)textViewDidBeginEditing:(TTUGCTextView *)textView {
    [self.toolbar markKeyboardAsVisible];
}

- (void)textViewDidInputTextAt:(TTUGCTextView *)textView {
    [self didInputTextAt];
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
- (void)didInputTextAt {
    self.textView.didInputTextAt = YES;
    self.isSelectViewControllerVisible = YES;
    
    if(self.atBtnClickBlock) {
        self.atBtnClickBlock(self.textView.didInputTextAt);
    } else {
        if ([TTAccountManager isLogin]) {
            [self defaultActionForAtButton];
        } else {
            [self.textView resignFirstResponder];
            [self gotoLogin];
        }
    }
}

- (void)toolbarDidClickAtButton {
    
    self.textView.didInputTextAt = NO;
    self.isSelectViewControllerVisible = YES;
    
    if(self.atBtnClickBlock) {
        self.atBtnClickBlock(self.textView.didInputTextAt);
    } else {
        if ([TTAccountManager isLogin]) {
            [self defaultActionForAtButton];
        } else {
            [self.textView resignFirstResponder];
            [self gotoLogin];
        }
    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.traceDict];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager presentAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wSelf defaultActionForAtButton];
                });
            }else{
                wSelf.isSelectViewControllerVisible = NO;
                [wSelf.textView becomeFirstResponder];
            }
        }else{
            wSelf.isSelectViewControllerVisible = NO;
//            [wSelf.textView becomeFirstResponder];
        }
    }];
}

- (void)defaultActionForAtButton {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"sslocal://ugc_post_at_list"];
    NSURL *url = components.URL;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"delegate"] = self;
    param[@"isPushOutAtListController"] = @(self.isPushOutAtListController);
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:param];
    if(self.isPushOutAtListController) {
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    } else {
        [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
    }
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
