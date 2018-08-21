//
//  WDDetailModel.m
//  Article
//
//  Created by 延晋 张 on 16/8/30.
//
//

#import "WDDetailModel.h"
#import "WDMonitorManager.h"
#import "WDParseHelper.h"
#import "WDAnswerEntity.h"
#import "WDMonitorManager.h"
#import "WDCommonLogic.h"

#import "TTAlphaThemedButton.h"
#import "SDWebImageManager.h"
#import "TTWebImageManager.h"
#import "TTAdPromotionManager.h"
#import <TTBaseLib/JSONAdditions.h>
#import <TTRoute/TTRoute.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>

NSString * const kWDDetailNeedReturnKey = @"need_return";
NSString * const kWDDetailShowReport = @"detail_related_report_style";

NSString * const kWDDetailViewControllerUMEventName = @"answer_detail";

NSString * const kWDDetailNatantTagsKey = @"kWDDetailNatantTagsKey";
NSString * const kWDDetailNatantRelatedKey = @"WDDetailNatantRelated";
NSString * const kWDDetailNatantAdsKey = @"WDDetailNatantAdsKey";
NSString * const kWDDetailNatantLikeAndRewardsKey = @"WDDetailNatantLikeAndRewards";

@interface WDDetailModel ()

@property (nonatomic, strong) NSDictionary *gdExtJsonDict;
@property (nonatomic, strong) NSDictionary *apiParam;

@property (nonatomic,   copy) NSString *insertedContextJS;
@property (nonatomic,   copy) NSString *etag;
@property (nonatomic,   copy) NSDictionary *ordered_info;
@property (nonatomic,   copy) NSArray *classNameList;
@property (nonatomic,   copy) NSString *questionSchema;
@property (nonatomic,   copy) NSString *rid;

@property (nonatomic, strong, nullable, readwrite) WDForwardStructModel *repostParams;

@end

@implementation WDDetailModel

- (instancetype)initWithAnswerId:(NSString *)answerID params:(NSDictionary *)params {
    if (self = [super init]) {
        NSDictionary *gdExtJson = [WDParseHelper gdExtJsonFromBaseCondition:params];
        NSDictionary *apiParam =  [WDParseHelper apiParamWithSourceApiParam:[WDParseHelper apiParamFromBaseCondition:params] source:kWDDetailViewControllerUMEventName];
        _gdExtJsonDict = gdExtJson ? [gdExtJson copy] : @{};
        NSDictionary *innerLogPb = [_gdExtJsonDict objectForKey:@"log_pb"];
        if (!innerLogPb) {
            NSDictionary *outerLogPb = [params objectForKey:@"log_pb"];
            if (outerLogPb) {
                NSMutableDictionary *newGdExtJson = [NSMutableDictionary dictionaryWithDictionary:_gdExtJsonDict];
                [newGdExtJson setObject:outerLogPb forKey:@"log_pb"];
                _gdExtJsonDict = [newGdExtJson copy];
            }
        }
        _apiParam = apiParam ? [apiParam copy] : @{};
        _useCDN = YES;
        _hasNext = YES;
        _answerEntity = [WDAnswerEntity generateAnswerEntityFromAnsid:answerID];
        _relatedReportStyle = [WDCommonLogic relatedReportStyle];
        
        BOOL isJumpComment = NO;
        if ([params tt_boolValueForKey:@"is_jump_comment"]) {
            isJumpComment = [params tt_boolValueForKey:@"is_jump_comment"];
        }
        _isJumpComment = isJumpComment;
        
        NSString *msgId = nil;
        if ([params tt_stringValueForKey:@"msg_id"]) {
            msgId = [params tt_stringValueForKey:@"msg_id"];
        }
        _msgId = msgId;
        
        NSString *isRequstSelf = [params objectForKey:@"type"];
        if ([isRequstSelf isEqualToString:@"new"] || ([[TTAccountManager userID] isEqualToString:_answerEntity.user.userID])) {
            _useCDN = NO;
            _answerEntity.content = nil;
        }
        
        if ([params.allKeys containsObject:@"showcomment"]) {
            _showComment = ((NSNumber *)[params objectForKey:@"showcomment"]).boolValue;
        }
        
        if ([params valueForKey:@"answer_tips"]) {
            _answerTips = [params tt_dictionaryValueForKey:@"answer_tips"];
        }
        
        if ([params valueForKey:@"hide_answer_button"]) {
            _shouldHideAnswerButton = [params tt_boolValueForKey:@"hide_answer_button"];
        }
        
        if ([params valueForKey:@"rid"]) {
            _rid = [params tt_stringValueForKey:@"rid"];
        }
        
        if ([params valueForKey:@"is_hidden_head"]) {
            _shouldHideHeader = [params tt_boolValueForKey:@"is_hidden_head"];
        }
    }
    return self;
}

