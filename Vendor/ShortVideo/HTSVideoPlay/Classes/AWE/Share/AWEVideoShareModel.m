//
//  AWEVideoShareModel.m
//  Pods
//
//  Created by 王双华 on 2017/8/24.
//
//

#import "AWEVideoShareModel.h"
#import "TTShortVideoModel.h"
#import "AWEVideoConstants.h"
#import "TTShortVideoModel.h"
#import <extobjc.h>
#import <TTBaseLib/UIImageAdditions.h>
#import "TTShareManager.h"
#import "TSVVideoShareManager.h"
#import "TTDirectForwardWeitoutiaoContentItem.h"
#import "TSVVideoDetailShareHelper.h"
#import "TTSettingsManager.h"
#import "TTAccountAuthWeChat.h"
#import <TencentOpenAPI/QQApiInterface.h>

@interface AWEVideoShareModel ()

@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareDesc;
@property (nonatomic, copy) NSString *shareCopyContent;
@property (nonatomic, copy) NSString *shareURL;
@property (nonatomic, copy) NSString *shareImageURL;
@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) AWEVideoShareType shareType;
@property (nonatomic, strong) TTShortVideoModel *model;

@end

@implementation AWEVideoShareModel

+ (NSString *)labelForContentItemType:(NSString *)contentItemType
{
    NSDictionary *dict = @{TTActivityContentItemTypeWechatTimeLine: @"weixin_moments",
                           TTActivityContentItemTypeWechat: @"weixin",
                           TTActivityContentItemTypeQQFriend: @"qq",
                           TTActivityContentItemTypeQQZone: @"qzone"};
//                           TTActivityContentItemTypeSystem: @"system",
//                           TTActivityContentItemTypeCopy: @"copy"};
    
    return [dict objectForKey:contentItemType];
}

- (instancetype)initWithModel:(TTShortVideoModel *)model image:(UIImage *)shareImage shareType:(AWEVideoShareType)shareType
{
    self = [super init];
    if (self) {
        _model = model;
        _isFavorite = model.userRepin;
        _shareImage = shareImage;
        
        if (_shareImage) {
            UIImage * videoImage = [UIImage imageNamed:@"huoshanlive"];
            CGFloat maxSize = MIN(shareImage.size.width, shareImage.size.height) / 1.5;
            videoImage = [videoImage imageScaleAspectToMaxSize:maxSize];
            _shareImage = [UIImage drawImage:videoImage inImage:shareImage atPoint:CGPointMake(shareImage.size.width / 2, shareImage.size.height / 2)];
        }
        
        if (model.shareTitle.length > 0) {
            _shareTitle = model.shareTitle;
        } else {
            _shareTitle = [NSString stringWithFormat:@"%@的精彩视频", model.author.name];
        }
        
        NSString *desc = model.shareDesc;
        if (desc.length > 0) {
            NSString *content = [desc length] > 30 ? [[desc substringToIndex:30] stringByAppendingString:@"..."] : desc;
            _shareDesc = content;
        } else {
            _shareDesc = @"这是我私藏的视频。一般人我才不分享！";
        }
        
        if ([model.groupSource isEqualToString:AwemeGroupSource]) {
            _shareCopyContent = [NSString stringWithFormat:@"%@在抖音上分享了视频，快来围观！传送门戳我>>%@", model.author.name, model.shareUrl];
        } else if ([model.groupSource isEqualToString:HotsoonGroupSource]) {
            _shareCopyContent = [NSString stringWithFormat:@"%@在火山星球上分享了视频，快来围观！传送门戳我>>%@", model.author.name, model.shareUrl];
        } else if ([model.groupSource isEqualToString:ToutiaoGroupSource]) {
            _shareCopyContent = [NSString stringWithFormat:@"%@在幸福里上分享了视频，快来围观！传送门戳我>>%@", model.author.name, model.shareUrl];
        } else {
            _shareCopyContent = [NSString stringWithFormat:@"%@分享了视频，快来围观！传送门戳我>>%@", model.author.name, model.shareUrl];
        }
        
        _shareURL = model.shareUrl;
        _shareImageURL = [model.video.originCover.urlList firstObject];
        _shareType = shareType;
    }
    return self;
}

