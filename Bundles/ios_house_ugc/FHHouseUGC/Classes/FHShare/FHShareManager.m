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
#import <SSCommonLogic.h>
@implementation FHShareManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static FHShareManager *defaultManager;
    dispatch_once(&onceToken, ^{
        defaultManager = [[FHShareManager alloc] init];
    });
    return defaultManager;
}

-(BOOL)isShareOptimization {
    return YES;
    return [SSCommonLogic isShareOptimization];
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

-(BDUGShareBaseContentItem *)createItemWithModel:(FHShareBaseModel *)model channelType:(FHShareChannelType)channelType {
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
        default:
            break;
    }
    return item;
}

-(BDUGWechatContentItem *)createWechatItemWithModel:(FHShareBaseModel *)model {
    BDUGWechatContentItem *item = [[BDUGWechatContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage defaultShareType:model.shareType];
    item.activityImageName = @"weixin_allshare";
    item.contentTitle = @"微信";
    return item;
}

-(BDUGWechatTimelineContentItem *)createWechatTimeLineItemWithModel:(FHShareBaseModel *)model {
    BDUGWechatTimelineContentItem *item = [[BDUGWechatTimelineContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage defaultShareType:model.shareType];
    item.activityImageName = @"pyq_allshare";
    item.contentTitle = @"朋友圈";
    return item;
}


-(BDUGQQFriendContentItem *)createQQFriendItemWithModel:(FHShareBaseModel *)model {
    BDUGQQFriendContentItem *item = [[BDUGQQFriendContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage imageUrl:model.imageUrl shareTye:model.shareType];
    item.activityImageName = @"qq_allshare";
    item.contentTitle = @"QQ";
    return item;
}

-(BDUGQQZoneContentItem *)createQQZoneItemWithModel:(FHShareBaseModel *)model {
    BDUGQQZoneContentItem *item = [[BDUGQQZoneContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage imageUrl:model.imageUrl shareTye:model.shareType];
    item.activityImageName = @"qqkj_allshare";
    item.contentTitle = @"QQ空间";
    return item;
}

-(BDUGCopyContentItem *)createCopyLinkItemWithModel:(FHShareBaseModel *)model {
    BDUGCopyContentItem *item = [[BDUGCopyContentItem alloc] init];
    item.webPageUrl = model.shareUrl;
    item.activityImageName = @"copy_allshare";
    item.contentTitle = @"复制链接";
    return item;
}

@end

@implementation FHShareBaseModel

@end

@implementation FHShareContentModel

@end
