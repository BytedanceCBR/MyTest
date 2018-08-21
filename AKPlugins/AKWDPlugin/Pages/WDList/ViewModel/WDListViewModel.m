//
//  WDListViewModel.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import "WDListViewModel.h"
#import "WDApiModel.h"
#import "WDNetWorkPluginManager.h"
#import "WDDefines.h"
#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDQuestionService.h"
#import "WDParseHelper.h"
#import "WDSettingHelper.h"
#import "WDMonitorManager.h"
#import "WDCommonLogic.h"
#import "WDAnswerService.h"
#import "TTActionSheetController.h"
#import <TTImage/TTWebImageManager.h>
#import "SDWebImageManager.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTIndicatorView.h"
#import <TTAccountBusiness.h>
#import "TTAuthorizeManager.h"
#import "WDListCellViewModel.h"
#import "WDListCellDataModel.h"
#import "WDUIHelper.h"

NSString * const kWDListNeedReturnKey = @"WDListNeedReturnKey";
NSString * const kWDWendaListViewControllerUMEventName = @"question";

@interface WDListViewModel()<WDAnswerServiceProtocol>

@property (nonatomic,   copy) NSString *qID;
@property (nonatomic, strong) WDQuestionEntity *questionEntity;
@property (nonatomic,   copy) NSDictionary *apiParameter;
@property (nonatomic,   copy) NSDictionary *gdExtJson;
@property (nonatomic,   copy) NSString *channelSchema;
@property (nonatomic, assign) BOOL listPageneedReturn;

@property (nonatomic, assign) BOOL loadMoreHasMore;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isFinish;
@property (nonatomic, assign) BOOL isFailure;
@property (nonatomic, assign) CGFloat offset;

@property (nonatomic,   copy) NSArray<WDModuleStructModel> *tabModelArray;
@property (nonatomic, strong) NSMutableArray<WDListCellDataModel *> *dataModelsArray;
@property (nonatomic, strong) NSMutableArray<WDInviteUserStructModel *> *inviteUserModels;
@property (nonatomic, assign) BOOL latelyHasException;

@property (nonatomic, assign) CFTimeInterval startTime;

@property (nonatomic, strong) TTActionSheetController *actionSheetController;

@property (nonatomic, assign) NSInteger maxTitleLineCount;

//问题合并相关
@property (nonatomic, assign) WDQuestionRelatedStatus questionRelatedStatus;
@property (nonatomic, assign) BOOL canAnswer;
@property (nonatomic,   copy) NSString *relatedQuestionTitle;
@property (nonatomic,   copy) NSString *relatedQuestionSchema;
@property (nonatomic,   copy) NSString *relatedReasonUrl;

// 转发相关
@property (nonatomic, readwrite, strong) WDForwardStructModel *repostParams;

@property (nonatomic, assign) BOOL canGetRedPacket;
@property (nonatomic, assign) BOOL showRewardView;
@property (nonatomic, strong) WDProfitStructModel *profitModel;
@property (nonatomic, assign) BOOL showShareRewardView;
@property (nonatomic, strong) WDShareProfitStructModel *shareProfitModel; // 分享有礼数据

@end

@implementation WDListViewModel

