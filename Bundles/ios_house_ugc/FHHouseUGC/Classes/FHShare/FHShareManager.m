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
#import "FHReportActivity.h"
#import "FHBlockActivity.h"
#import "FHDislikeActivity.h"
#import "FHIMActivity.h"
#import "FHCollectActivity.h"
#import <TTIndicatorView.h>
#import <FHUserTracker.h>
#import <NSDictionary+BTDAdditions.h>
#import <NSString+BTDAdditions.h>
#import <NSURL+BTDAdditions.h>
#import <FHCommonDefines.h>
#import <UIColor+Theme.h>
#import "FHLarkShareButton.h"

@implementation FHShareDataModel

@end

@implementation FHShareCommonDataModel

@end

@interface FHShareContentModel ()
@property(nonatomic,strong) FHShareDataModel *dataModel;
@property(nonatomic,strong) NSArray *contentItemArray;
@end

@implementation FHShareContentModel

- (instancetype)initWithDataModel:(FHShareDataModel *)dataModel contentItemArray:(NSArray *)contentItemArray {
    self = [super init];
    if (self) {
        _dataModel = dataModel;
        _contentItemArray = contentItemArray;
    }
    return self;
}

@end

@interface FHShareManager () <BDUGShareManagerDataSource,BDUGShareManagerDelegate>
@property(nonatomic,strong) BDUGShareManager *shareManager;
@property(nonatomic,strong) FHShareContentModel *shareContentModel;
@property(nonatomic,strong) NSDictionary *tracerDict;
@property(nonatomic,strong) FHLarkShareButton *larkShareButton;
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
    NSArray *activityNameArray = @[@"FHReportActivity",@"FHBlockActivity",@"FHDislikeActivity",@"FHIMActivity",@"FHCollectActivity"];
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    for(NSString *activityName in activityNameArray) {
        Class activityClass = NSClassFromString(activityName);
        [activities addObject: [[activityClass alloc] init]];
    }
    [BDUGShareManager addUserDefinedActivitiesFromArray:activities];
}


-(BOOL)isShareOptimization {
    BOOL isShareOptimization = [SSCommonLogic isShareOptimization];
    isShareOptimization = YES;
    return  isShareOptimization;
}

- (void)showSharePanelWithModel:(FHShareContentModel *)model tracerDict:(NSDictionary *)tracerDict {
    self.shareContentModel = model;
    self.tracerDict = tracerDict;
    
    [FHUserTracker writeEvent:@"click_share" params:tracerDict];
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
            item = [self createWechatItemWithModel:model.commonDataModel];
            break;
        case FHShareChannelTypeWeChatTimeline:
            item = [self createWechatTimeLineItemWithModel:model.commonDataModel];
            break;
        case FHShareChannelTypeQQFriend:
            item = [self createQQFriendItemWithModel:model.commonDataModel];
            break;
        case FHShareChannelTypeQQZone:
            item = [self createQQZoneItemWithModel:model.commonDataModel];
            break;
        case FHShareChannelTypeCopyLink:
            item = [self createCopyLinkItemWithModel:model.commonDataModel];
            break;
        case FHShareChannelTypeReport:
            item = [self createReportItemWithModel:model.reportDataModel];
            break;
        case FHShareChannelTypeBlock:
            item = [self createBlockItem];
            break;
        case FHShareChannelTypeDislike:
            item = [self createDislikeItem];
            break;
        case FHShareChannelTypeIM:
            item = [self createIMItemWithModel:model.imDataModel];
            break;
        case FHShareChannelTypeCollect:
            item = [self createCollectItemWithModel:model.collectDataModel];
            break;
        default:
            break;
    }
    return item;
}

