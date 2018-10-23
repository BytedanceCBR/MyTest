//
//  ExploreDetailManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-12-26.
//
//

#import "ExploreDetailManager.h"
#import "NewsDetailLogicManager.h"
#import "ExploreItemActionManager.h"
#import <TTAccountBusiness.h>
#import "NewsDetailConstant.h"

#import "TTUIResponderHelper.h"
#import "TTTrackerWrapper.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTRelevantDurationTracker.h"
#import "Bubble-Swift.h"


@interface ExploreDetailManager()
{
    /**
     *  是否已经加载过Article
     */
    BOOL _hasLoadedArticle;
    
    BOOL _hasSendReadContent;
    BOOL _hasSendFinishContent;
    BOOL _hasSendReadComment;
    BOOL _hasSendFinishComment;
    
}
@property(nonatomic, retain)ExploreOrderedData * orderedData;
@property(nonatomic, retain)Article * article;
@property(nonatomic, retain)NSString * eventLabel;

@property(nonatomic, retain)NSDictionary * paramDicts;
@property(nonatomic, retain)NSDictionary * gdExtJSONDict;

@property(nonatomic, retain)NSDictionary * otherExtraDic;
/**
 *  added 5.2.1 开屏广告透传open_url打开详情页广告落地页
 */
@property (nonatomic, copy) NSString *adOpenUrl;
/**
 *  图片下载器
 */
@property(nonatomic, retain)ExploreItemActionManager * itemAction;

/**
 *  用于统计停留时常的category
 */
@property(nonatomic, assign)NSTimeInterval startTime;

@property(nonatomic, assign)id logPb;

@end

@implementation ExploreDetailManager

- (void)dealloc {
}

- (id)initWithArticle:(Article *)article
          orderedData:(ExploreOrderedData *)orderedData
      umengEventLabel:(NSString *)eventLabel
            adOpenUrl:(NSString *)adOpenUrl
           adLogExtra:(nullable NSString *)adLogExtra
            condition:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.startTime = 0;
        self.article = article;
        self.orderedData = orderedData;
        self.eventLabel = eventLabel;
        self.adOpenUrl = adOpenUrl;
        self.paramDicts = dict;
        self.adLogExtra = adLogExtra;
        self.logPb = [dict objectForKey:@"kNewsDetailViewExtLogPb"];
        if (self.logPb == nil) {
            self.logPb = self.orderedData.logPb;
        }
    }
    return self;
}

#pragma mark -- public method

- (ExploreOrderedData *)currentOrderedData
{
    return _orderedData;
}

- (Article *)currentArticle
{
    if (_hasLoadedArticle) {
        return _article;
    }
    if (_article) {
        return _article;
    }
    return nil;
}

- (TTGroupModel *)currentGroupModel {
    return _article.groupModel;
}

- (NSNumber *)currentADID
{
    NSNumber *adID = isEmptyString(_orderedData.ad_id) ? nil : @(_orderedData.ad_id.longLongValue);
    if ([adID longLongValue] == 0) {
        adID = [[self currentCondition] valueForKey:kNewsDetailViewConditionADIDKey];
    }
    return adID;
}

- (NSString *)currentCategoryId {
    if ([self.paramDicts.allKeys containsObject:kNewsDetailViewConditionCategoryIDKey]) {
        return [self.paramDicts objectForKey:kNewsDetailViewConditionCategoryIDKey];
    } else if (_orderedData) {
        return  _orderedData.categoryID;
    }
    else if ([self.paramDicts.allKeys containsObject:kNewsDetailViewConditionRelateReadFromAlbumKey]) {
        return @"album";
    }
    else if ([self.paramDicts.allKeys containsObject:kNewsDetailViewConditionRelateReadFromGID]) {
        return @"related";
    }
    return @"xx";
}

- (NSDictionary *)currentCondition
{
    return _paramDicts;
}

- (void)setHasLoadedArticle
{
    _hasLoadedArticle = YES;
}

