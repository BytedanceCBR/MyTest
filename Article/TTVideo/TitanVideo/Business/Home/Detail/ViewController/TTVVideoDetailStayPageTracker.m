//
//  TTVVideoDetailStayPageTracker.m
//  Article
//
//  Created by pei yun on 2017/4/9.
//
//

#import "TTVVideoDetailStayPageTracker.h"
#import "KVOController.h"
#import "TTDetailModel.h"
#import "TTDetailModel+videoArticleProtocol.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "SSURLTracker.h"
#import "TTVCommentModelProtocol.h"
#import "TTRelevantDurationTracker.h"

static NSInteger const vaildStayPageMinInterval = 1;
static NSInteger const vaildStayPageMaxInterval = 7200;

@interface TTVVideoDetailStayPageTracker()
{
    BOOL _didDisAppear;
}
@property (nonatomic, assign) BOOL viewIsAppear;
@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic,strong) NSDate *commentListShowDate;
@property (nonatomic,strong) NSDate *commentDetailShowDate;

@end

@implementation TTVVideoDetailStayPageTracker

- (void)dealloc
{
    [self ttv_logBack];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithArticle:(id<TTVArticleProtocol>)article
{
    if ([super init]) {
        _article = article;
        _startTime = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification  object:nil];
    }
    return self;
}

- (void)setDetailStateStore:(TTVDetailStateStore *)detailStateStore
{
    if (detailStateStore != _detailStateStore) {
        [self.KVOController unobserve:self.detailStateStore.state];
        [_detailStateStore unregisterForActionClass:[TTVDetailStateAction class] observer:self];
        _detailStateStore = detailStateStore;
        [_detailStateStore registerForActionClass:[TTVDetailStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)actionChangeCallbackWithAction:(TTVDetailStateAction *)action state:(TTVDetailStateModel *)state
{
    switch (action.actionType) {
        case TTVDetailEventTypeViewWillAppear:{
            [self viewWillAppear];
        }
            break;
        case TTVDetailEventTypeViewDidAppear:{
            [self viewDidAppear];
        }
            break;
        case TTVDetailEventTypeViewWillDisappear:{
            [self viewWillDisappear];
        }
            break;
        case TTVDetailEventTypeViewDidDisappear:{
            [self viewDidDisappear];
        }
            break;
            
        case TTVDetailEventTypeViewDidLoad:{
            [self ttv_logGoDetail];
        }
            break;
        case TTVDetailEventTypeCommentDetailViewDidAppear:{
            [self ttv_commentDetailWillAppear];
        }
            break;
        case TTVDetailEventTypeCommentDetailViewWillDisappear:{
            [self ttv_commentDetailDidDisappear:action];
        }
            break;
        case TTVDetailEventTypeCommentListViewDidAppear: {
            [self ttv_commentListWillAppear];
        }
            break;
        case TTVDetailEventTypeCommentListViewWillDisappear:{
            [self ttv_commentListDidDisappear];
        }
            break;
        default:
            break;
    }
}
- (void)ttv_kvo
{

}

- (void)receiveDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self endStayTrack];
    if (!_didDisAppear) {
        [self ttv_logReadPctTrack];
    }
}

- (void)receiveWillEnterForegroundNotification:(NSNotification *)notification
{
    [self startStayTrack];
    //进入后台会发通知，再次进前台需清零 @liangxinyu
    self.commentListShowDate = [NSDate date];
    self.commentShowTimeTotal = 0;
}

- (void)viewWillAppear
{
    self.viewIsAppear = YES;
    [self startStayTrack];
}

- (void)viewDidAppear
{
    _didDisAppear = NO;
}

- (void)viewWillDisappear
{
    [self endStayTrack];
    self.viewIsAppear = NO;
}

- (void)viewDidDisappear
{
    [self ttv_logReadPctTrack];
    _didDisAppear = YES;
}

- (void)startStayTrack
{
    if (_startTime == 0 && _article.uniqueID > 0) {
        _startTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)endStayTrackV3WithDuration:(NSTimeInterval)duration
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self event3CommonData]];
    if ([_gdExtDict isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:_gdExtDict];
    }
    [dict setValue:_article.groupModel.itemID forKey:@"item_id"];
    [dict setValue:self.detailModel.relateReadFromGID forKey:@"from_gid"];
    [dict setValue:@(_article.groupModel.aggrType) forKey:@"aggr_type"];
    [dict setValue: [NSString stringWithFormat:@"%.0f",(duration*1000)] forKey:@"stay_time"];
    [dict setValue:@"video" forKey:@"page_type"];
    [dict setValue:_article.adModel.log_extra ? _article.adModel.log_extra : _articleExtraInfo.logExtra forKey:@"log_extra"];
    [dict setValue:@(round(self.commentShowTimeTotal)).stringValue forKey:@"stay_comment_time"];
    if (self.viewIsAppear) {
        [TTTrackerWrapper eventV3:@"stay_page" params:dict isDoubleSending:YES];
    }
}

