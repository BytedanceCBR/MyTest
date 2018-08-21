//
//  WDMoreListViewModel.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import "WDMoreListViewModel.h"
#import "WDApiModel.h"
#import "WDNetWorkPluginManager.h"
#import "WDDefines.h"
#import "WDSettingHelper.h"
#import "WDParseHelper.h"
#import "WDMoreListCellViewModel.h"
#import "TTNetworkManager.h"
#import <TTBaseLib/JSONAdditions.h>
#import "WDCommonLogic.h"
#import "TTImageInfosModel.h"
#import "WDQuestionFoldReasonEntity.h"
#import "WDAnswerService.h"
#import "WDListCellDataModel.h"

NSString * const kWDWendaListMorePageSource = @"question_fold";
NSString * const kWDWendaMoreListViewControllerUMEventName = @"question";

@interface WDMoreListViewModel()<WDAnswerServiceProtocol>

@property (nonatomic, copy) NSString * qID;
@property (nonatomic, copy) NSDictionary *apiParameter;
@property (nonatomic, copy) NSDictionary *gdExtJson;

@property (nonatomic, assign) BOOL loadMoreHasMore;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isFinish;
@property (nonatomic, assign) BOOL isFailure;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) BOOL latelyHasException;
@property (nonatomic, strong) NSMutableArray<WDListCellDataModel *> *dataModelsArray;

@end

@implementation WDMoreListViewModel

- (instancetype)initWithQid:(NSString *)qid
                  gdExtJson:(NSDictionary *)gdExtJson
               apiParameter:(NSDictionary *)apiParameter
{
    self = [super init];
    if (self) {
        _qID = qid;
        _gdExtJson = [gdExtJson copy];
        _apiParameter = [[WDParseHelper apiParamWithSourceApiParam:apiParameter source:kWDWendaListMorePageSource] copy];
        
        _loadMoreHasMore = YES;
        _isLoading = NO;
        _offset = 0;
        
        self.dataModelsArray = (NSMutableArray<WDListCellDataModel *> *)[NSMutableArray array];
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

- (BOOL)latelyHasException
{
    return _latelyHasException;
}

- (void)refresh
{
    [self _clear];
    _isLoading = NO;
}

- (void)requestFinishBlock:(WDWendaMoreListManagerFinishBlock)finishBlock
{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    [self _clear];
    [WDMoreListViewModel requestForQuestionID:self.qID apiParam:self.apiParameter gdExtJson:self.gdExtJson offset:0 finishBlock:^(WDWendaV2QuestionBrowResponseModel *responseModel, NSError *error) {
        if (!error) {
            [self transModelToEntityAndAppendToList:responseModel.data];
            self.offset = [responseModel.offset floatValue];
            self.loadMoreHasMore = [responseModel.has_more boolValue];
            _latelyHasException = NO;
        } else {
            _latelyHasException = YES;
        }
        _isFinish = YES;
        if (finishBlock) {
            finishBlock(error);
        }
        _isLoading = NO;
    }];
}

- (void)loadMoreFinishBlock:(WDWendaMoreListManagerFinishBlock)finishBlock
{
    if (!_loadMoreHasMore) {
        return;
    }
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    _isFinish = NO;
    [WDMoreListViewModel requestForQuestionID:self.qID apiParam:self.apiParameter gdExtJson:self.gdExtJson offset:self.offset finishBlock:^(WDWendaV2QuestionBrowResponseModel *responseModel, NSError *error) {
        if (!error) {
            NSUInteger originCount = [self.dataModelsArray count];
            [self transModelToEntityAndAppendToList:responseModel.data];
            NSUInteger afterCount = [self.dataModelsArray count];
            self.offset = [responseModel.offset floatValue];
            self.loadMoreHasMore = [responseModel.has_more boolValue];
            if (afterCount <= originCount) {
                _latelyHasException = YES;
            } else {
                _latelyHasException = NO;
            }
            _isFailure = NO;
        } else {
            _latelyHasException = YES;
            _isFailure = YES;
        }
        _isFinish = YES;
        if (finishBlock) {
            finishBlock(error);
        }
        _isLoading = NO;
    }];
}

- (void)_clear
{
    _loadMoreHasMore = YES;
    _offset = 0;
    [_dataModelsArray removeAllObjects];
}

- (void)setQuestionFoldReasonDataWithModel:(WDAnswerFoldReasonStructModel *)foldReasonModel {
    self.questionEntity.foldReasonEntity = [[WDQuestionFoldReasonEntity alloc] initWithModel:foldReasonModel];
    self.questionEntity.foldReasonId = self.questionEntity.foldReasonEntity.openURL;
}

- (void)transModelToEntityAndAppendToList:(NSArray<WDWendaListCellStructModel> *)models {
    [models enumerateObjectsUsingBlock:^(WDWendaListCellStructModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WDListCellDataModel *model = [[WDListCellDataModel alloc] initWithListCellStructModel:obj];
        if (![[self uniqueIDArray] containsObject:model.uniqueId]) {
            [self.dataModelsArray addObject:model];
        }
    }];
}

- (WDQuestionEntity *)questionEntity
{
    WDQuestionEntity *entity = [WDQuestionEntity genQuestionEntityFromQID:_qID];
    return entity;
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
    NSArray *niceIDS = [self.questionEntity answerIDS];
    NSMutableArray *allIDS = niceIDS.mutableCopy;
    [allIDS addObjectsFromArray:[self answerIDArray]];
    [dict setValue:allIDS forKey:@"answer_list"];
//    NSUInteger index = [self.answerEntitys indexOfObject:answerEntity];
    NSUInteger index = [[self answerIDArray] indexOfObject:answerEntity.ansid];
    [dict setValue:@(index + niceIDS.count) forKey:@"in_offset"];
    [dict setValue:@(self.offset) forKey:@"next_offset"];
    [dict setValue:@(self.hasMore) forKey:@"has_more"];
    [dict setValue:[self.questionEntity niceAnsCount] forKey:@"nice_answer_count"];
    return [dict copy];
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
        }
    }
}

@end


@implementation WDMoreListViewModel(NetworkCategory)

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
    requestModel.request_type = WDWendaListRequestTypeNORMAL;
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaV2QuestionBrowResponseModel *) responseModel, error);
        }
    }];
}

@end

@implementation WDMoreListViewModel(WDTracker)

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

