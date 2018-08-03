//
//  WDDetailSlideViewModel.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/5.
//
//

#import "WDDetailSlideViewModel.h"
#import "WDFetchAnswerContentHelper.h"
#import "WDDetailModel.h"
#import "WDAnswerEntity.h"
#import "WDParseHelper.h"
#import "WDNetWorkPluginManager.h"
#import "WDSettingHelper.h"
#import "NSObject+FBKVOController.h"

@interface WDDetailSlideViewModel ()

@property (nonatomic, strong, nullable) WDFetchAnswerContentHelper *fetchContentHelper;
@property (nonatomic, strong, nullable) TTRouteParamObj *paramObj;
@property (nonatomic, assign, readwrite) BOOL hasCountChange;
@property (nonatomic, assign, readwrite) BOOL hasGetAllAnswers;
@property (nonatomic, assign, readwrite) BOOL isOnlyAnswer;
@property (nonatomic, assign, readwrite) NSInteger showSlideType;
@property (nonatomic, strong, readwrite) WDDetailModel *initialDetailModel;

@end

@implementation WDDetailSlideViewModel

#pragma mark - lifestyle

- (void)dealloc {
    
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        self.paramObj = paramObj;
        self.fetchContentHelper = [[WDFetchAnswerContentHelper alloc] initWithRouteParamObj:paramObj];
        self.currentDetailModel = self.initialDetailModel;
        self.showSlideType = [[WDSettingHelper sharedInstance_tt] wdAnswerDetailShowSlideType];
        self.ansItemsArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - public

- (void)fetchContentFromRemoteIfNeededWithComplete:(nullable WDFetchRemoteContentBlock)block {
    [self.fetchContentHelper fetchContentFromRemoteIfNeededWithComplete:block];
}

// 是不是可以从detailModel中取值？
- (void)startFetchAnswerListWithResult:(void(^)(NSError *error))resultBlock {
    NSString *ansId = self.initialDetailModel.answerEntity.ansid;
    NSDictionary *params = self.paramObj.allParams;
    if (self.ansItemsArray.count > 0) {
        WDNextItemStructModel *lastModel = [self.ansItemsArray lastObject];
        ansId = lastModel.ansid;
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:lastModel.schema]];
        params = paramObj.allParams;
    }
    NSDictionary *gdExtJson = [WDParseHelper gdExtJsonFromBaseCondition:params];
    NSDictionary *apiParam =  [WDParseHelper apiParamWithSourceApiParam:[WDParseHelper apiParamFromBaseCondition:params] source:kWDDetailViewControllerUMEventName];
    NSString *enterFrom = [gdExtJson objectForKey:@"enter_from"];
    self.hasCountChange = NO;
    [WDDetailSlideViewModel startFetchAnswerListWithAnswerID:ansId enterFrom:enterFrom gdExtJson:[gdExtJson JSONRepresentation] apiParameter:[apiParam JSONRepresentation] finishBlock:^(WDWendaAnswerListResponseModel *responseModel, NSError *error) {
        if (!error) {
            [self setAnswerListFromModel:responseModel];
        }
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

- (TTRouteParamObj *)getRouteParamObjWithIndex:(NSInteger)index {
    WDNextItemStructModel *itemModel = [self.ansItemsArray objectAtIndex:index];
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:itemModel.schema]];
    return paramObj;
}

- (BOOL)isFirstFoldAnswerWithIndex:(NSInteger)index {
    NSInteger realIndex = index - 1;
    if (self.ansItemsArray.count > realIndex) {
        WDNextItemStructModel *itemModel = [self.ansItemsArray objectAtIndex:realIndex];
        return itemModel.show_toast.boolValue;
    }
    return NO;
}

- (BOOL)isLastAnswerFromDetailModel:(WDDetailModel *)detailModel {
    BOOL isLast = NO;
    if (self.hasGetAllAnswers) {
        if (self.ansItemsArray.count == 0) {
            isLast = YES;
        }
        else {
            WDNextItemStructModel *lastModel = [self.ansItemsArray lastObject];
            if ([lastModel.ansid isEqualToString:detailModel.answerEntity.ansid]) {
                return YES;
            }
        }
    }
    return isLast;
}

- (BOOL)isLastAnswer {
    if (self.ansItemsArray.count > 0) {
        WDNextItemStructModel *lastModel = [self.ansItemsArray lastObject];
        if ([lastModel.ansid isEqualToString:self.currentDetailModel.answerEntity.ansid]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)isNeedShowSlideHint {
    if (self.showSlideType == AnswerDetailShowSlideTypeWhiteHeaderWithoutHint) {
        return NO;
    }
    if (self.ansItemsArray.count == 0) {
        return NO;
    }
    BOOL hasShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"WDDetailHasShowSlideHint"];
    return !hasShow;
}

- (void)afterShowSlideHint {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WDDetailHasShowSlideHint"];
}

#pragma mark - private

- (void)setAnswerListFromModel:(WDWendaAnswerListResponseModel *)responseModel {
    NSInteger oldCount = self.ansItemsArray.count;
    NSMutableArray *array = [NSMutableArray arrayWithArray:responseModel.answer_list];
    NSInteger responseCount = [array count];
    if (oldCount == 0) {
        if (responseCount == 1) {
            self.isOnlyAnswer = YES;
            self.hasGetAllAnswers = YES;
        }
        else if (responseCount > 1) {
            [array removeObjectAtIndex:0];
            [self.ansItemsArray addObjectsFromArray:array];
            self.hasCountChange = YES;
        }
    }
    else {
        if (responseCount == 1) {
            self.hasGetAllAnswers = YES;
        }
        else if (responseCount > 1) {
            // 为了兼容服务端的bug
            WDNextItemStructModel *model11 = [self.ansItemsArray lastObject];
            WDNextItemStructModel *model22 = [responseModel.answer_list lastObject];
            if ([model11.ansid isEqualToString:model22.ansid]) {
                self.hasGetAllAnswers = YES;
                return;
            }
            [array removeObjectAtIndex:0];
            [self.ansItemsArray addObjectsFromArray:array];
            self.hasCountChange = YES;
        }
    }
}

- (WDNextItemStructModel *)getOneTestNextItemModelWithAnsId:(NSString *)ansid answerSchema:(NSString *)ansSchema {
    WDNextItemStructModel *nextItemModel = [WDNextItemStructModel new];
    nextItemModel.ansid = ansid;
    nextItemModel.schema = ansSchema;
    return nextItemModel;
}

#pragma mark - get

- (WDDetailModel *)initialDetailModel {
    return self.fetchContentHelper.detailModel;
}

@end

@implementation WDDetailSlideViewModel (NetWorkCategory)

+ (void)startFetchAnswerListWithAnswerID:(NSString *)ansID
                                enterFrom:(NSString *)enterFrom
                                gdExtJson:(NSString *)gdExtJson
                             apiParameter:(NSString *)apiParameter
                              finishBlock:(void(^)(WDWendaAnswerListResponseModel *responseModel, NSError *error))finishBlock {
    
    WDWendaAnswerListRequestModel *requestModel = [[WDWendaAnswerListRequestModel alloc] init];
    requestModel.ansid = ansID;
    requestModel.api_param = apiParameter;
    requestModel.gd_ext_json = gdExtJson;
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaAnswerListResponseModel *)responseModel, error);
        }
    }];
}

@end