- (void)endStayTrack
{
    if (_startTime == 0 || _article.uniqueID == 0) {
        return;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double duration = now - _startTime;
    self.startTime = 0;
    if (duration < vaildStayPageMinInterval || duration > vaildStayPageMaxInterval) {
        return;
    }
    
    if (self.commentListShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentListShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentListShowDate = nil;
        
    }

    NSMutableDictionary * dict;
    if ([_gdExtDict isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:_gdExtDict];
    } else {
        dict = [NSMutableDictionary dictionary];
    }
    id value = @(_article.uniqueID);
    [dict setValue:value forKey:@"value"];
    [dict setValue:@(duration) forKey:@"ext_value"];
    [dict setValue:@"video" forKey:@"page_type"];
    [dict setValue:value forKey:@"item_id"];
    [dict setValue:[self.detailStateStore.state ttv_fromGid] forKey:@"from_gid"];
    [dict setValue:_article.adModel.log_extra ? _article.adModel.log_extra : _articleExtraInfo.logExtra forKey:@"log_extra"];

    [dict setValue:@(_article.groupModel.aggrType) forKey:@"aggr_type"];
    [dict setValue:@(round(self.commentShowTimeTotal)).stringValue forKey:@"stay_comment_time"];
    [dict setValue:self.detailModel.logPb forKey:@"log_pb"];
    if (self.viewIsAppear) {
        [TTTrackerWrapper category:@"umeng"
                      event:@"stay_page"
                      label:self.detailModel.clickLabel
                       dict:dict];
        [self endStayTrackV3WithDuration:duration];
        [[TTRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:self.article.groupModel.groupID
                                                                              itemID:self.article.groupModel.itemID
                                                                           enterFrom:self.enterFrom
                                                                        categoryName:self.categoryName
                                                                            stayTime:duration * 1000
                                                                               logPb:self.detailModel.logPb];
        

    }
}

/**
 *  返回当前阅读时间
 */
- (float)currentStayDuration
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double duration = now - _startTime;
    duration = MAX(MIN(duration, vaildStayPageMaxInterval), vaildStayPageMinInterval);
    return (float)duration*1000;
}

#pragma mark other track
- (NSDictionary *)event3CommonData{
    NSMutableDictionary *event3Dic = [NSMutableDictionary dictionary];
    [event3Dic setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [event3Dic setValue:[self.detailModel uniqueID] forKey:@"group_id"];
    [event3Dic setValue:self.enterFrom forKey:@"enter_from"];
    [event3Dic setValue:self.detailModel.protocoledArticle.aggrType forKey:@"aggr_type"];
    [event3Dic setValue:self.categoryName forKey:@"category_name"];
    [event3Dic setValue:self.detailModel.logPb forKey:@"log_pb"];
    [event3Dic  addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
    return event3Dic;
}

- (void)ttv_logBack
{
    if (self.detailStateStore.state.clickedBackBtn) {
        wrapperTrackEvent(@"detail", @"page_close_button");
    } else {
        wrapperTrackEvent(@"detail", @"back_gesture");
    }
}

- (void)ttv_logGoDetail3
{
    NSMutableDictionary *event3Dic = [NSMutableDictionary dictionaryWithDictionary:[self event3CommonData]];
    [event3Dic setValue:self.detailModel.protocoledArticle.novelData[@"book_id"] forKey:@"novel_id"];
    NSString *mediaID = [self.detailModel.protocoledArticle.mediaInfo[@"media_id"] stringValue];
    if ([self.detailModel.protocoledArticle hasVideoSubjectID]) {
        mediaID = [self.detailModel.protocoledArticle.detailMediaInfo[@"media_id"] stringValue];
    }
    [event3Dic setValue:mediaID forKey:@"media_id"];
    [event3Dic setValue:self.detailModel.protocoledArticle.adIDStr forKey:@"ad_id"];
    
    if (self.detailModel.gdExtJsonDict && self.detailModel.gdExtJsonDict.count > 0){
        [event3Dic addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
    }
    
    BOOL hasZzComment = self.detailModel.protocoledArticle.zzComments.count > 0;
    [event3Dic setValue:@(hasZzComment ? 1 : 0) forKey:@"has_zz_comment"];

    [event3Dic setValue:@"video" forKey:@"group_type"];
    [event3Dic setValue:self.detailModel.categoryID forKey:@"category_id"];
    [event3Dic setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
    [event3Dic setValue:@"video" forKey:@"article_type"];
    
    [TTTrackerWrapper eventV3:@"go_detail" params:event3Dic isDoubleSending:YES];

}

- (void)ttv_logGoDetail
{
    [self ttv_logGoDetail3];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    id value = [self.detailModel uniqueID];
    [dic setValue:[self.detailStateStore.state ttv_adid].stringValue forKey:@"ext_value"];
    [dic setValue:value forKey:@"item_id"];
    [dic setValue:[self.detailStateStore.state ttv_aggrType] forKey:@"aggr_type"];
    [dic setValue:[self.detailModel.article.userInfo ttgc_contentID] forKey:@"author_id"];
    [dic setValue:@"video" forKey:@"article_type"];
    if (self.detailModel.gdExtJsonDict && self.detailModel.gdExtJsonDict.count > 0){
        [dic addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
    }
    BOOL hasZzComment = self.detailModel.protocoledArticle.zzComments.count > 0;
    [dic setValue:@(hasZzComment?1:0) forKey:@"has_zz_comment"];
    if (hasZzComment) {
        [dic setValue:self.detailModel.protocoledArticle.firstZzCommentMediaId forKey:@"mid"];
    }
    [dic setValue:self.detailModel.logPb forKey:@"log_pb"];
    if (![TTTrackerWrapper isOnlyV3SendingEnable]){
        if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat)
        {
            wrapperTrackEventWithCustomKeys(@"go_detail", @"click_headline", value, nil, dic);
        }
        else if (self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloatRelated)
        {
            [self ttv_addFromGId:dic];
            wrapperTrackEventWithCustomKeys(@"go_detail", @"click_related", value, nil, dic);
        }
        else
        {
            [self ttv_addFromGId:dic];
            wrapperTrackEventWithCustomKeys(@"go_detail", self.detailModel.clickLabel, value, nil, dic);
        }
    }
}

- (void)ttv_addFromGId:(NSMutableDictionary *)dic
{
    if ([dic isKindOfClass:[NSMutableDictionary class]]) {
        if (self.detailModel.relateReadFromGID) {
            [dic setValue:[NSString stringWithFormat:@"%@",self.detailModel.relateReadFromGID] forKey:@"from_gid"];
        }
    }
}


//readPct事件
- (void)ttv_logReadPctTrack
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (self.detailModel.gdExtJsonDict) {
        [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }
    
    [dict setValue:@"article" forKey:@"category"];
    [dict setValue:@"read_pct" forKey:@"tag"];
    [dict setValue:self.detailModel.clickLabel forKey:@"label"];
    [dict setValue:@(self.detailModel.protocoledArticle.uniqueID) forKey:@"value"];
    [dict setValue:self.detailModel.adID forKey:@"ext_value"];
    [dict setValue:[self.detailStateStore.state detailReadPCT] forKey:@"pct"];
    [dict setValue:@(1) forKey:@"page_count"];
    if (!isEmptyString([self.detailStateStore.state ttv_itemId])) {
        [dict setValue:[self.detailStateStore.state ttv_aggrType] forKey:@"aggr_type"];
        [dict setValue:[self.detailStateStore.state ttv_itemId] forKey:@"item_id"];
    }
    [dict setValue:self.detailModel.logPb forKey:@"log_pb"];
    [TTTrackerWrapper eventData:dict];
}

- (void)ttv_commentListWillAppear
{
    if (!self.commentListShowDate) {
        self.commentListShowDate = [NSDate date];
    }
}

- (void)ttv_commentListDidDisappear
{
    if (self.commentListShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentListShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentListShowDate = nil;
    }
}

- (void)ttv_commentDetailWillAppear
{
    [self ttv_commentListDidDisappear];
    
    if (!self.commentDetailShowDate) {
        self.commentDetailShowDate = [NSDate date];
    }
}

- (void)ttv_commentDetailDidDisappear:(TTVDetailStateAction *)action
{
    if (self.commentDetailShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentDetailShowDate];
        self.commentDetailShowTimeTotal += timeInterval*1000;
        self.commentDetailShowDate = nil;
        
        
        //关闭回复详情页埋点
        if ([action.payload conformsToProtocol:@protocol(TTVCommentModelProtocol)]) {
            id <TTVCommentModelProtocol> commentModel =  (id <TTVCommentModelProtocol>)action.payload;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:commentModel.groupModel.itemID forKey:@"item_id"];
            [dic setValue:commentModel.groupModel.groupID forKey:@"group_id"];
            [dic setValue:commentModel.userID forKey:@"to_user_id"];
            [dic setValue:commentModel.commentID forKey:@"comment_id"];
            [dic setValue:@"detail" forKey:@"position"];
            [dic setValue:@(round(self.commentDetailShowTimeTotal)).stringValue forKey:@"stay_time"];
            
            [TTTracker eventV3:@"comment_close" params:dic];
        }
    }
}

#pragma mark -
#pragma mark helper

- (NSMutableDictionary *)screenContext
{
    NSMutableDictionary *screenContext = [[NSMutableDictionary alloc] init];
    [screenContext setValue:self.detailModel.adID forKey:@"ad_id"];
    [screenContext setValue:self.detailModel.protocoledArticle.itemID forKey:@"item_id"];
    [screenContext setValue:@(self.detailModel.protocoledArticle.uniqueID) forKey:@"group_id"];
    return screenContext;
}

@end