- (NSArray<id<TTActivityContentItemProtocol>> *)forwardSharePanelContentItems {
    NSArray *array = [TSVVideoShareManager synchronizeUserDefaultsWithItemArray:@[
                                                                                     [self wechatMomentsContentItem],
                                                                                     [self wechatContentItem],
                                                                                     [self qqContentItem],
                                                                                     [self qqZoneContentItem]]];
    return array;
}

- (NSArray<id<TTActivityContentItemProtocol>> *)shareContentItems
{
    NSArray *shareContentItemsArray = nil;
    NSMutableArray* needAddItem = [[NSMutableArray alloc] initWithCapacity:4];

//    if ([TTAccountAuthWeChat isAppInstalled]) {
//        [needAddItem addObject: [self wechatMomentsContentItem]];
//        [needAddItem addObject: [self wechatContentItem]];
//    }
    
    [needAddItem addObject: [self wechatMomentsContentItem]];
    [needAddItem addObject: [self wechatContentItem]];

    
    if ([QQApiInterface isQQInstalled]) {
        [needAddItem addObject: [self qqContentItem]];
        [needAddItem addObject: [self qqZoneContentItem]];
    }

    NSArray *topArray = [TSVVideoShareManager synchronizeUserDefaultsWithItemArray:needAddItem];
    NSMutableArray *secondArray = [NSMutableArray array];
    NSNumber *shareEnable = @YES;
    switch (_shareType) {
        case AWEVideoShareTypeDefault:
        {
            /// 底部分享入口
            if (shareEnable.boolValue) {
//                [secondArray addObject:[self systemContentItem]];
//                [secondArray addObject:[self copyContentItem]];
//                if (![self.model isAuthorMyself]) {
//                    //自己发的小视频不支持保存视频
//                    [secondArray addObject:[self saveVideoContentItem]];
//                }
                shareContentItemsArray = @[
                                           topArray
//                                           [secondArray copy],
                                           ];
            } else {

                shareContentItemsArray = @[
                                           @[[self reportContentItem]]
                                           ];
            }
        }
            break;
        case AWEVideoShareTypeMore:
        {
            /// 顶部更多入口
            if (shareEnable.boolValue) {
                
                [secondArray addObject:[self favoriteContentItem]];
                
                if (![self.model isAuthorMyself]) {
                    //自己发的小视频不支持保存视频、举报、保存视频、分享链接
                    [secondArray addObject:[self dislikeContentItem]];
                    [secondArray addObject:[self reportContentItem]];
//                    [secondArray addObject:[self saveVideoContentItem]];
//                    [secondArray addObject:[self copyContentItem]];
                } else {
                    [secondArray addObject:[self deleteContentItem]];
                }
                shareContentItemsArray = @[
                                           topArray,
                                           [secondArray copy],
                                           ];
            } else {
                if (![self.model isAuthorMyself]) {
                    //自己发的小视频不支持保存视频、举报、保存视频、分享链接
                    [secondArray addObject:[self reportContentItem]];
                } else {
                    [secondArray addObject:[self deleteContentItem]];
                }
                shareContentItemsArray = @[
                                           [secondArray copy],
                                           ];
            }
        }
            break;
        case AWEVideoShareTypeMoreForStory:
        {
            if (shareEnable.boolValue) {
                shareContentItemsArray = @[
                                           topArray,
                                           @[

                                               [self favoriteContentItem],
                                             [self reportContentItem]
//                                             [self saveVideoContentItem],
//                                             [self copyContentItem]],
                                           ]];
            } else {
                shareContentItemsArray = @[
                                           @[
                                             [self reportContentItem]]
                                           ];
            }
        }
            break;
        case AWEVideoShareTypeAd:
        {
        /// 顶部更多入口
        //广告小视频支持、举报、保存视频、分享链接
            if (shareEnable.boolValue) {
                [secondArray addObject:[self dislikeContentItem]];
                [secondArray addObject:[self reportContentItem]];
//                [secondArray addObject:[self copyContentItem]];
                NSArray *topArray = [TSVVideoShareManager synchronizeUserDefaultsWithItemArray:@[[self wechatMomentsContentItem],
                                                                                                 [self wechatContentItem],
                                                                                                 [self qqContentItem],
                                                                                                 [self qqZoneContentItem]]];
                shareContentItemsArray = @[
                                           topArray,
                                           [secondArray copy],
                                           ];
            } else {
                [secondArray addObject:[self reportContentItem]];
                shareContentItemsArray = @[
                                           [secondArray copy],
                                           ];
            }
        }
            break;
        default:
            break;
    }
    return shareContentItemsArray;
}

