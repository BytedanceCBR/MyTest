//
//  TTDetailModel.m
//  Article
//
//  Created by Ray on 16/3/31.
//
//

#import "TTDetailModel.h"
#import "NewsDetailLogicManager.h"
#import "TTDetailModel+videoArticleProtocol.h"

#import <TTBaseLib/TTDeviceHelper.h>
#import <TTThemed/UIColor+TTThemeExtension.h>
#import <TTBaseLib/UIButton+TTAdditions.h>
#import <TTUIWidget/TTAlphaThemedButton.h>

extern NSString * const assertDesc_articleType;

@interface TTDetailModel ()
@property (nonatomic, strong, readwrite) ExploreDetailManager *detailManager;
@end

@implementation TTDetailModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ttDragToRoot = YES;
    }
    return self;
}

-(ExploreDetailManager *)sharedDetailManager{
    if (self.detailManagerCustomBlock) {
        BOOL shouldReturn = NO;
        ExploreDetailManager *manager = self.detailManagerCustomBlock(&shouldReturn);
        if (shouldReturn) {
            return manager;
        }
    }
    NSAssert([self.article isKindOfClass:[Article class]], assertDesc_articleType);
    if (!_detailManager) {
        NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
        [condition setValue:_adID forKey:kNewsDetailViewConditionADIDKey];
        [condition setValue:_categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
        if (self.fromSource == NewsGoDetailFromSourceVideoAlbum) {
            [condition setValue:_relateReadFromGID forKey:kNewsDetailViewConditionRelateReadFromAlbumKey];

        }
        else
        {
            [condition setValue:_relateReadFromGID forKey:kNewsDetailViewConditionRelateReadFromGID];
        }
        [condition setValue:_statParams forKey:kNewsDetailViewCustomStatParamsKey];
        [condition setValue:_gdExtJsonDict forKey:@"kNewsDetailViewExtJSONKey"];
        [condition setValue:_logPb forKey:@"kNewsDetailViewExtLogPb"];
        [condition setValue:_adLogExtra forKey:kNewsDetailViewConditionADLogExtraKey];
        _detailManager = [[ExploreDetailManager alloc] initWithArticle:self.article
                                                           orderedData:self.orderedData
                                                       umengEventLabel:self.clickLabel
                                                             adOpenUrl:self.adOpenUrl
                                                            adLogExtra:self.adLogExtra
                                                             condition:condition];
    }
    return _detailManager;
}

- (NSString *)clickLabel
{
    if (isEmptyString(_clickLabel) || ([_clickLabel isKindOfClass:[NSString class]] && _clickLabel.length <= 0)) {
        // 对于服务端在schema上附加的gd_label，如果客户端不能识别会默认为NewsGoDetailFromSourceUnknow
        // 则使用服务端给的gd_label发送统计
        if (self.fromSource == NewsGoDetailFromSourceUnknow &&
            !isEmptyString(self.gdLabel)) {
            _clickLabel = self.gdLabel;
        } else {
            self.clickLabel = [NewsDetailLogicManager articleDetailEventLabelForSource:self.fromSource categoryID:self.categoryID];
        }
    }
    return _clickLabel;
}

- (BOOL)isFromList
{
    return self.fromSource == NewsGoDetailFromSourceCategory || self.fromSource == NewsGoDetailFromSourceHeadline;
}

- (void)sendDetailTrackEventWithTag:(NSString *)tag label:(NSString *)label {
    [self sendDetailTrackEventWithTag:tag label:label extra:nil];
}

- (void)sendDetailTrackEventWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    if (self.sharedDetailManager) {
        NSString *groupId = [NSString stringWithFormat:@"%@", self.uniqueID];
        NSMutableDictionary *extValueDic = [NSMutableDictionary dictionaryWithDictionary:extra];
        if ([self.adID longLongValue]) {
            NSString *adId = [NSString stringWithFormat:@"%lld", [self.adID longLongValue]];
            extValueDic[@"ext_value"] = adId;
        }
        [extValueDic setValue:@([self.article.itemID longLongValue]) forKey:@"item_id"];
//        [extValueDic setValue:self.article.aggrType forKey:@"aggr_type"];
        NSString *source;
        if (!isEmptyString(_gdLabel)) {
            source = _gdLabel;
        }
        else {
            //        source = [NSString stringWithFormat:@"click_%@", _orderedData.categoryID];
            source = self.clickLabel;
        }
        extValueDic[@"event_type"] = @"house_app2c_v2";
        extValueDic[@"group_id"] = groupId;
        extValueDic[@"position"] = @"detail";
        if (_logPb) {
            extValueDic[@"log_pb"] = _logPb;
        } else {
            extValueDic[@"log_pb"] = self.orderedData.logPb;
        }
        if (extValueDic[@"log_pb"] == nil) {
            extValueDic[@"log_pb"] = @"be_null";
        }
        extValueDic[@"share_platform"] = label;
        extValueDic[@"enter_from"] = [self enterFromString];
        extValueDic[@"category_name"] = [self categoryName];
        extValueDic[@"event_type"] = @"house_app2c_v2";
        [TTTracker eventV3:@"rt_share_to_platform" params:extValueDic];
//        wrapperTrackEventWithCustomKeys(tag, label, groupId, source, extValueDic);
        return;
    }
    NSString *groupId = [NSString stringWithFormat:@"%lld", self.protocoledArticle.uniqueID];
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionaryWithDictionary:extra];
    if ([self.articleExtraInfo.adID longLongValue]) {
        NSString *adId = [NSString stringWithFormat:@"%lld", [self.articleExtraInfo.adID longLongValue]];
        extValueDic[@"ext_value"] = adId;
    }
    [extValueDic setValue:@([self.protocoledArticle.itemID longLongValue]) forKey:@"item_id"];
