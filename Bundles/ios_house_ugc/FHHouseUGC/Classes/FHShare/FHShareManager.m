//
//  FHShareManager.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/3.
//

#import "FHShareManager.h"
#import <BDUGShareBaseContentItem.h>
#import <BDUGWechatContentItem.h>
#import <BDUGQQFriendContentItem.h>
#import <BDUGQQZoneContentItem.h>
#import <BDUGWechatTimelineContentItem.h>
#import <BDUGCopyContentItem.h>
#import <BDUGShareManager.h>
#import <SSCommonLogic.h>
#import "FHShareActivity/FHReportActivity.h"
#import "FHShareActivity/FHBlockActivity.h"
#import "FHShareActivity/FHDislikeActivity.h"


@interface FHShareManager () <BDUGShareManagerDataSource,BDUGShareManagerDelegate>
@property(nonatomic,strong) BDUGShareManager *shareManager;
@property(nonatomic,strong) FHShareContentModel *shareContentModel;
@end

@implementation FHShareManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static FHShareManager *defaultManager;
    dispatch_once(&onceToken, ^{
        defaultManager = [[FHShareManager alloc] init];
        defaultManager.shareManager = [[BDUGShareManager alloc] init];
        defaultManager.shareManager.dataSource = defaultManager;
        defaultManager.shareManager.delegate = defaultManager;
    });
    return defaultManager;
}

- (void)addCustomShareActivity {
    NSArray *activityNameArray = @[@"FHReportActivity",@"FHBlockActivity",@"FHDislikeActivity"];
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    for(NSString *activityName in activityNameArray) {
        Class activityClass = NSClassFromString(activityName);
        [activities addObject: [[activityClass alloc] init]];
    }
    [BDUGShareManager addUserDefinedActivitiesFromArray:activities];
}


-(BOOL)isShareOptimization {
    BOOL isShareOptimization = YES;
    return  isShareOptimization;
    return [SSCommonLogic isShareOptimization];
}

- (void)showSharePanelWithModel:(FHShareContentModel *)model {
    self.shareContentModel = model;
    [self.shareManager displayPanelWithContent:nil];
}

-(NSArray *)createContentItemsWithModel:(FHShareContentModel *)model {
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    for(NSInteger i = 0;i < model.contentItemArray.count; i++) {
        NSArray *itemTypeArray = model.contentItemArray[i];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        NSAssert([itemTypeArray isKindOfClass:[NSArray class]], @"object should be an array");
        for(NSInteger j = 0;j < itemTypeArray.count; j++) {
            FHShareChannelType channelType = (FHShareChannelType) [itemTypeArray[j] integerValue];
            BDUGShareBaseContentItem *item = [self createItemWithModel:model.dataModel channelType:channelType];
            if(item) {
                [items addObject:item];
            }
        }
        if(items.count) {
            [itemsArray addObject:items];
        }
    }
    return itemsArray;
}

-(BDUGShareBaseContentItem *)createItemWithModel:(FHShareDataModel *)model channelType:(FHShareChannelType)channelType {
    BDUGShareBaseContentItem *item = nil;
    switch (channelType) {
        case FHShareChannelTypeWeChat:
            item = [self createWechatItemWithModel:model];
            break;
        case FHShareChannelTypeWeChatTimeline:
            item = [self createWechatTimeLineItemWithModel:model];
            break;
        case FHShareChannelTypeQQFriend:
            item = [self createQQFriendItemWithModel:model];
            break;
        case FHShareChannelTypeQQZone:
            item = [self createQQZoneItemWithModel:model];
            break;
        case FHShareChannelTypeCopyLink:
            item = [self createCopyLinkItemWithModel:model];
            break;
        case FHShareChannelTypeReport:
            item = [self createReportItemWithModel:model];
            break;
        case FHShareChannelTypeBlock:
            item = [self createBlockItemWithModel:model];
            break;
        case FHShareChannelTypeDislike:
            item = [self createDislikeItemWithModel:model];
            break;
        default:
            break;
    }
    return item;
}

-(BDUGWechatContentItem *)createWechatItemWithModel:(FHShareDataModel *)model {
    BDUGWechatContentItem *item = [[BDUGWechatContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage defaultShareType:model.shareType];
    item.activityImageName = @"weixin_allshare";
    item.contentTitle = @"微信";
    return item;
}

-(BDUGWechatTimelineContentItem *)createWechatTimeLineItemWithModel:(FHShareDataModel *)model {
    BDUGWechatTimelineContentItem *item = [[BDUGWechatTimelineContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage defaultShareType:model.shareType];
    item.activityImageName = @"pyq_allshare";
    item.contentTitle = @"朋友圈";
    return item;
}


-(BDUGQQFriendContentItem *)createQQFriendItemWithModel:(FHShareDataModel *)model {
    BDUGQQFriendContentItem *item = [[BDUGQQFriendContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage imageUrl:model.imageUrl shareTye:model.shareType];
    item.activityImageName = @"qq_allshare";
    item.contentTitle = @"QQ";
    return item;
}

-(BDUGQQZoneContentItem *)createQQZoneItemWithModel:(FHShareDataModel *)model {
    BDUGQQZoneContentItem *item = [[BDUGQQZoneContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage imageUrl:model.imageUrl shareTye:model.shareType];
    item.activityImageName = @"qqkj_allshare";
    item.contentTitle = @"QQ空间";
    return item;
}

-(BDUGCopyContentItem *)createCopyLinkItemWithModel:(FHShareDataModel *)model {
    BDUGCopyContentItem *item = [[BDUGCopyContentItem alloc] init];
    item.webPageUrl = model.shareUrl;
    item.activityImageName = @"copy_allshare";
    item.contentTitle = @"复制链接";
    return item;
}

-(FHReportContentItem *)createReportItemWithModel:(FHShareDataModel *)model {
    FHReportContentItem *item = [[FHReportContentItem alloc] init];
    item.activityImageName = @"report_allshare";
    item.contentTitle = @"举报";
    return item;
}

-(FHBlockContentItem *)createBlockItemWithModel:(FHShareDataModel *)model {
    FHBlockContentItem *item = [[FHBlockContentItem alloc] init];
    item.activityImageName = @"shield_allshare";
    item.contentTitle = @"拉黑";
    return item;
}

-(FHDislikeContentItem *)createDislikeItemWithModel:(FHShareDataModel *)model {
    FHDislikeContentItem *item = [[FHDislikeContentItem alloc] init];
    item.activityImageName = @"unlike_allshare";
    item.contentTitle = @"屏蔽";
    return item;
}

-(NSArray *)resetPanelItems:(NSArray *)array panelContent:(BDUGSharePanelContent *)panelContent {
    return [self createContentItemsWithModel:self.shareContentModel];
}

-(void)shareManager:(BDUGShareManager *)shareManager completedWith:(id<BDUGActivityProtocol>)activity sharePanel:(id<BDUGActivityPanelControllerProtocol>)panelController error:(NSError *)error desc:(NSString *)desc {
    
}

@end

@implementation FHShareDataModel

@end

@implementation FHShareContentModel

@end