- (void)updateArticleByData:(NSDictionary *)dict
{
    if ([[dict allKeys] containsObject:@"go_detail_count"]) {
        int goDetailCount = [[dict objectForKey:@"go_detail_count"] intValue];
        _article.goDetailCount = @(goDetailCount);
    }
    
    
    if ([dict objectForKey:@"ban_bury"]) {
        _article.banBury = [NSNumber numberWithInteger:[dict integerValueForKey:@"ban_bury" defaultValue:0]];
    }
    if ([dict objectForKey:@"ban_digg"]) {
        _article.banDigg = [NSNumber numberWithInteger:[dict integerValueForKey:@"ban_digg" defaultValue:0]];
    }
    
    if ([[dict allKeys] containsObject:@"bury_count"]) {
        int buryCount = [[dict objectForKey:@"bury_count"] intValue];
        if (buryCount > _article.buryCount || [_article.banBury integerValue]) {
            _article.buryCount = buryCount;
        }
    }
    
    if ([[dict allKeys] containsObject:@"user_bury"]) {
        BOOL userBury = [[dict objectForKey:@"user_bury"] boolValue];
        _article.userBury = userBury;
    }
    
    BOOL bannComment = [[dict objectForKey:@"ban_comment"] boolValue];
    _article.banComment = bannComment;
    
    if ([[dict allKeys] containsObject:@"repin_count"]) {
        int repinCount = [[dict objectForKey:@"repin_count"] intValue];
        _article.repinCount = @(repinCount);
    }
    
    if ([[dict allKeys] containsObject:@"digg_count"]) {
        int diggCount = [[dict objectForKey:@"digg_count"] intValue];
        if (diggCount > _article.diggCount || [_article.banDigg integerValue]) {
            _article.diggCount = diggCount;
        }
    }
    
    if ([[dict allKeys] containsObject:@"like_count"]) {
        int likeCount = [[dict objectForKey:@"like_count"] intValue];
        _article.likeCount = @(likeCount);
    }
    
    if ([[dict allKeys] containsObject:@"like_desc"]) {
        NSString *friendsLikeInfo = [dict objectForKey:@"like_desc"];
        _article.likeDesc = friendsLikeInfo;
    }
    
    if ([[dict allKeys] containsObject:@"share_url"]) {
        NSString * shareURL = [dict objectForKey:@"share_url"];
        _article.shareURL = shareURL;
    }
    
    if ([[dict allKeys] containsObject:@"display_title"]) {
        NSString * displayTitle = [dict objectForKey:@"display_title"];
        _article.displayTitle = displayTitle;
    }
    
    if ([[dict allKeys] containsObject:@"display_url"]) {
        NSString * displayURL = [dict objectForKey:@"display_url"];
        _article.displayURL = displayURL;
    }
    
    if ([[dict allKeys] containsObject:@"ad_button"]) {
        NSDictionary *embededAdInfo = [dict objectForKey:@"ad_button"];
        _article.embededAdInfo = embededAdInfo;
    }

    if (![TTDeviceHelper isPadDevice]) {
        if ([[dict allKeys] containsObject:@"video_extend_link"]) {
            _article.videoExtendLink = [dict objectForKey:@"video_extend_link"];
        }
    }

    /*
     * information 接口返回的接口字段 comment_count 数字不是及时的，所以更新评论数不使用该接口字段
     *
     * 应该使用all_comments接口的total_number字段，该字段是实时更新的
     */
    
    //        if ([[dict allKeys] containsObject:@"comment_count"]) {
    //            int commentCount = [[dict objectForKey:@"comment_count"] intValue];
    //            _article.commentCount = @(commentCount);
    //        }
    
    if ([[dict allKeys] containsObject:@"user_repin"]) {
        BOOL userRepin = [[dict objectForKey:@"user_repin"] boolValue];
        _article.userRepined = userRepin;
    }
    
    if ([[dict allKeys] containsObject:@"user_digg"]) {
        BOOL userDigg = [[dict objectForKey:@"user_digg"] boolValue];
        _article.userDigg = userDigg;
    }
    
    BOOL delArticle = [[dict objectForKey:@"delete"] boolValue];
    _article.articleDeleted = @(delArticle);
    
    if ([[dict allKeys] containsObject:@"user_like"]) {
        BOOL userLike = [[dict objectForKey:@"user_like"] boolValue];
        _article.userLike = @(userLike);
    }
    
    if ([[dict allKeys] containsObject:@"media_info"]) {
        NSDictionary *mediaInfo = [dict objectForKey:@"media_info"];
        if ([_article hasVideoSubjectID]) {
            _article.detailMediaInfo = mediaInfo;
        } else {
            _article.mediaInfo = mediaInfo;
        }
        //下载订阅号头像到cache
//        NSString *avatarUrl = self.article.mediaInfo[@"avatar_url"];
//        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:avatarUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            NSLog(@"image downloaded");
//        }];
    }
    
    if ([[dict allKeys] containsObject:@"user_info"]) {
        NSDictionary *userInfo = [dict objectForKey:@"user_info"];
        if ([_article hasVideoSubjectID]) {
            NSMutableDictionary *tmpDict = _article.detailUserInfo ? [_article.detailUserInfo mutableCopy] : [NSMutableDictionary dictionary];
            [userInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [tmpDict setValue:obj forKey:key];
            }];
            _article.detailUserInfo = [tmpDict copy];
        } else {
            NSMutableDictionary *tmpDict = _article.userInfo ? [_article.userInfo mutableCopy] : [NSMutableDictionary dictionary];
            [userInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [tmpDict setValue:obj forKey:key];
            }];
            _article.userInfo = [tmpDict copy];
        }
    }
    
    if ([[dict allKeys] containsObject:@"video_watch_count"]) {
        NSInteger videoWatchCount = [[dict objectForKey:@"video_watch_count"] integerValue];
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:_article.videoDetailInfo];
        NSInteger currentWatchCount = [info[@"video_watch_count"] integerValue];
        if (videoWatchCount > currentWatchCount) {
            info[@"video_watch_count"] = @(videoWatchCount);
            _article.videoDetailInfo = info;
        }
    }
    
    if ([[dict allKeys] containsObject:@"detail_show_flags"]) {
        _article.detailShowFlags = [dict tt_boolValueForKey:@"detail_show_flags"];
    }
    
    if ([[dict allKeys] containsObject:@"read_count"]) {
        _article.readCount = [dict tt_longlongValueForKey:@"read_count"];
    }
    
    if ([[dict allKeys] containsObject:@"commoditys"]) {
        _article.commoditys = [dict arrayValueForKey:@"commoditys" defaultValue:nil];
    }
    
    [_article save];
}

