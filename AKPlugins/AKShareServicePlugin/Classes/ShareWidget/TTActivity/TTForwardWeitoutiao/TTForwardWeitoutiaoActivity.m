//
//  TTForwardWeitoutiaoActivity.m
//  Article
//
//  Created by 王霖 on 17/4/24.
//
//
#import "TTForwardWeitoutiaoActivity.h"
#import <TTShareManager.h>
#import <TTThemed/TTThemeManager.h>

NSString * const TTActivityTypeForwardWeitoutiao = @"com.toutiao.UIKit.activity.ForwardWeitoutiao";
@interface TTForwardWeitoutiaoActivity ()
@property (nonatomic, strong) UIImage * dayImage;
@property (nonatomic, strong) UIImage * nightImage;
@end
@implementation TTForwardWeitoutiaoActivity
+ (void)load {
    [TTShareManager addUserDefinedActivity:[TTForwardWeitoutiaoActivity new]];
}

- (TTForwardWeitoutiaoContentItem *)contentItem
{
    if (!_contentItem) {
        _contentItem = [[TTForwardWeitoutiaoContentItem alloc] init];
    }
    return _contentItem;
}

#pragma mark - Identifier
- (NSString *)contentItemType {
    return TTActivityContentItemTypeForwardWeitoutiao;
}
- (NSString *)activityType {
    return TTActivityTypeForwardWeitoutiao;
}
#pragma mark - Display
- (NSString *)activityImageName {
    return [self.contentItem activityImageName];
}

- (NSString *)contentTitle {
    return [self.contentItem contentTitle];
}

- (NSString *)shareLabel {
    return nil;
}

#pragma mark - Action
- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if (self.contentItem.customAction) {
        self.contentItem.customAction();
    }
    if (completion) {
        completion(self, nil, nil);
    }
}
#pragma mark - TTActivityPanelActivityProtocol
- (TTActivityPanelControllerItemLoadImageType)itemLoadImageType {
    return TTActivityPanelControllerItemLoadImageTypeImage;
}
- (UIImage *)itemImage {
    UIImage * dayImage = [[self repostIconDownloadManager] getWeitoutiaoRepostDayIcon];
    UIImage * nightImage = [[self repostIconDownloadManager] getWeitoutiaoRepostNightIcon];
    if (nil == dayImage || nil == nightImage) {
        //使用本地图片
        self.dayImage = [UIImage imageNamed:@"share_toutiaoweibo"];
        self.nightImage = [UIImage imageNamed:@"share_toutiaoweibo_night"];
    }else {
        //网络图片已下载
        self.dayImage = dayImage;
        self.nightImage = nightImage;
    }
    if (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) {
        return self.dayImage;
    }else {
        return self.nightImage;
    }
}

- (id<TTWeitoutiaoRepostIconDownloadManagerInterface>)repostIconDownloadManager
{
    // TTWeitoutiaoRepostIconDownloadManager在主工程中
    Class class = NSClassFromString(@"TTWeitoutiaoRepostIconDownloadManager");
    if (!class) {
        return nil;
    }
    id<TTWeitoutiaoRepostIconDownloadManagerInterface> manager = [class performSelector:@selector(sharedManager)];
    if (![manager conformsToProtocol:@protocol(TTWeitoutiaoRepostIconDownloadManagerInterface)]) {
        return nil;
    }
    return manager;
}

@end