-(BDUGWechatContentItem *)createWechatItemWithModel:(FHShareCommonDataModel *)model {
    BDUGWechatContentItem *item = [[BDUGWechatContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage defaultShareType:model.shareType];
    item.activityImageName = @"weixin_allshare";
    item.contentTitle = @"微信";
    return item;
}

-(BDUGWechatTimelineContentItem *)createWechatTimeLineItemWithModel:(FHShareCommonDataModel *)model {
    BDUGWechatTimelineContentItem *item = [[BDUGWechatTimelineContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage defaultShareType:model.shareType];
    item.activityImageName = @"pyq_allshare";
    item.contentTitle = @"朋友圈";
    return item;
}


-(BDUGQQFriendContentItem *)createQQFriendItemWithModel:(FHShareCommonDataModel *)model {
    BDUGQQFriendContentItem *item = [[BDUGQQFriendContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage imageUrl:model.imageUrl shareTye:model.shareType];
    item.activityImageName = @"qq_allshare";
    item.contentTitle = @"QQ";
    return item;
}

-(BDUGQQZoneContentItem *)createQQZoneItemWithModel:(FHShareCommonDataModel *)model {
    BDUGQQZoneContentItem *item = [[BDUGQQZoneContentItem alloc] initWithTitle:model.title desc:model.desc webPageUrl:model.shareUrl thumbImage:model.thumbImage imageUrl:model.imageUrl shareTye:model.shareType];
    item.activityImageName = @"qqkj_allshare";
    item.contentTitle = @"QQ空间";
    return item;
}

-(BDUGCopyContentItem *)createCopyLinkItemWithModel:(FHShareCommonDataModel *)model {
    BDUGCopyContentItem *item = [[BDUGCopyContentItem alloc] init];
    item.webPageUrl = model.shareUrl;
    item.activityImageName = @"copy_allshare";
    item.contentTitle = @"复制链接";
    return item;
}


-(FHReportContentItem *)createReportItemWithModel:(FHShareReportDataModel *)model {
    FHReportContentItem *item = [[FHReportContentItem alloc] init];
    item.activityImageName = @"report_allshare";
    item.contentTitle = @"举报";
    item.reportBlcok = model.reportBlcok;
    return item;
}

-(FHBlockContentItem *)createBlockItem {
    FHBlockContentItem *item = [[FHBlockContentItem alloc] init];
    item.activityImageName = @"shield_allshare";
    item.contentTitle = @"拉黑";
    return item;
}

-(FHDislikeContentItem *)createDislikeItem {
    FHDislikeContentItem *item = [[FHDislikeContentItem alloc] init];
    item.activityImageName = @"unlike_allshare";
    item.contentTitle = @"屏蔽";
    return item;
}

-(FHIMContentItem *)createIMItemWithModel:(FHShareIMDataModel *)model {
    FHIMContentItem *item = [[FHIMContentItem alloc] init];
    item.imShareInfo = model.imShareInfo;
    item.tracer = model.tracer;
    item.extraInfo = model.extraInfo;
    item.activityImageName = @"share_im";
    item.contentTitle = @"联系过的经纪人";
    return item;
}

-(FHCollectContentItem *)createCollectItemWithModel:(FHShareCollectDataModel *)model {
    FHCollectContentItem *item = [[FHCollectContentItem alloc] init];
    item.collectBlcok = model.collectBlcok;
    item.activityImageName = model.collected ? @"love_allshare_selected" : @"love_allshare";
    item.contentTitle = @"收藏";
    return item;
}

-(NSArray *)resetPanelItems:(NSArray *)array panelContent:(BDUGSharePanelContent *)panelContent {
    return [self createContentItemsWithModel:self.shareContentModel];
}

-(void)shareManager:(BDUGShareManager *)shareManager completedWith:(id<BDUGActivityProtocol>)activity sharePanel:(id<BDUGActivityPanelControllerProtocol>)panelController error:(NSError *)error desc:(NSString *)desc {
    NSString *imageName = error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png";
    if(desc.length > 0) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:desc indicatorImage:[UIImage imageNamed:imageName] autoDismiss:YES dismissHandler:nil];
    }
    
    NSMutableDictionary *params = self.tracerDict.mutableCopy;
    params[@"platform"] = [self activityPlatform: activity];
    [FHUserTracker writeEvent:@"share_platform" params:params];
}


- (NSString *)activityPlatform:(id<BDUGActivityProtocol>)activity {
    NSString *contentItemType = activity.contentItemType;
    if([contentItemType isEqual:BDUGActivityContentItemTypeWechat]){
        return @"weixin";
    } else if([contentItemType isEqual:BDUGActivityContentItemTypeWechatTimeLine]) {
        return @"weixin_moments";
    } else if([contentItemType isEqual:BDUGActivityContentItemTypeQQFriend]) {
        return @"qq";
    } else if([contentItemType isEqual:BDUGActivityContentItemTypeQQZone]) {
        return @"qzone";
    } else if([contentItemType isEqual:BDUGActivityContentItemTypeCopy]) {
        return @"copy";
    } else if([contentItemType isEqual:FHActivityContentItemTypeIM]) {
        return @"realtor";
    } else {
        return @"be_null";
    }
}

-(BOOL)openSnssdkUrlWith:(NSURL *)url {
    NSDictionary *queryDict = [url btd_queryItemsWithDecoding];
    NSString *scheme = [queryDict objectForKey:@"scheme"];
    NSDictionary *params = [[queryDict objectForKey:@"params"] btd_jsonDictionary];
    NSURL *openUrl = [NSURL URLWithString:scheme];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:params];
    return [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
}

-(void)hasOpenWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self.larkShareButton.paramObj = paramObj;
}

- (void)addLarkShareButtonToScreen {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.larkShareButton];
}

-(FHLarkShareButton *)larkShareButton {
    if(!_larkShareButton) {
        _larkShareButton = [[FHLarkShareButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, SCREEN_HEIGHT - 160, 40, 40)];
        [_larkShareButton setBackgroundImage:[UIImage imageNamed:@"BDUGShareLarkResource.bundle/lark_allshare"] forState:UIControlStateNormal];
        _larkShareButton.layer.cornerRadius = 20;
        _larkShareButton.layer.borderWidth = 1;
        _larkShareButton.layer.borderColor = [UIColor themeGray6].CGColor;
    }
    return _larkShareButton;
}

@end