- (void)extraTrackerDic:(NSDictionary *)dic
{
    self.otherExtraDic = dic;
}

#pragma mark -- util

- (void)showTipMsg:(NSString *)tip
{
    if (_delegate && [_delegate respondsToSelector:@selector(detailManager:showTipMsg:)]) {
        [_delegate detailManager:self showTipMsg:tip];
    }
}

- (void)showTipMsg:(NSString *)tip icon:(UIImage *)image
{
    if (_delegate && [_delegate respondsToSelector:@selector(detailManager:showTipMsg:icon:)]) {
        [_delegate detailManager:self showTipMsg:tip icon:image];
    }
}

- (void)showTipMsg:(NSString *)tip icon:(UIImage *)image dismissHandler:(DismissHandler)handler{
    if (_delegate && [_delegate respondsToSelector:@selector(detailManager:showTipMsg:icon:dismissHandler:)]) {
        [_delegate detailManager:self showTipMsg:tip icon:image dismissHandler:handler];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////

@implementation ExploreDetailManager(ExploreDetailCurrentStatusCategory)

// 新增的方法，针对图集，视频详情页的收藏，以强制&非强制吊起登录弹窗
- (void)changeFavoriteButtonClicked:(double)readPct viewController:(UIViewController *)viewController
{
    if (!_itemAction) {
        self.itemAction = [[ExploreItemActionManager alloc] init];
    }
        // 吊起强制&非强制的登录弹窗
        // 图集详情页的收藏
        if ([_article isImageSubject]) {
            NSMutableDictionary * param = [@{@"location":readPct>1 ? @"related":@"content"} mutableCopy];
            [param addEntriesFromDictionary:self.gdExtJSONDict];
            // 图集传入的参数 param:param trackEventTag:@"slide_detail" viewController:viewController
            [self favorFunc:param trackEventTag:@"slide_detail" viewController:viewController source:@"photo_detail_favor"];
        } else {
            // 视频详情页的收藏
            // 视频传入的参数 param:self.gdExtJSONDict trackEventTag:@"detail" viewController:viewController
            [self favorFunc:self.gdExtJSONDict trackEventTag:@"detail" viewController:viewController source:@"video_detail_favor"];
        }
}

// 收藏吊起弹窗的抽取方法,前两个传入的参数主要用于图集和视频的详情页的区分，第三个参数为要显示的viewController，第四个参数为source来源
- (void)favorFunc:(NSDictionary *)param trackEventTag:(NSString *)tag viewController:(UIViewController *)viewController source:(NSString *)source{
    if (!_article.userRepined) {
        if ([_article isVideoSubject]) {
            NSMutableDictionary *extraDic;
            if (param){
                extraDic = [NSMutableDictionary dictionaryWithDictionary:param];
            }else{
                extraDic = [NSMutableDictionary dictionary];
            }
            
            [extraDic setValue:@"video" forKey:@"article_type"];
            [extraDic setValue:[self.article.userInfo ttgc_contentID] forKey:@"author_id"];
            
            [NewsDetailLogicManager trackEventTag:tag label:@"favorite_button" value:@([self article].uniqueID) extValue:[self currentADID]  fromID:nil params:[extraDic copy] groupModel:_article.groupModel];
        }else{
            [NewsDetailLogicManager trackEventTag:tag label:@"favorite_button" value:@([self article].uniqueID) extValue:[self currentADID] fromID:nil params:param groupModel:_article.groupModel];
        }
        TTAccountLoginAlertTitleType type = TTAccountLoginAlertTitleTypeFavor;
        NSInteger favorCount = [SSCommonLogic favorCount];
        
        if ([SSCommonLogic favorDetailActionType] == 0) {
            // 策略0: 不需要登录
            // 收藏操作都会正常进行,进行原来的收藏操作
            [self didFavor:param trackEventTag:tag dismissHandler:nil];
        } else if ([SSCommonLogic favorDetailActionType] == 1) {
            // 策略1: 强制登录，需要客户端判断用户的登录状态
            if ([TTAccountManager isLogin]) {
                // 如果用户已经登录，不出现弹窗，收藏操作会正常进行
                [self didFavor:param trackEventTag:tag dismissHandler:nil];
            } else if (![TTAccountManager isLogin]) {
                // 用户处于未登录状态，需要进行强制登录，用户不登录的话无法使用后续功能
                [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        // 如果登录成功，后续功能会照常进行
                        // 进行收藏操作
                        [self didFavor:param trackEventTag:tag dismissHandler:nil];
                    } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                        // 如果退出登录，登录不成功，则后续功能不会进行
                        // 添加收藏失败的统计埋点
//                        [NewsDetailLogicManager trackEventTag:tag label:@"favorite_fail" value:[self article].uniqueID extValue:[self currentADID] fromID:nil params:param groupModel:_article.groupModel];
                    } else if (type == TTAccountAlertCompletionEventTypeTip) {
                        [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:viewController] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                            if (state == TTAccountLoginStateLogin) {
                                // 如果登录成功，则进行收藏过程
//                                [self didFavor:param trackEventTag:tag dismissHandler:nil];
                            } else if (state == TTAccountLoginStateCancelled) {
                                // 添加收藏失败的统计埋点
//                                [NewsDetailLogicManager trackEventTag:tag label:@"favorite_fail" value:[self article].uniqueID extValue:[self currentADID] fromID:nil params:param groupModel:_article.groupModel];
                            }
                        }];
                    }
                }];
            }
        } else if ([SSCommonLogic favorDetailActionType] == 2) {
            // 策略2: 非强制登录，需要客户端判断用户的登录状态
            if ([TTAccountManager isLogin]) {
                // 如果用户已登录，不出现弹窗，收藏操作会正常进行
                [self didFavor:param trackEventTag:tag dismissHandler:nil];
            } else if (![TTAccountManager isLogin]) {
                // 用户处于未登录状态，进行非强制登录弹窗
                // 非强制登录的逻辑，根据当前详情页的点击收藏的次数进行弹窗判断的逻辑
                // 得到当前详情页的点击收藏的次数，进行判断
                favorCount++;
                BOOL countEqual = NO;
                for (NSNumber *tmp in [SSCommonLogic favorDetailActionTick]) {
                    if (favorCount == tmp.integerValue) {
                        countEqual = YES;
                        // 如果等于某次非强制登录弹窗的次数，则进行弹窗
                        // 受弹窗顺序影响，0是动作生效前；1：动作生效后
                        if([SSCommonLogic favorDetailDialogOrder] == 0){
                            [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                if (type == TTAccountAlertCompletionEventTypeDone) {
                                    // 显示弹窗后，才进行收藏过程
                                    [self didFavor:param trackEventTag:tag dismissHandler:nil];
                                } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                                    // 显示弹窗后，才进行收藏过程
                                    [self didFavor:param trackEventTag:tag dismissHandler:nil];
                                } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                    [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:viewController] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                                        if (state == TTAccountLoginStateLogin) {
                                            // 如果登录成功，则进行收藏过程
//                                            [self didFavor:param trackEventTag:tag dismissHandler:nil];
                                        } else if (state == TTAccountLoginStateCancelled) {
                                            // 显示弹窗后，才进行收藏过程
                                        }
                                    }];
                                }
                            }];
                        }
                        else if([SSCommonLogic favorDetailDialogOrder] == 1){
                            [self didFavor:param trackEventTag:tag dismissHandler:^(BOOL isUserDismiss) {
                                [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                    if (type == TTAccountAlertCompletionEventTypeTip) {
                                        [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:viewController] type:TTAccountLoginDialogTitleTypeDefault source:source subscribeCompletion:^(TTAccountLoginState state) {
                                            
                                        }];
                                    }
                                }];
                            }];
                        }
                        // 找到相等次数时，break跳出循环
                        break;
                    }
                }
                if (!countEqual) {
                    // 如果不是符合的次数，则直接进行订阅操作过程
                    [self didFavor:param trackEventTag:tag dismissHandler:nil];
                }
            }
            // 将点击订阅数持久化进NSUSerDefaults
            [SSCommonLogic setFavorCount:favorCount];
        }
    } else {
        // 取消订阅
        if ([_article isVideoSubject]) {
            NSMutableDictionary *extraDic;
            if (param){
                extraDic = [NSMutableDictionary dictionaryWithDictionary:param];
            }else{
                extraDic = [NSMutableDictionary dictionary];
            }
            [extraDic setValue:@"video" forKey:@"article_type"];
            [extraDic setValue:[self.article.userInfo ttgc_contentID] forKey:@"author_id"];
            [NewsDetailLogicManager trackEventTag:@"detail" label:@"unfavorite_button" value:@(_article.uniqueID) extValue:[self currentADID] fromID:nil params:[extraDic copy] groupModel:_article.groupModel];
        }else{
            [NewsDetailLogicManager trackEventTag:tag label:@"unfavorite_button" value:@(_article.uniqueID) extValue:[self currentADID] fromID:nil params:param groupModel:_article.groupModel];
        }
        [self didUnFavor];
    }
}

