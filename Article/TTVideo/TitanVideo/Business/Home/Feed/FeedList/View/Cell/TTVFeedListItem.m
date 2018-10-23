//
//  TTVFeedListItem.m
//  Article
//
//  Created by panxiang on 2017/4/13.
//
//

#import "TTVFeedListItem.h"
#import "TTVFeedItem+Extension.h"
#import "TTDeviceUIUtils.h"
#import "JSONAdditions.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTVDetailRelatedRecommendCellViewModel.h"
#import "TTNetworkManager.h"
extern CGFloat adBottomContainerViewHeight(void);
extern CGFloat ttv_bottomPaddingViewHeight(void);

TTVFeedListCellSeparatorStyle ttv_feedListCellSeparatorStyleByTotalAndRow(NSInteger total,NSInteger row)
{
    TTVCellGroupStyle cellGroupStyle = ttv_cellGroupStyleByTotalAndRow(total, row);
    if (cellGroupStyle == TTVCellGroupStyleTop || cellGroupStyle == TTVCellGroupStyleMiddle) {
        return TTVFeedListCellSeparatorStyleHas;
    }
    return TTVFeedListCellSeparatorStyleNone;
}


@implementation TTVFeedListItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    return adBottomContainerViewHeight() + (self.cellSeparatorStyle == TTVFeedListCellSeparatorStyleHas ? ttv_bottomPaddingViewHeight() + [TTDeviceHelper ssOnePixel] : 0);
}

- (TTVVideoArticle *)article
{
    return [self.originData article];
}

- (BOOL)isPlayInDetailView
{
    return [self.originData isPlayInDetailView];
}

- (BOOL)supportVideoProportion
{
    BOOL result = [[[TTSettingsManager sharedManager] settingForKey:@"video_detail_flexbile_proportion_enabled" defaultValue:@NO freeze:NO] boolValue];
    if ([self.categoryId isEqualToString:@"subv_ugc"]) {
        return result && [self article].videoProportion > 0;
    } else {
        return result && [self article].videoProportion > 0;
    }
}

- (void)ttv_addShareTrcker{
    if (!_shareTracker) {
        _shareTracker = [[TTVShareActionsTracker alloc] init];
    }
    TTVVideoArticle *article= [self article];
    _shareTracker.categoryName = self.categoryId;
    _shareTracker.groupID = [self.originData uniqueIDStr];
    _shareTracker.itemID = [NSString stringWithFormat:@"%lld",article.itemId];
    _shareTracker.adId = [self article].adId;
    _shareTracker.position = @"list";
    _shareTracker.platform = [NSString stringWithFormat:@"%ld",(long)0];//TTSharePlatformTypeOfMain
    _shareTracker.source = @"video";
    _shareTracker.enterFrom = @"click_category";
    TTVUserInfo *userInfo = self.originData.videoUserInfo;
    _shareTracker.authorId = [NSString stringWithFormat:@"%lld", userInfo.userId ];
    NSDictionary *dic = [self.originData.logPb tt_JSONValue];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        _shareTracker.logPb = dic;
    }
}

-(nullable TTADTrackEventLinkModel *)adEventLinkModel{
    NSString *adIdString = [self article].adId;
    if (isEmptyString(adIdString)) {
        return nil;
    }
    
    NSString *logExtraString = [self article].logExtra;
    if (isEmptyString(logExtraString)) {
        logExtraString = @"";
    }
    
    TTADTrackEventLinkModel *result = _adEventLinkModel;
    if (result) {
        return result;
    }
    result = [[TTADTrackEventLinkModel alloc] init];
    
    result.adID = adIdString;
    result.logExtra = logExtraString;
    _adEventLinkModel = result;
    
    return result;
}

- (NSDictionary *)realTimeAdExtraData:(NSString *)tag label:(NSString *)label extraData:(NSDictionary *)extraData
{
    NSMutableDictionary *events = [@{} mutableCopy];
    NSMutableDictionary *adExtraData = [NSMutableDictionary dictionary];
    NSDictionary *linkExtra = [self.adEventLinkModel adEventLinkDictionaryWithTag:tag WithLabel:label];
    [adExtraData addEntriesFromDictionary:linkExtra];
    
    NSString *extraString = [extraData objectForKey:@"ad_extra_data"];
    if (!isEmptyString(extraString)) {
        NSError *error = nil;
        NSDictionary *extraJsonDic = [NSString tt_objectWithJSONString:extraString error:&error];
        [adExtraData addEntriesFromDictionary:extraJsonDic];
    }
    NSString *finalString = [adExtraData tt_JSONRepresentation];
    [events setValue:finalString forKey:@"ad_extra_data"];
    return events;
}

- (void)fetchRecommendArray:(void (^ __nullable)(NSError * error))comleteBLC
{
    NSString *urlString = [self p_getAPIPrefix];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[self userId] forKey:@"follow_user_id"];
    [params setValue:@"follow" forKey:@"scene"];
    [params setValue:self.categoryId forKey:@"source"];
    [params setValue:[NSString stringWithFormat:@"%lld", self.originData.article.groupId] forKey:@"group_id"];
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (!error) {
            NSMutableArray *userCards = [TTVDetailFollowUserRecommendInfoModel arrayOfModelsFromDictionaries:[jsonObj tt_arrayValueForKey:@"user_cards"]];
            for (int i = 0; i < userCards.count; i++) {
                TTVDetailFollowUserRecommendInfoModel *model = [userCards objectAtIndex:i];
                if (!isEmptyString(model.user.info.avatar_url) && !isEmptyString(model.user.info.name) &&
                    !isEmptyString(model.recommend_reason) && !isEmptyString(model.user.info.user_id)) {
                    TTVDetailRelatedRecommendCellViewModel *cellViewModel = [[TTVDetailRelatedRecommendCellViewModel alloc] init];
                    cellViewModel.infoModel = model;
                    if (!self.recommendArray) {
                        self.recommendArray = [NSMutableArray array];
                    }
                    [self.recommendArray addObject:cellViewModel];
                }
            }
            if (self.recommendArray.count > 0) {
                self.recommendViewHeight = [TTDeviceUIUtils tt_newPadding:223];
                self.showRelatedRecommendView = YES;
            }
            
        }
        comleteBLC(error);
    }];
}

- (NSString *)p_getAPIPrefix
{
    return [NSString stringWithFormat:@"%@/user/relation/user_recommend/v1/supplement_recommends/", [CommonURLSetting baseURL]];
}

- (NSString *)userId
{
    NSString *userId = [NSString stringWithFormat:@"%lld", self.originData.videoUserInfo.userId];
    return userId;
}


@end