- (instancetype)initWithQid:(NSString *)qid
                  gdExtJson:(NSDictionary *)gdExtJson
               apiParameter:(NSDictionary *)apiParameter
                 needReturn:(BOOL)needReturn
{
    self = [super init];
    if (self) {
        
        _qID = [qid copy];
        _gdExtJson = gdExtJson ? [gdExtJson copy] : @{};
        _apiParameter = [[WDParseHelper apiParamWithSourceApiParam:apiParameter source:kWDWendaListViewControllerUMEventName] copy];
        _listPageneedReturn = needReturn;
        
        _questionEntity = [WDQuestionEntity genQuestionEntityFromQID:qid];
        
        _loadMoreHasMore = YES;
        _canAnswer = YES;
        _isLoading = NO;
        _canGetRedPacket = NO;
        _showRewardView = NO;
        _offset = 0;
        _questionRelatedStatus = WDQuestionRelatedStatusNormal;
        
        self.dataModelsArray = (NSMutableArray<WDListCellDataModel *> *)[NSMutableArray array];
        self.inviteUserModels = [[NSMutableArray alloc] init];
        
        [WDAnswerService registerDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [WDAnswerService unRegisterDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isLoading
{
    return _isLoading;
}

- (BOOL)hasMore
{
    return _loadMoreHasMore;
}

- (BOOL)hasNiceAnswers
{
    return self.questionEntity.niceAnsCount.longLongValue > 0;
}

- (BOOL)hasAnswers {
    return (self.questionEntity.allAnsCount.integerValue > 0) ? YES : NO;
}

- (BOOL)hasTags {
    if ([self questionEntity].tagEntities.count) {
        return YES;
    }
    return NO;
}

- (BOOL)isSelf
{
    return ([TTAccountManager isLogin] && [self.questionEntity.user.user_id isEqualToString:[TTAccountManager userID]]);
}

- (BOOL)canEditTags {
//    if([self isSelf] || self.questionEntity.shouldShowEdit) {
//        return YES;
//    }
    //隐藏编辑tag的入口
    return NO;
}

- (BOOL)showInviteScrollView
{
    return (self.inviteUserModels.count > 0) && ([self.questionEntity.allAnsCount longLongValue] == 0) && [self isSelf];
}

- (BOOL)latelyHasException
{
    return _latelyHasException;
}

- (void)refresh
{
    [self _clear];
    _isLoading = NO;
}

- (void)reportQuestion
{
    if (!self.actionSheetController) {
        self.actionSheetController = [[TTActionSheetController alloc] init];
    }
    [self.actionSheetController insertReportArray:[[WDSettingHelper sharedInstance_tt]wendaQuestionReportSetting]];
    WeakSelf;
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeWendaQuestion completion:^(NSDictionary * _Nonnull parameters) {
        StrongSelf;
        [WDQuestionService reportQuestionWithQid:self.qID
                                    reportParams:parameters
                                             gid:self.qID
                                        apiParam:[self.apiParameter tt_JSONRepresentation]
                                     finishBlock:^(NSError *error, NSString *tips) {
                                         if (error) {
                                             [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报失败" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                         } else {
                                             [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                         }
                                     }];
        
    }];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.gdExtJson];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:@"question" forKey:@"tag"];
    [dict setValue:@"report" forKey:@"label"];
    [TTTracker eventData:dict];
}

- (void)requestFinishBlock:(WDWendaListManagerFinishBlock)finishBlock
{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    self.startTime = CACurrentMediaTime();
    
    [self _clear];
    
    [WDListViewModel requestForQuestionID:self.qID apiParam:self.apiParameter gdExtJson:self.gdExtJson offset:0 finishBlock:^(WDWendaV2QuestionBrowResponseModel *responseModel, NSError *error) {
        if (!error) {
            self.tabModelArray = responseModel.module_list;
            self.questionEntity = [WDQuestionEntity genQuestionEntityFromModel:responseModel.question];
            
            self.inviteUserModels = [NSMutableArray arrayWithArray:responseModel.candidate_invite_user];
            [self transNewAnswerModelToEntityAndAppendToList:responseModel.data];
            self.offset = [responseModel.offset floatValue];
            self.maxTitleLineCount = [responseModel.header_max_lines integerValue];
            
            self.loadMoreHasMore = [responseModel.has_more boolValue];
            _latelyHasException = NO;
            
            // api_param 竟然没有使用 ?? !!
            
            // 相关问题相关 could modify
            if (responseModel.related_question.banner_type) {
                self.questionRelatedStatus = [responseModel.related_question.banner_type integerValue];
            }
            if (responseModel.related_question.title) {
                self.relatedQuestionTitle = responseModel.related_question.title;
            }
            if (responseModel.related_question.question_schema) {
                self.relatedQuestionSchema = responseModel.related_question.question_schema;
            }
            if (responseModel.related_question.reason_schema) {
                self.relatedReasonUrl = responseModel.related_question.reason_schema;
            }
            if ([responseModel can_answer]) {
                self.canAnswer = [responseModel.can_answer boolValue];
            }
            // 转发相关
            if ([responseModel repost_params]) {
                self.repostParams = [responseModel repost_params];
            }
            // 分成悬赏相关
            if ([[WDSettingHelper sharedInstance_tt] isQuestionRewardUserViewShow]) {
                if (responseModel.has_profit) {
                    self.canGetRedPacket = responseModel.has_profit.boolValue;
                }
                if (responseModel.profit) {
                    self.showRewardView = YES;
                    self.profitModel = responseModel.profit;
                }
            }
            if ([[WDSettingHelper sharedInstance_tt] isQuestionShareRewardUserViewShow]) {
                if (responseModel.share_profit) {
                    self.showShareRewardView = YES;
                    self.shareProfitModel = responseModel.share_profit;
                }
            }
            // 分享相关
            [[TTWebImageManager shareManger] downloadImageWithURL:responseModel.question.share_data.image_url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
                if (error) {
                    NSLog(@"----listmodel下载分享url image");
                }
            }];
            
            self.latelyHasException = NO;
            [[TTMonitor shareManager] trackService:WDListRefreshService
                                            status:WDRequestNetworkStatusCompleted
                                             extra:[WDMonitorManager extraDicWithQuestionId:self.qID error:error]];
        } else {
            _latelyHasException = YES;
            [[TTMonitor shareManager] trackService:WDListRefreshService
                                            status:WDRequestNetworkStatusFailed
                                             extra:[WDMonitorManager extraDicWithQuestionId:self.qID error:error]];
        }
        _isFinish = YES;
        if (finishBlock) {
            finishBlock(error);
        }
        _isLoading = NO;
        NSMutableDictionary *dict = [WDMonitorManager extraDicWithQuestionId:self.qID error:error].mutableCopy;
        [dict setValue:@(0) forKey:@"getMore"];
        [WDListViewModel sendDetailTimeIntervalMonitorForService:WDListRefreshTimeService startTime:self.startTime extraData:[dict copy]];
        self.startTime = 0;
    }];
}

- (void)loadMoreFinishBlock:(WDWendaListManagerFinishBlock)finishBlock
{
    if (!_loadMoreHasMore) {
        return;
    }
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    _isFinish = NO;
    self.startTime = CACurrentMediaTime();
    
    [WDListViewModel requestForQuestionID:self.qID apiParam:self.apiParameter gdExtJson:self.gdExtJson offset:self.offset finishBlock:^(WDWendaV2QuestionBrowResponseModel *responseModel, NSError *error) {
        if (!error) {
            NSUInteger originCount = [self.dataModelsArray count];
            [self transNewAnswerModelToEntityAndAppendToList:responseModel.data];
            NSUInteger afterCount = [self.dataModelsArray count];
            self.offset = [responseModel.offset floatValue];
            self.loadMoreHasMore = [responseModel.has_more boolValue];
            if (afterCount <= originCount) {
                _latelyHasException = YES;
            } else {
                _latelyHasException = NO;
            }
            
            _isFailure = NO;
            [[TTMonitor shareManager] trackService:WDListLoadMoreService
                                            status:WDRequestNetworkStatusCompleted
                                             extra:[WDMonitorManager extraDicWithQuestionId:self.qID error:error]];
        } else {
            _latelyHasException = YES;
            
            _isFailure = YES;
            [[TTMonitor shareManager] trackService:WDListLoadMoreService
                                            status:WDRequestNetworkStatusFailed
                                             extra:[WDMonitorManager extraDicWithQuestionId:self.qID error:error]];
        }
        _isFinish = YES;
        if (finishBlock) {
            finishBlock(error);
        }
        _isLoading = NO;
        [[self class] sendDetailTimeIntervalMonitorForService:WDListLoadMoreTimeService startTime:self.startTime extraData:[WDMonitorManager extraDicWithQuestionId:self.qID error:error]];
        self.startTime = 0;
    }];
}

- (void)deleteQuestionWithFinishBlock:(void(^)(NSString *tips, NSError *error))finishBlock
{
    [WDQuestionService deleteQuestionWithQid:self.qID apiParameter:self.apiParameter finishBlock:^(WDWendaCommitDeletequestionResponseModel *responseModel, NSError *error) {
        NSString *tips = nil;
        if (error) {
            tips = error.userInfo[@"description"];
            if (!tips) {
                tips = error.localizedDescription;
            }
        }
        if (finishBlock) {
            finishBlock(tips, error);
        }
    }];
}

- (void)followQuestionWithFinishBlock:(void(^)(NSString *tips, NSError *error))finishBlock
{
    NSUInteger followType = self.questionEntity.isFollowed ? 0 : 1;
    
    [WDListViewModel trackEvent:(self.questionEntity.isFollowed ? @"unconcern_wenda" : @"concern_wenda")
                          label:kWDWendaListViewControllerUMEventName
                      gdExtJson:self.gdExtJson];
    
    [WDQuestionService followQuestionWithQid:self.qID followType:followType apiParameter:self.apiParameter finishBlock:^(WDWendaCommitFollowquestionResponseModel *responseModel, NSError *error) {
        NSString *tips = nil;
        if (!error) {
            if (responseModel.err_no.integerValue == 0) {
                self.questionEntity.isFollowed = !self.questionEntity.isFollowed;
                if (self.questionEntity.isFollowed) {
                    self.questionEntity.followCount = @(self.questionEntity.followCount.longLongValue + 1);
                } else {
                    if (self.questionEntity.followCount.longLongValue - 1 >= 0) {
                        self.questionEntity.followCount = @(self.questionEntity.followCount.longLongValue - 1);
                    } else {
                        self.questionEntity.followCount = @(0);
                    }
                }
            }
        } else {
            tips = TTNetworkConnected() ? @"" : @"网络不给力，请稍后重试";
            if (isEmptyString(tips)) {
                tips = error.userInfo[@"description"];
            }
            if (isEmptyString(tips)) {
                tips = error.localizedDescription;
            }
        }
        if (finishBlock) {
            finishBlock(tips, error);
        }
    }];
}

- (void)closePage
{
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)_clear
{
    _loadMoreHasMore = YES;
    _offset = 0;
    [_dataModelsArray removeAllObjects];
}

- (void)transNewAnswerModelToEntityAndAppendToList:(NSArray<WDWendaListCellStructModel> *)models {
    [models enumerateObjectsUsingBlock:^(WDWendaListCellStructModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WDListCellDataModel *model = [[WDListCellDataModel alloc] initWithListCellStructModel:obj];
        if (![[self uniqueIDArray] containsObject:model.uniqueId]) {
            [self.dataModelsArray addObject:model];
        }
    }];
}

- (NSArray *)answerIDArray
{
    NSMutableArray *answerIDArray = @[].mutableCopy;
    for (WDListCellDataModel *model in self.dataModelsArray) {
        if (model.hasAnswerEntity) {
            [answerIDArray addObject:model.answerEntity.ansid];
        }
    }
    return [answerIDArray copy];
}

- (NSArray *)uniqueIDArray {
    NSMutableArray *uniqueIDArray = @[].mutableCopy;
    for (WDListCellDataModel *model in self.dataModelsArray) {
        [uniqueIDArray addObject:model.uniqueId];
    }
    return [uniqueIDArray copy];
}

- (NSDictionary *)detailExtraInfoWith:(WDAnswerEntity *)answerEntity
{
    NSMutableDictionary *dict = @{}.mutableCopy;
    [dict setValue:[self answerIDArray] forKey:@"answer_list"];
    NSUInteger index = [[self answerIDArray] indexOfObject:answerEntity.ansid];
    [dict setValue:@(index) forKey:@"in_offset"];
    [dict setValue:@(self.offset) forKey:@"next_offset"];
    [dict setValue:@(self.hasMore) forKey:@"has_more"];
    [dict setValue:[self.questionEntity niceAnsCount] forKey:@"nice_answer_count"];
    return [dict copy];
}

- (NSString *)moreListAnswersTitle {
    return [NSString stringWithFormat:@"查看%lld个折叠回答",self.questionEntity.normalAnsCount.longLongValue];
}

- (NSInteger)defaultNumberOfLines {
    NSUInteger count = _maxTitleLineCount;
    if (count <= 0) {
        count = 1;
    } else if (count >= 15) {
        count = 15;
    }
    return count;
}

#pragma mark - WDAnswerServiceProtocol

- (void)answerStatusChangedWithAnsId:(NSString *)ansId actionType:(WDAnswerActionType)actionType error:(NSError *)error {
    if (!error) {
        if (actionType == WDAnswerActionTypeDelete) {
            for (WDListCellDataModel *model in self.dataModelsArray) {
                if (model.hasAnswerEntity && [model.answerEntity.ansid isEqualToString:ansId]) {
                    [self.dataModelsArray removeObject:model];
                    if (self.questionEntity.niceAnsCount.longLongValue > 0) {
                        self.questionEntity.niceAnsCount = @(self.questionEntity.niceAnsCount.longLongValue - 1);
                    }
                    break;
                }
            }
        } else if (actionType == WDAnswerActionTypePost) {
            self.questionEntity.niceAnsCount = @(self.questionEntity.niceAnsCount.longLongValue + 1);
        }
    }
}

#pragma mark - Util

+ (void)sendDetailTimeIntervalMonitorForService:(NSString *)serviceName startTime:(CFTimeInterval)startTime extraData:(NSDictionary *)extraData
{
    CFTimeInterval interval = startTime ? (CACurrentMediaTime() - startTime) * 1000.f : 0;
    NSString *intervalString = [NSString stringWithFormat:@"%.1f", interval];
    if (!isEmptyString(intervalString)) {
        [[TTMonitor shareManager] trackService:serviceName value:intervalString extra:extraData];
    }
}

@end

@implementation WDListViewModel(NetworkCategory)

+ (void)requestForQuestionID:(NSString *)qid
                    apiParam:(NSDictionary *)apiParam
                   gdExtJson:(NSDictionary *)gdExtJson
                      offset:(NSInteger)offset
                 finishBlock:(void(^)(WDWendaV2QuestionBrowResponseModel *responseModel, NSError *error))finishBlock {
    WDWendaV2QuestionBrowRequestModel *requestModel = [[WDWendaV2QuestionBrowRequestModel alloc] init];
    requestModel.qid = qid;
    requestModel.api_param = [apiParam tt_JSONRepresentation];
    requestModel.gd_ext_json = [gdExtJson tt_JSONRepresentation];
    requestModel.offset = @(offset);
    requestModel.count = @(20);
    requestModel.request_type = WDWendaListRequestTypeNICE;
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaV2QuestionBrowResponseModel *) responseModel, error);
        }
    }];
}