//非强制登录策略下，先出收藏成功提醒，再出登录弹窗
- (void)didFavor:(NSDictionary *)param trackEventTag:(NSString *)tag dismissHandler:(DismissHandler)handler{
    [_itemAction favoriteForOriginalData:_article adID:[self currentADID] finishBlock:nil];
    if(_article.userRepined)
    {
        [self showTipMsg:NSLocalizedString(@"收藏成功", nil) icon:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] dismissHandler:handler];
    }
    // 收藏成功，统计打点 favorite_success
    [NewsDetailLogicManager trackEventTag:tag label:@"favorite_success" value:@([self article].uniqueID) extValue:[self currentADID] fromID:nil params:param groupModel:_article.groupModel];
    if ([self.article isImageSubject]) {
        [Answers logCustomEventWithName:@"favorite" customAttributes:@{@"source": @"photo"}];
        [[TTMonitor shareManager] trackService:@"favorite_success" status:1 extra:@{@"source": @"photo"}];
    }
}

// 点击取消收藏的操作
- (void)didUnFavor {
    [_itemAction unfavoriteForOriginalData:_article adID:[self currentADID] finishBlock:nil];
    if (!_article.userRepined)
    {
        [self showTipMsg:NSLocalizedString(@"取消收藏", nil) icon:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]];
    }
    
}