//    [extValueDic setValue:self.protocoledArticle.aggrType forKey:@"aggr_type"];

    NSString *source;
    if (!isEmptyString(_gdLabel)) {
        source = _gdLabel;
    }
    else {
        //        source = [NSString stringWithFormat:@"click_%@", _orderedData.categoryID];
        source = self.clickLabel;
    }
    extValueDic[@"event_type"] = @"house_app2c_v2";
    extValueDic[@"group_id"] = groupId;
    extValueDic[@"position"] = @"detail";
    if (_logPb) {
        extValueDic[@"log_pb"] = _logPb;
    } else {
        extValueDic[@"log_pb"] = self.orderedData.logPb;
    }

    if (extValueDic[@"log_pb"] == nil) {
        extValueDic[@"log_pb"] = @"be_null";
    }
    extValueDic[@"share_platform"] = label;
    extValueDic[@"enter_from"] = [self enterFromString];
    extValueDic[@"category_name"] = [self categoryName];
    extValueDic[@"event_type"] = @"house_app2c_v2";
    [TTTracker eventV3:@"rt_share_to_platform" params:extValueDic];
//    wrapperTrackEventWithCustomKeys(tag, label, groupId, source, extValueDic);
}

- (NSString *)uniqueID
{
    if ([self.protocoledArticle isKindOfClass:[Article class]]) {
        NSString *groupId = [NSString stringWithFormat:@"%lld", self.article.uniqueID];
        if (!groupId) {
            if (self.article.groupModel.groupID) {
                groupId = self.article.groupModel.groupID;
            }
        }
        return groupId;
    } else {
        return [@(self.protocoledArticle.uniqueID) stringValue];
    }
}

- (NSString *)categoryID {
    if (isEmptyString(_categoryID)) {
        return @"xx";
    }
    return _categoryID;
}

- (BOOL)tt_isArticleReliable {
    if (nil == self.protocoledArticle) {
        return NO;
    }
    if ([self.protocoledArticle.articleDeleted boolValue]) {
        return NO;
    }
    
    //临时加ugc发布视频特殊处理，articleType=2，后续服务端会统一下发0，去掉此逻辑。加上是为了处理后端升级前的缓存数据
    //除文章外，视频、图集统一下发articleType=0，content值可作为reliable判断依据
    if (ArticleTypeNativeContent == self.protocoledArticle.articleType ||
        ArticleTypeTempUGCVideo == self.protocoledArticle.articleType) {
        return !isEmptyString(self.protocoledArticle.articleDetailContent) && !isEmptyString(self.protocoledArticle.title);
    }else if (ArticleTypeWebContent == self.protocoledArticle.articleType) {
        return !isEmptyString(self.protocoledArticle.articleURLString);
    }
    return NO;
}

- (Article *)fitArticle {
    return self.paidArticle? :self.article;
}

- (NSString *)categoryName
{
    NSString *categoryName = self.categoryID;
    if (!categoryName || [categoryName isEqualToString:@"xx"] ) {
        categoryName = [[self enterFromString] stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }else{
        if (![[self enterFromString] isEqualToString:@"click_headline"]) {
            if ([categoryName hasPrefix:@"_"]) {
                categoryName = [categoryName substringFromIndex:1];
            }
        }
    }

    return categoryName;
}

- (NSString *)enterFromString {

    return [NewsDetailLogicManager enterFromValueForLogV3WithClickLabel:self.clickLabel categoryID:self.categoryID];
}

@end