//和后端协商后所有的gd都透传，所以此方法不调用
+ (NSDictionary *)uploadGdExtJsonQid:(NSString *)qid gdExtJson:(NSDictionary *)originGdExtJson
{
    NSMutableDictionary *gdExtJson = @{kWDEnterFromKey : @"click_answer"}.mutableCopy;
    if (originGdExtJson[kWDEnterFromKey]) {
        gdExtJson[kWDParentEnterFromKey] = originGdExtJson[kWDEnterFromKey];
    }
    if (originGdExtJson[kWDLogPbFromKey]) {
        gdExtJson[kWDLogPbFromKey] = originGdExtJson[kWDLogPbFromKey];
    }
    
    if (originGdExtJson[@"ansid"]) {
        gdExtJson[@"enterfrom_answerid"] = originGdExtJson[@"ansid"];
    } else {
        gdExtJson[@"enterfrom_answerid"] = qid;
    }
    return [gdExtJson copy];
}

@end

@implementation WDListViewModel(WDTracker)

+ (void)trackEvent:(NSString *)event label:(NSString *)label gdExtJson:(NSDictionary *)gdExtJson
{
    if (isEmptyString(event) || isEmptyString(label)) {
        return;
    }
    
    NSMutableDictionary *dictionary = [gdExtJson mutableCopy];
    [dictionary setValue:@"umeng" forKey:@"category"];
    [dictionary setValue:event forKey:@"tag"];
    [dictionary setValue:label forKey:@"label"];
    [TTTracker eventData:dictionary];
}

@end