@end

@implementation ExploreDetailManager(ExploreDetailStayPageTracker)

- (void)startStayTracker
{
    if (_startTime == 0) {
        self.startTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)endStayTracker
{
    if (_startTime == 0) {
        return;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double duration = now - _startTime;
    self.startTime = 0;
    //kVaildStayPageMinInterval 1
    //kVaildStayPageMaxInterval 7200
    if (duration < 0 || duration > 7200) {
        return;
    }
    long long adid = [self currentADID].longLongValue;
    if (adid != 0) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:@"stay_page" forKey:@"tag"];
        [dict setValue:@"ad_wap_stat" forKey:@"label"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        // 转换成毫秒
        [dict setValue:[NSString stringWithFormat:@"%.0f", duration*1000] forKey:@"ext_value"];
        [dict setValue:@(adid) forKey:@"value"];
        [dict setValue:[@(_article.uniqueID) stringValue] forKey:@"group_id"];
        BOOL hasZzComment = self.article.zzComments.count > 0;
        [dict setValue:@(hasZzComment?1:0) forKey:@"has_zz_comment"];
        if (!isEmptyString(_article.groupModel.itemID)) {
            [dict setValue:_article.groupModel.itemID forKey:@"item_id"];
            [dict setValue:@(_article.groupModel.aggrType) forKey:@"aggr_type"];
        }
        
        if (_article.novelData) {
            [dict setValue:_article.novelData[@"book_id"] forKey:@"novel_id"];
        }

        if (!isEmptyString([[self currentOrderedData] log_extra])) {
            [dict setValue:[[self currentOrderedData] log_extra] forKey:@"log_extra"];
        }
        else if (!isEmptyString(self.adLogExtra)) {
            [dict setValue:self.adLogExtra forKey:@"log_extra"];
        }
        else {
            [dict setValue:@"" forKey:@"log_extra"];
        }
        [dict setValue:self.logPb forKey:@"log_pb"];
        [TTTrackerWrapper eventData:dict];
    }
    if (!isEmptyString(_eventLabel)) {
        
        NSMutableDictionary * dict;
        if (self.gdExtJSONDict) {
            dict = [self.gdExtJSONDict mutableCopy];
        }
        else {
            dict = [NSMutableDictionary dictionary];
        }
        
        if (!isEmptyString([[self currentOrderedData] log_extra])) {
            [dict setValue:[[self currentOrderedData] log_extra] forKey:@"log_extra"];
        }
        else {
            [dict setValue:@"" forKey:@"log_extra"];
        }
        if ([[[self currentArticle] hasVideo] boolValue]) {
            [dict setValue:@"video" forKey:@"page_type"];
        }
        
        if (_article.novelData) {
            [dict setValue:_article.novelData[@"book_id"] forKey:@"novel_id"];
        }
        
        [dict setValue:self.paramDicts[kNewsDetailViewConditionRelateReadFromGID] forKey:@"from_gid"];
        
        self.gdExtJSONDict = [dict copy];
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            NSMutableDictionary *paramsD = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJSONDict];
            [paramsD addEntriesFromDictionary:self.otherExtraDic];
            [paramsD setValue:self.logPb forKey:@"log_pb"];
            id value = @([self article].uniqueID);
            
//            [NewsDetailLogicManager trackEventTag:@"stay_page"
//                                            label:_eventLabel
//                                            value:value
//                                         extValue:[NSNumber numberWithDouble:duration]
//                                           fromID:self.paramDicts[kNewsDetailViewConditionRelateReadFromGID]
//                                             adID:[self currentADID]
//                                           params:paramsD
//                                       groupModel:_article.groupModel];
        }
        if ([[self currentADID] longLongValue] != 0) {
            [NewsDetailLogicManager trackEventTag:@"stay_page2"
                                            label:_eventLabel
                                            value:@([self article].uniqueID)
                                         extValue:[self currentADID] fromID:nil params:self.gdExtJSONDict
                                       groupModel:_article.groupModel];
        }
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.article.groupModel.groupID forKey:@"group_id"];
    [params setValue:self.article.groupModel.itemID forKey:@"item_id"];
    [params setValue:self.logPb ? : @"be_null" forKey:@"log_pb"];
    NSString* enterFrom = [self enterFromString];
    [params setValue:enterFrom forKey:@"enter_from"];
    if (![@"push" isEqualToString:enterFrom]) {
        [params setValue:[self categoryName] forKey:@"category_name"];
    }
    [params setValue:self.paramDicts[kNewsDetailViewConditionRelateReadFromGID] forKey:@"from_gid"];
    [params setValue:@((long long)(duration * 1000)).stringValue forKey:@"stay_time"];

    [[EnvContext shared].tracer writeEvent:@"stay_page" params:params];

