//
//  TTAuthorizeLoginObj.m
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import "TTAuthorizeLoginObj.h"
#import <TTAccountBusiness.h>

/*
 1、点击取消，弹窗关闭。
 2、点击登录，跳转至登录页。
 *评论界面引导，点击「评论」先去登录，登录完后弹出评论框。（类似未登录点击「评论」按钮效果）
 */
@implementation TTAuthorizeLoginObj

- (void)showAlertAtActionDetailComment:(TTThemedAlertActionBlock)completionBlock {
    if (![self isEnabled])
        return;
    
    // 第一次不弹
    if (self.authorizeModel.showLoginTimesDetailComment - 1 >= self.authorizeModel.showLoginMaxTimesDetailComment) {
        return;
    }
    
    self.authorizeModel.showLoginTimesDetailComment += 1;
    
    // 第一次不弹
    if (self.authorizeModel.showLoginTimesDetailComment == 1) {
        [self.authorizeModel saveData];
        return;
    }
    
    [self updateShowTime];
    
    [self showMainTitle:@"发表评论" message:@"登录发表评论，接受万众点赞" imageName:@"comments_picture.png" cancelButtonTitle:@"取消" okButtonTitle:@"评论"
     cancelBlock:^{
        ttTrackEvent(@"pop", @"login_detail_comment_cancel");
     } okBlock:^{
         ttTrackEvent(@"pop", @"login_detail_comment_open");
         if (completionBlock) {
             completionBlock();
         }
     }];
    ttTrackEvent(@"pop", @"login_detail_comment_show");
}
    
- (BOOL)isEnabled {
    // 仅对未登录的用户生效。
    if ([TTAccountManager isLogin])
        return NO;
    
    // 距上次同类弹窗时间k天
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.authorizeModel.lastTimeShowLogin;
    if (interval < self.authorizeModel.showLoginTimeInterval) {
        return NO;
    }
    
    // 和其他类型弹窗间隔c天
    interval = now - [self.authorizeModel maxLastTimeExcept:self.authorizeModel.lastTimeShowLogin];
    if (interval < self.authorizeModel.showAlertInterval) {
        return NO;
    }
    
    return YES;
}

- (void)updateShowTime {
    self.authorizeModel.lastTimeShowLogin = (NSInteger)[[NSDate date] timeIntervalSince1970];
    [self.authorizeModel saveData];
}

@end
