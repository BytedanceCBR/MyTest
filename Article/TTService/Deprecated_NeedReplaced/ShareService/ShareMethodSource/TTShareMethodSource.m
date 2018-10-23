//
//  TTShareMethodSource.m
//  Article
//
//  Created by 延晋 张 on 2017/1/12.
//
//

#import "TTShareMethodSource.h"
#import "TTDeviceHelper.h"
#import "SSCommonLogic.h"
#import "TTShareConstants.h"
#import "TTIndicatorView.h"
#import <TTShareAdapterSetting.h>
#import "TTShareMethodUtil.h"
#import "TTUIResponderHelper.h"
#import "UIView+SupportFullScreen.h"
#import "TTVPlayVideo.h"
@implementation TTShareMethodSource

+ (void)load
{
    [TTShareAdapterSetting sharedService].methodSource = [TTShareMethodSource new];
}

- (BOOL)isPadDevice
{
    return [TTDeviceHelper isPadDevice];
}

- (BOOL)isZoneVersion
{
    return [SSCommonLogic isZoneVersion];
}

- (UIViewController *)topmostViewController
{
    return [TTUIResponderHelper topmostViewController];
}

- (void)activityWillSharedWith:(id<TTActivityProtocol>)activity
{
    if ([[activity contentItem] conformsToProtocol:@protocol(TTActivityContentItemShareProtocol)]) {
        id<TTActivityContentItemShareProtocol> contentItem = (id<TTActivityContentItemShareProtocol>)[activity contentItem];
        
        if ([TTShareMethodUtil isQQFriendShare:contentItem]) {
            [self shareItem:contentItem extroInfo:kShareChannelFromQQ];
            [self replaceQQImageURL:contentItem];
            if ([contentItem shareType] == TTShareVideo) {
                TTQQFriendContentItem *qqItem = (TTQQFriendContentItem *)contentItem;
                qqItem.image = [self videoImageWith:qqItem.image];
            }
        } else if ([TTShareMethodUtil isQQZoneShare:contentItem]) {
            [self shareItem:contentItem extroInfo:kShareChannelFromQQZone];
            if ([contentItem shareType] == TTShareVideo) {
                TTQQZoneContentItem *qqZoneItem = (TTQQZoneContentItem *)contentItem;
                qqZoneItem.image = [self videoImageWith:qqZoneItem.image];
            }
        } else if([TTShareMethodUtil isWeChatShare:contentItem]) {
            [self shareItem:contentItem extroInfo:kShareChannelFromWeixin];
            [self shareItem:contentItem extroInfo:@"wxshare_count=1"];
            if ([contentItem shareType] == TTShareVideo) {
                TTWechatContentItem *wechatItem = (TTWechatContentItem *)contentItem;
                wechatItem.thumbImage = [self videoImageWith:wechatItem.thumbImage];
            }
        } else if ([TTShareMethodUtil isWeChatTimeLineShare:contentItem]) {
            [self shareItem:contentItem extroInfo:kShareChannelFromWeixinMoment];
            [self shareItem:contentItem extroInfo:@"wxshare_count=1"];
        }
//        } else if([TTShareMethodUtil isWeiboShare:contentItem]) {
//            [self shareItem:contentItem extroInfo:@"wbshare_count=1"];
//        } else if([TTShareMethodUtil isDingTalkShare:contentItem]) {
//            [self shareItem:contentItem extroInfo:kShareChannelFromDingTalk];
//            [self shareItem:contentItem extroInfo:@"dtshare_count=1"];
//        } else if([TTShareMethodUtil isAliShare:contentItem]) {
//            [self shareItem:contentItem extroInfo:kShareChannelFromZhiFuBao];
//            [self shareItem:contentItem extroInfo:@"zfbshare_count=1"];
//        }
    }
}

- (void)activityHasSharedWith:(id<TTActivityProtocol>)activity error:(NSError *)error desc:(NSString *)desc
{
    NSString *imageName = error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png";
    if (!isEmptyString(desc)) {
        if ([TTDeviceHelper OSVersionNumber] < 9.0){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:desc indicatorImage:[UIImage themedImageNamed:imageName] autoDismiss:YES dismissHandler:nil];
            return;
        }

        [self showShareIndicatorViewInKeyWindowWithTip:desc andImage:[UIImage imageNamed:imageName] dismissHandler:nil];

    }
}

#pragma mark - ViedoImage

- (UIImage *)videoImageWith:(UIImage *)originImage
{
    UIImage *tempImage = originImage;
    UIImage *videoImage = [UIImage imageNamed:@"toutiaovideo"];
    videoImage = [videoImage imageScaleAspectToMaxSize:originImage.size.height / 1.5];
    tempImage = [UIImage drawImage:videoImage inImage:originImage atPoint:CGPointMake(originImage.size.width / 2, originImage.size.height / 2)];
    return tempImage;
}

#pragma mark - 补充统计Url

- (void)shareItem:(id<TTActivityContentItemProtocol>)contentItem extroInfo:(NSString *)extroInfo
{
    if ([contentItem respondsToSelector:@selector(webPageUrl)]) {
        id<TTActivityContentItemShareProtocol> shareItem = (id<TTActivityContentItemShareProtocol>)contentItem;
        NSString *webPageUrl = [shareItem webPageUrl];
        if (!isEmptyString(webPageUrl) && [webPageUrl rangeOfString:extroInfo].location == NSNotFound) {
            if ([webPageUrl rangeOfString:@"?"].location == NSNotFound) {
                [shareItem setWebPageUrl:[webPageUrl stringByAppendingFormat:@"?%@", extroInfo]];
            } else {
                [shareItem setWebPageUrl:[webPageUrl stringByAppendingFormat:@"&%@", extroInfo]];
            }
        }
    } else {
        NSAssert(0, @"无webPageUrl property");
    }
}

#pragma mark - 替换图片格式

- (void)replaceQQImageURL:(id<TTActivityContentItemProtocol>)contentItem
{
    TTQQFriendContentItem *qqItem = (TTQQFriendContentItem *)contentItem;
    if ([qqItem.imageUrl hasSuffix:@".webp"]) {
        qqItem.imageUrl = [qqItem.imageUrl stringByReplacingOccurrencesOfString:@".webp" withString:@".jpg" options:0 range:NSMakeRange(qqItem.imageUrl.length - 5, 5)];
    }
    
}

- (void)showShareIndicatorViewInKeyWindowWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler {
    BOOL isFullScreen = [TTVPlayVideo currentPlayingPlayVideo].player.context.isFullScreen;
    TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:indicatorImage dismissHandler:handler];
    [indicateView addTransFormIsFullScreen:isFullScreen];
    indicateView.autoDismiss = YES;
    [indicateView showFromParentView:[[indicateView class] defaultParentView]];
    [indicateView changeFrameIsFullScreen:isFullScreen];
}

@end