#pragma mark - Items
- (TTWechatTimelineContentItem *)wechatMomentsContentItem
{
    TTWechatTimelineContentItem *wctlContentItem = [[TTWechatTimelineContentItem alloc] initWithTitle:self.shareDesc
                                                                                                 desc:nil
                                                                                           webPageUrl:self.shareURL
                                                                                           thumbImage:self.shareImage
                                                                                            shareType:TTShareWebPage];
    return wctlContentItem;
}

- (TTWechatContentItem *)wechatContentItem
{
    TTWechatContentItem *wcContentItem = [[TTWechatContentItem alloc] initWithTitle:self.shareTitle
                                                                               desc:self.shareDesc
                                                                         webPageUrl:self.shareURL
                                                                         thumbImage:self.shareImage
                                                                          shareType:TTShareWebPage];
    return wcContentItem;
}

- (TTQQFriendContentItem *)qqContentItem
{
    TTQQFriendContentItem *qqContentItem = [[TTQQFriendContentItem alloc] initWithTitle:self.shareTitle
                                                                                   desc:self.shareDesc
                                                                             webPageUrl:self.shareURL
                                                                             thumbImage:self.shareImage
                                                                               imageUrl:self.shareImageURL
                                                                               shareTye:TTShareWebPage];
    return qqContentItem;
}

- (TTQQZoneContentItem *)qqZoneContentItem
{
    TTQQZoneContentItem *qqZoneContentItem = [[TTQQZoneContentItem alloc] initWithTitle:self.shareTitle
                                                                                   desc:self.shareDesc
                                                                             webPageUrl:self.shareURL
                                                                             thumbImage:self.shareImage
                                                                               imageUrl:self.shareImageURL
                                                                               shareTye:TTShareWebPage];
    return qqZoneContentItem;
}

- (TTFavouriteContentItem *)favoriteContentItem
{
    TTFavouriteContentItem *favoriteContentItem = [[TTFavouriteContentItem alloc] init];
    favoriteContentItem.selected = _isFavorite;
    return favoriteContentItem;
}

- (TTReportContentItem *)reportContentItem
{
    TTReportContentItem *reportContentItem = [[TTReportContentItem alloc] init];
    return reportContentItem;
}

- (TTDislikeContentItem *)dislikeContentItem
{
    TTDislikeContentItem *dislikeContentItem = [[TTDislikeContentItem alloc] init];
    return dislikeContentItem;
}

//- (TTSystemContentItem *)systemContentItem
//{
//    TTSystemContentItem *systemContentItem = [[TTSystemContentItem alloc] initWithDesc:self.shareCopyContent webPageUrl:self.shareURL image:self.shareImage];
//    return systemContentItem;
//}
//
//- (TTCopyContentItem *)copyContentItem
//{
//    TTCopyContentItem *copyContentItem = [[TTCopyContentItem alloc] initWithDesc:self.shareCopyContent];
//    return copyContentItem;
//}
//
//- (TTSaveVideoContentItem *)saveVideoContentItem
//{
//    TTSaveVideoContentItem *saveVideoContentItem = [[TTSaveVideoContentItem alloc] init];
//    return saveVideoContentItem;
//}

- (TTDeleteContentItem *)deleteContentItem
{
    TTDeleteContentItem *deleteContentItem = [[TTDeleteContentItem alloc] init];
    return deleteContentItem;
}

@end