- (void)updateDetailModelWithExtraData:(nonnull NSDictionary *)wendaExtra
{
    [self.answerEntity updateWithDetailWendaExtra:wendaExtra];
    if (wendaExtra) {
        NSDictionary *show_post_answer_strategy = [wendaExtra objectForKey:@"show_post_answer_strategy"];
        if (show_post_answer_strategy && [show_post_answer_strategy isKindOfClass:[NSDictionary class]]) {
            NSDictionary *show_top = [show_post_answer_strategy objectForKey:@"show_top"];
            if (show_top && [show_top isKindOfClass:[NSDictionary class]]) {
                self.showPostAnswer = NO;
                self.postAnswerText = [show_top objectForKey:@"text"];
            }
        }
    }
}

- (void)updateDetailModelWith:(nonnull WDWendaAnswerInformationResponseModel *)responseModel
{
    self.shareImgUrl = responseModel.share_img;
    self.shareTitle = responseModel.share_title;
    self.insertedContextJS = responseModel.context;
    self.etag = responseModel.etag;
    self.answerEntity.shareURL = responseModel.share_url;
    self.answerEntity.userRepined = responseModel.user_repin.boolValue;
    self.answerEntity.answerDeleted = responseModel.wendaDelete.boolValue;
    self.answerEntity.mediaInfo = [WDDetailModel dictionaryWith:responseModel.media_info];
    self.answerEntity.postAnswerSchema = responseModel.post_answer_schema;
    self.answerEntity.userRepined = responseModel.user_repin.boolValue;
    self.questionSchema = responseModel.question_schema;
    if (responseModel.activity.redpack) {
        self.redPack = responseModel.activity.redpack;
        self.needSendRedPackFlag = YES;
    }
    @try {
        self.answerEntity.mediaInfo = [responseModel.media_info toDictionary];
        self.adPromotion = [responseModel.recommend_sponsor toDictionary];
    }
    @catch (NSException *exception) {
        // nothing to do...
    }
    
    [self relatedOrderInfoWithArr:responseModel.ordered_info];

    if (responseModel.wenda_data) {
        WDDetailWendaStructModel *wendaStruct = responseModel.wenda_data;
        [self.answerEntity updateWithInfoWendaData:wendaStruct];
    }
    if (responseModel.next_item_struct) {
        self.hasNextData = YES;
        self.nextAnsid = responseModel.next_item_struct.next_ansid;
        self.nextAnswerSchema = responseModel.next_item_struct.next_answer_schema;
        self.allAnswerText = responseModel.next_item_struct.all_answer_text;
        self.nextAnswerText = responseModel.next_item_struct.next_answer_text;
        self.showToast = [responseModel.next_item_struct.show_toast boolValue];
        self.hasNext = [responseModel.next_item_struct.has_next boolValue];
    }
    if (responseModel.err_tips) {
        self.err_tips = responseModel.err_tips;
    }
    // 引导提示相关
    if (responseModel.show_tips) {
        self.showTips = responseModel.show_tips.boolValue;
    }
    // 转发相关
    if (responseModel.repost_params) {
        self.repostParams = responseModel.repost_params;
    }
    // 红包相关
    if (responseModel.profit_label) {
        self.answerEntity.profitLabel = responseModel.profit_label;
    }
    
    //先把图片下载了，防止在分享的时候没有
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.shareImgUrl] options:SDWebImageRefreshCached  progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        self.shareImg = image;
    }];
    

    [self.answerEntity save];
}

#pragma mark - Public Util Content

- (void)openListPage
{
    if (!isEmptyString(self.questionSchema) && [NSURL URLWithString:self.questionSchema]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.questionSchema] userInfo:nil];
    } else if ([NSURL URLWithString:self.listSchema]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.listSchema] userInfo:nil];
    }
}

- (BOOL)isArticleReliable
{
    if (self.answerEntity.answerDeleted) {
        return NO;
    }
    
    return !isEmptyString(self.answerEntity.content);
}

- (NSString *)enterFrom
{
    return self.gdExtJsonDict[kWDEnterFromKey];
}

- (nullable NSString *)parentEnterFrom
{
    return self.gdExtJsonDict[kWDParentEnterFromKey];
}

- (BOOL)needReturn
{
    if ([self.dataSource respondsToSelector:@selector(needReturn)]) {
        return [self.dataSource needReturn];
    }
    return NO;
}