//    [TTTrackerWrapper eventV3:@"stay_page" params:({
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJSONDict];
//        [params setValue:self.article.groupModel.groupID forKey:@"group_id"];
//        [params setValue:self.article.groupModel.itemID forKey:@"item_id"];
//        [params setValue:enterFromString forKey:@"enter_from"];
//        [params setValue:[self.paramDicts tt_stringValueForKey:kNewsDetailViewConditionCategoryIDKey] forKey:@"category_name"];
//        [params setValue:@(duration * 1000).stringValue forKey:@"stay_time"];
//        [params setValue:self.logPb forKey:@"log_pb"];
//        [params setValue:[self currentADID] forKey:@"ad_id"];
//        [params setValue:[self.article.novelData tt_stringValueForKey:@"book_id"] forKey:@"novel_id"];
//        [params addEntriesFromDictionary:self.otherExtraDic];
//        [params copy];
//    }) isDoubleSending:YES];
    
    // 注入关联时长
    [[TTRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:self.article.groupModel.groupID
                                                                          itemID:self.article.groupModel.itemID
                                                                       enterFrom:[self enterFromString]
                                                                    categoryName:[self currentCategoryId]
                                                                        stayTime:duration * 1000
                                                                           logPb:self.logPb];
}

- (NSString *)enterFromString {
    
    return [NewsDetailLogicManager enterFromValueForLogV3WithClickLabel:self.eventLabel categoryID:[self currentCategoryId]];
    
}



- (NSString *)categoryName
{
    NSString *categoryName = [self currentCategoryId];
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

/**
 *  返回当前阅读时间
 */
- (float)currentStayDuration
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double duration = now - _startTime;
    duration = MAX(MIN(duration, 7200), 1);
    return (float)duration*1000;
}

@end
