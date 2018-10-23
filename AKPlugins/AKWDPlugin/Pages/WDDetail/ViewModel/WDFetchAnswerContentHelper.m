//
//  WDFetchAnswerContentHelper.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/6.
//
//

#import "WDFetchAnswerContentHelper.h"
#import "WDDetailFullContentManager.h"
#import "WDMonitorManager.h"
#import "WDParseHelper.h"
#import "WDAnswerEntity.h"
#import "WDDetailModel.h"

#import "NetworkUtilities.h"
#import "TTNetworkManager.h"
#import <TTAccountBusiness.h>

@interface WDFetchAnswerContentHelper ()

@property (nonatomic, assign) BOOL hasLoadedArticle;
@property (nonatomic, assign) CFTimeInterval cdnRequestTime;
@property (nonatomic, strong, nullable) WDDetailModel *detailModel;

@end

@implementation WDFetchAnswerContentHelper

#pragma mark - lifestyle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentLoadFinished:)
                                                     name:@"kNewsFetchWDDetailFinishedNotification"
                                                   object:nil];
        
        NSDictionary *params = paramObj.allParams;
        if ([params.allKeys containsObject:@"ansid"]) {
            NSString *ansID = [params tt_stringValueForKey:@"ansid"];
            _detailModel = [[WDDetailModel alloc] initWithAnswerId:ansID params:params];
        }
        
    }
    return self;
}

#pragma mark - public

- (void)fetchContentFromRemoteIfNeededWithComplete:(nullable WDFetchRemoteContentBlock)block {
    self.fetchContentBlock = block;
    if (![self.detailModel isContentHasFetched] || self.detailModel.answerEntity.answerDeleted || !self.detailModel.useCDN) {
        
        if (self.detailModel.useCDN) {
            self.cdnRequestTime = CACurrentMediaTime();
            // way 1
            [[WDDetailFullContentManager sharedManager] fetchDetailForAnswerEntity:self.detailModel.answerEntity
                                                                            useCDN:self.detailModel.useCDN];
        } else {
            // way 2
            [self tryFetchDetailForAnswerEntity:self.detailModel.answerEntity];
        }
    }
    else {
        self.hasLoadedArticle = YES;
        
        [self.detailModel.answerEntity updateWithAnsid:self.detailModel.answerEntity.ansid Content:self.detailModel.answerEntity.content];
        if (self.detailModel.answerEntity.detailWendaExtra) {
            [self.detailModel updateDetailModelWithExtraData:self.detailModel.answerEntity.detailWendaExtra];
        }
        
        if (self.fetchContentBlock) {
            self.fetchContentBlock(WDFetchResultTypeDone);
        }
    }
}

#pragma mark - private

- (void)contentLoadFinished:(NSNotification *)notification {
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    WDAnswerEntity *answerEntity = [[notification userInfo] objectForKey:kWDFullAnswerData];
    if (!error) {
        CFTimeInterval interval = self.cdnRequestTime ? (CACurrentMediaTime() - self.cdnRequestTime) * 1000.f : 0;
        if (interval > 0) {
            NSString *intervalString = [NSString stringWithFormat:@"%.1f", interval];
            [[TTMonitor shareManager] trackService:WDDetailCDNTimeService value:intervalString extra:[WDMonitorManager extraDicWithError:error]];
            LOGD(@"serviceName is %@, intervalString is %@", WDDetailCDNService, intervalString);
        }
    }
    self.cdnRequestTime = 0;
    [self refreshAnswerEntity:answerEntity error:error];
    if (error) {
        [[TTMonitor shareManager] trackService:WDDetailCDNService
                                        status:WDRequestNetworkStatusFailed
                                         extra:[WDMonitorManager extraDicWithAnswerId:answerEntity.ansid error:error]];
    } else {
        [[TTMonitor shareManager] trackService:WDDetailCDNService
                                        status:WDRequestNetworkStatusCompleted
                                         extra:[WDMonitorManager extraDicWithAnswerId:answerEntity.ansid error:error]];
    }
}