- (BOOL)isContentHasFetched
{
    if (!isEmptyString(self.answerEntity.content) && self.answerEntity.content) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDictionary *)newsDetailRightButtons
{
    //escape barButton
    NSMutableDictionary *rightButtonItems = [NSMutableDictionary dictionary];
    TTAlphaThemedButton *moreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    [moreButton setImage:[UIImage themedImageNamed:@"new_more_titlebar.png"] forState:UIControlStateNormal];
    [moreButton sizeToFit];
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
    } else {
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
    }
    
    rightButtonItems[@"MoreBarButtonKey"] = moreButton;
    return [rightButtonItems copy];
}

- (nonnull WDDetailUserPermission *)userPermission
{
    return self.answerEntity.userPermission;
}

- (NSString *)listSchema
{
    NSMutableDictionary *gdExtJson = [[NSMutableDictionary alloc] init];
    [gdExtJson setValue: @"click_header" forKey:kWDEnterFromKey];
    [gdExtJson setValue:self.answerEntity.qid forKey:@"qid"];
    [gdExtJson setValue:self.answerEntity.ansid forKey:@"ansid"];
    NSDictionary *apiParam = [WDParseHelper routeJsonWithOriginJson:self.apiParam source:kWDDetailViewControllerUMEventName];
    NSMutableString * urlStr = [NSMutableString stringWithFormat:@"sslocal://wenda_list?qid=%@", self.answerEntity.qid];
    [urlStr appendFormat:@"&gd_ext_json=%@", [gdExtJson tt_JSONRepresentation]];
    [urlStr appendFormat:@"&api_param=%@", [apiParam tt_JSONRepresentation]];
    NSString *fixStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    fixStr = [fixStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return  fixStr;
}

#pragma mark - Util Methods

+ (NSDictionary *)dictionaryWith:(WDDetailMediaInfoStructModel *)mediaInfoModel
{
    NSMutableDictionary *dict = @{}.mutableCopy;
    [dict setValue:mediaInfoModel.avatar_url forKey:@"avatar_url"];
    [dict setValue:mediaInfoModel.media_id forKey:@"media_id"];
    [dict setValue:mediaInfoModel.name forKey:@"name"];
    [dict setValue:mediaInfoModel.subscribed forKey:@"subcribed"];
    return [dict copy];
}


- (void)relatedOrderInfoWithArr:(NSArray<WDOrderedItemInfoStructModel> *)arr {
    if (!arr || ![arr isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableArray * natantClassNameList = [NSMutableArray arrayWithCapacity:arr.count];
    NSMutableDictionary * relatedArticles = [[NSMutableDictionary alloc] init];
    for (WDOrderedItemInfoStructModel *structModel in arr) {
        if ([structModel.name isEqualToString:@"labels"] && [structModel.data count]) {
            [natantClassNameList addObject:@"WDDetailNatantTagsView"];
            [relatedArticles setValue:structModel.data forKey:kWDDetailNatantTagsKey];
        }
        if ([structModel.name isEqualToString:@"related_news"] && [structModel.data count]) {
            [natantClassNameList addObject:@"WDDetailNatantRelateArticleGroupView"];
            [relatedArticles setValue:structModel.data forKey:kWDDetailNatantRelatedKey];
        } else if ([structModel.name isEqualToString:@"ad"] && structModel.ad_data) {
            [natantClassNameList addObject:@"TTWDDetailADContainerView"];
            [relatedArticles setValue:structModel.ad_data forKey:kWDDetailNatantAdsKey];
        } else if ([structModel.name isEqualToString:@"like_and_rewards"] && ((self.relatedReportStyle == WDDetailReportStyleRelatedReport) || (self.relatedReportStyle == WDDetailReportStyleDoubleDigg))) {
            [natantClassNameList addObject:@"WDDetailNatantRewardView"];
            [relatedArticles setValue:structModel.related_data forKey:kWDDetailNatantLikeAndRewardsKey];
        }
    }
    [natantClassNameList addObject:@"WDCommentReposNatantHeaderView"];
    self.ordered_info = relatedArticles;
    self.classNameList = natantClassNameList;
}

- (id)adNatantDataModel:(NSString *)key4Data {
    return self.ordered_info[key4Data];
}

@end

@implementation WDDetailModel (Track)

- (void)sendDetailTrackEventWithTag:(NSString *)tag label:(NSString *)label {
    [self sendDetailTrackEventWithTag:tag label:label extra:nil];
}

- (void)sendDetailTrackEventWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra
{
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJsonDict];
    [extValueDic setValue:self.answerEntity.ansid forKey:@"item_id"];
//    [extValueDic setValue:@(0) forKey:@"aggr_type"];
    ttTrackEventWithCustomKeys(tag, label, self.answerEntity.ansid, self.enterFrom, extValueDic);
}

@end
