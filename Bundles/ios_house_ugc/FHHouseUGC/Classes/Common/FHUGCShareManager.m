//
//  FHUGCShareManager.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/10/30.
//

#import "FHUGCShareManager.h"
#import "TTRoute.h"
#import "TTShareManager.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TTActivityContentItemProtocol.h>
#import <TTWechatTimelineContentItem.h>
#import <TTWechatContentItem.h>
#import <TTQQFriendContentItem.h>
#import <TTQQZoneContentItem.h>
#import <TTWechatTimelineActivity.h>
#import <TTWechatActivity.h>
#import <TTQQFriendActivity.h>
#import <TTQQZoneActivity.h>
#import <TTCopyActivity.h>
#import "FHUserTracker.h"
#import "BDWebImage.h"
#import "TTAccountManager.h"

@interface FHUGCShareManager ()<TTShareManagerDelegate>
@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, copy)     NSDictionary       *shareExtraDic;// 额外分享参数字典

@end

@implementation FHUGCShareManager

+ (instancetype)sharedManager {
    static FHUGCShareManager *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[FHUGCShareManager alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
   
    }
    return self;
}

#pragma mark TTShareManagerDelegate
- (void)shareManager:(TTShareManager *)shareManager clickedWith:(id<TTActivityProtocol>)activity sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
    NSString *platform = @"be_null";
    if ([activity isKindOfClass:[TTWechatTimelineActivity class]]) {
        platform = @"weixin_moments";
    } else if ([activity isKindOfClass:[TTWechatActivity class]]) {
        platform = @"weixin";
    } else if ([activity isKindOfClass:[TTQQFriendActivity class]]) {
        platform = @"qq";
    } else if ([activity isKindOfClass:[TTQQZoneActivity class]]) {
        platform = @"qzone";
    } else if ([activity isKindOfClass:[TTCopyActivity class]]) {
        platform = @"copy";
    }
    [self addShareFormLog:platform];
}

- (void)shareManager:(TTShareManager *)shareManager completedWith:(id<TTActivityProtocol>)activity sharePanel:(id<TTActivityPanelControllerProtocol>)panelController error:(NSError *)error desc:(NSString *)desc
{
    
}

- (TTShareManager *)shareManager
{
    if (!_shareManager) {
        _shareManager = [[TTShareManager alloc]init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

// 详情页分享
- (void)shareAction {
    [self shareActionWithShareExtra:nil];
}

// 携带埋点参数的分享
- (void)shareActionWithShareExtra:(NSDictionary *)extra {
    self.shareExtraDic = extra;
    [self addClickShareLog];
    
    if (!self.shareInfo) {
        return;
    }
    UIImage *shareImage = [[BDImageCache sharedImageCache]imageFromDiskCacheForKey:self.shareInfo.coverImage] ? : [UIImage imageNamed:@"default_image"];
    NSString *title = self.shareInfo.title ? : @"";
    NSString *desc = self.shareInfo.desc ? : @"";
    NSString *webPageUrl = self.shareInfo.shareUrl ? : @"";
    
    NSMutableArray *shareContentItems = @[].mutableCopy;

    TTWechatContentItem *wechatItem = [[TTWechatContentItem alloc] initWithTitle:title desc:desc webPageUrl:webPageUrl thumbImage:shareImage shareType:TTShareWebPage];
    [shareContentItems addObject:wechatItem];
    TTWechatTimelineContentItem *timeLineItem = [[TTWechatTimelineContentItem alloc] initWithTitle:title desc:desc webPageUrl:webPageUrl thumbImage:shareImage shareType:TTShareWebPage];
    [shareContentItems addObject:timeLineItem];
    
    // 大师说PM说微信不用判断
    if ([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]) {
        
        TTQQFriendContentItem *qqFriendItem = [[TTQQFriendContentItem alloc] initWithTitle:title desc:desc webPageUrl:webPageUrl thumbImage:shareImage imageUrl:@"" shareTye:TTShareWebPage];
        [shareContentItems addObject:qqFriendItem];
        TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:title desc:desc webPageUrl:webPageUrl thumbImage:shareImage imageUrl:@"" shareTye:TTShareWebPage];
        [shareContentItems addObject:qqZoneItem];
    }
    
    TTCopyContentItem *copyContentItem = [[TTCopyContentItem alloc] initWithDesc:webPageUrl];
    [shareContentItems addObject:copyContentItem];
    [self.shareManager displayActivitySheetWithContent:shareContentItems];
}


#pragma mark 埋点相关
- (NSDictionary *)baseParams
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    params[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    params[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    params[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
    return params;
}

- (void)addClickShareLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    if (self.shareExtraDic) {
        [params addEntriesFromDictionary:self.shareExtraDic];
    }
    [FHUserTracker writeEvent:@"click_share" params:params];
}

- (void)addShareFormLog:(NSString *)platform
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    params[@"platform"] = platform ? : @"be_null";
    if (self.shareExtraDic) {
        [params addEntriesFromDictionary:self.shareExtraDic];
    }
    [FHUserTracker writeEvent:@"share_platform" params:params];
    self.shareExtraDic = nil;// 分享都会走当前方法
}

@end

// 分享模型数据
@implementation FHUGCShareInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"coverImage": @"cover_image",
                           @"isVideo": @"is_video",
                           @"shareUrl": @"share_url",
                           @"desc": @"description",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