- (void)refreshAnswerEntity:(WDAnswerEntity *)answerEntity error:(NSError *)error
{
    if(self.detailModel.answerEntity == nil)
    {
        if (self.fetchContentBlock) {
            self.fetchContentBlock(WDFetchResultTypeFailed);
        }
        return ;
    }
    
    // don't have valid new article
    if(answerEntity && ![answerEntity isValid])
    {
        if (self.fetchContentBlock) {
            self.fetchContentBlock(WDFetchResultTypeFailed);
        }
        return;
    }
    
    if(self.detailModel.answerEntity  != nil && answerEntity != nil &&
       ![self.detailModel.answerEntity.ansid isEqualToString:answerEntity.ansid]){
        if (self.fetchContentBlock) {
            self.fetchContentBlock(WDFetchResultTypeEndLoading);
        }
        return;
    }
    if(error == nil)
    {
        if(!_hasLoadedArticle)
        {
            self.detailModel.answerEntity = answerEntity;
            _hasLoadedArticle = YES;
            
            [self.detailModel.answerEntity updateWithAnsid:self.detailModel.answerEntity.ansid Content:self.detailModel.answerEntity.content];
            if (self.detailModel.answerEntity.detailWendaExtra) {
                [self.detailModel updateDetailModelWithExtraData:self.detailModel.answerEntity.detailWendaExtra];
            }
            
            if (self.fetchContentBlock) {
                self.fetchContentBlock(WDFetchResultTypeDone);
            }
        }
    }
    else if(isEmptyString(answerEntity.content))
    {
        if (!TTNetworkConnected()) {
            if (self.fetchContentBlock) {
                self.fetchContentBlock(WDFetchResultTypeNoNetworkConnect);
            }
        }
        else {
            if (self.fetchContentBlock) {
                self.fetchContentBlock(WDFetchResultTypeFailed);
            }
        }
    }
}

- (void)tryFetchDetailForAnswerEntity:(WDAnswerEntity *)answerEntity
{
    NSString * requestURL = [self wendaDetailUrlStringWithAnswerID:answerEntity.ansid];
    if (isEmptyString(requestURL)) {
        if (self.fetchContentBlock) {
            self.fetchContentBlock(WDFetchResultTypeFailed);
        }
        return;
    }
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setValue:@"new" forKey:@"type"];
    [param setValue:@([NSDate timeIntervalSinceReferenceDate]) forKey:@"timeStamp"];
    __weak typeof(self) wself = self;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:requestURL params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        __strong typeof(self) sself = wself;
        if (!sself) {
            return;
        }
        
        if (error) {
            [sself tryFetchDetailForAnswerEntity:answerEntity];
            //loadDetail错误统计
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:answerEntity.ansid forKey:@"value"];
            [dict setValue:@0 forKey:@"error_type"];
            [dict setValue:@(error.code) forKey:@"status"];
            [dict setValue:error.localizedDescription forKey:@"error_msg"];
            [TTTracker category:@"answer"
                                 event:@"detail_load"
                                 label:@"error"
                                  dict:dict];
        }
        else {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[jsonObj objectForKey:@"data"]];
            NSString *content = [data objectForKey:@"content"];
            
            [self _checkAnswerContentOrFullValidationAnswerEntity:answerEntity dict:data];
            
            if(answerEntity && content)
            {
                [data removeObjectForKey:@"group_id"];
                if (data[@"item_id"]) {
                    [data setValue:[NSString stringWithFormat:@"%@", data[@"item_id"]] forKey:@"item_id"];
                }
                
                //此处需要判断没有删除的情况， 没有返回delete的，都认为没有被删除
                if (![[data allKeys] containsObject:@"delete"]) {
                    [data setObject:@0 forKey:@"delete"];
                }
                
                //loadDetail删除统计
                if ([[data objectForKey:@"delete"] integerValue] == 1) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:answerEntity.ansid forKey:@"value"];
                    [TTTracker category:@"answer"
                                         event:@"detail_load"
                                         label:@"delete"
                                          dict:dict];
                }
                
                [answerEntity updateWithDetailWendaAnswer:data];
                [answerEntity save];
                
                NSMutableDictionary * notifyDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [notifyDict setObject:answerEntity forKey:@"data"];
                
                [sself refreshAnswerEntity:answerEntity error:nil];
            }
        }
    }];
}

- (void)_checkAnswerContentOrFullValidationAnswerEntity:(WDAnswerEntity *)answerEntity
                                                   dict:(NSDictionary *)dict
{
    NSString *content = [dict objectForKey:@"content"];
    NSDictionary *wendaExtra = answerEntity.detailWendaExtra;
    NSString *errorTips = nil;
    if (isEmptyString(content)) {
        errorTips = @"nativeArticle with no content";
    } else if (wendaExtra.count == 0){
        errorTips = @"wendaExtra with no data";
    }
    if (!isEmptyString(errorTips)) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:answerEntity.ansid forKey:@"value"];
        [dict setValue:@1 forKey:@"error_type"];
        [dict setValue:errorTips forKey:@"error_msg"];
        [TTTracker category:@"answer"
                             event:@"detail_load"
                             label:@"error"
                              dict:dict];
    }
}

#pragma mark - util

- (NSString *)wendaDetailUrlStringWithAnswerID:(NSString *)answerID {
    if (isEmptyString(answerID) || [answerID rangeOfString:@"null"].length) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/wenda/v1/answer/detail/%@/", [WDCommonURLSetting baseURL], answerID];
}

- (NSNumber *)fixNumberTypeGroupID:(NSNumber *)gID
{
    long long fixedID = [gID longLongValue];
    if (fixedID < 0) {  //逻辑修正，头条2.7(包括)版本之前，使用int32存储groupID，溢出，新版本需要兼容负数groupID
        fixedID = fixedID + 4294967296;
    }
    return @(fixedID);
}

@end
