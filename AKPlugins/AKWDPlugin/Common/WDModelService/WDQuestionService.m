//
//  WDQuestionService.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/11/6.
//

#import "WDQuestionService.h"
#import <TTBaseLib/JSONAdditions.h>
#import "WDNetWorkPluginManager.h"

NSString * const kWDServiceHelperQuestionFollowNotification = @"WDServiceHelperQuestionFollowNotification";

@interface WDQuestionService ()

@property (nonatomic, strong) NSHashTable<id<WDQuestionServiceProtocol>>*delegates;

@end

@implementation WDQuestionService

+ (instancetype)sharedInstance {
    static WDQuestionService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WDQuestionService alloc] init];
    });
    return sharedInstance;
}

+ (void)registerDelegate:(id<WDQuestionServiceProtocol>)delegate {
    [[WDQuestionService sharedInstance] registerDelegate:delegate];
}

+ (void)unRegisterDelegate:(id<WDQuestionServiceProtocol>)delegate {
    [[WDQuestionService sharedInstance] unRegisterDelegate:delegate];
}

- (instancetype)init {
    if (self = [super init]) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)registerDelegate:(id<WDQuestionServiceProtocol>)delegate {
    if (!delegate) return;
    [self.delegates addObject:delegate];
}

- (void)unRegisterDelegate:(id<WDQuestionServiceProtocol>)delegate {
    if (!delegate) return;
    [self.delegates removeObject:delegate];
}

- (void)broadcastQuestionWithQid:(NSString *)qid
                      actionType:(WDQuestionActionType)actionType
                           error:(NSError *)error {
    NSArray <id<WDQuestionServiceProtocol>>*allDelegates = [self.delegates allObjects];
    for (id<WDQuestionServiceProtocol> delegate in allDelegates) {
        if ([delegate respondsToSelector:@selector(questionStatusChangedWithQId:actionType:error:)]) {
            [delegate questionStatusChangedWithQId:qid actionType:actionType error:error];
        }
    }
}

#pragma mark - Action

+ (void)followQuestionWithQid:(NSString *)qid
                   followType:(NSUInteger)followType
                 apiParameter:(NSDictionary *)apiParameter
                  finishBlock:(void(^)(WDWendaCommitFollowquestionResponseModel *responseModel, NSError * error))finishBlock {
    if (isEmptyString(qid)) {
        return;
    }
    WDWendaCommitFollowquestionRequestModel *requestModel = [[WDWendaCommitFollowquestionRequestModel alloc] init];
    requestModel.qid = qid;
    requestModel.follow_type = @(followType);
    requestModel.api_param = [apiParameter tt_JSONRepresentation];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaCommitFollowquestionResponseModel *)responseModel, error);
        }
        [[WDQuestionService sharedInstance] broadcastQuestionWithQid:qid actionType:WDQuestionActionTypeFollow error:error];
        if (!error) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:qid forKey:@"id"];
            [params setValue:@(followType) forKey:@"status"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kWDServiceHelperQuestionFollowNotification object:nil userInfo:[params copy]];
            [[NSNotificationCenter defaultCenter] postNotificationName:TTWDFollowPublishQASuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(WDPushNoteGuideFireReasonWDFollowQuestion)}];
        }
    }];
}

+ (void)deleteQuestionWithQid:(NSString *)qid
                 apiParameter:(NSDictionary *)apiParameter
                  finishBlock:(void(^)(WDWendaCommitDeletequestionResponseModel *responseModel, NSError * error))finishBlock {
    if (isEmptyString(qid)) {
        return;
    }
    WDWendaCommitDeletequestionRequestModel *requestModel = [[WDWendaCommitDeletequestionRequestModel alloc] init];
    requestModel.qid = qid;
    requestModel.api_param = [apiParameter tt_JSONRepresentation];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaCommitDeletequestionResponseModel *)responseModel, error);
        }
        [[WDQuestionService sharedInstance] broadcastQuestionWithQid:qid actionType:WDQuestionActionTypeDelete error:error];
    }];
}

+ (void)reportQuestionWithQid:(NSString *)qid
                reportParams:(NSDictionary *)reportParams
                         gid:(NSString *)gid
                    apiParam:(NSString *)apiParam
                 finishBlock:(void(^)(NSError * error, NSString* tips))finishBlock {
    if (isEmptyString(qid)) {
        return;
    }
    NSString *reasonCodeStr = (NSString *)[reportParams objectForKey:@"report"];
    
    if (!isEmptyString(reasonCodeStr)) {
        NSString *message = (NSString *)[reportParams objectForKey:@"criticism"];
        NSArray *codeNumArray = [[NSArray alloc] init];
        codeNumArray = [reasonCodeStr componentsSeparatedByString:@","];
        WDWendaCommitReportRequestModel *requestModel = [[WDWendaCommitReportRequestModel alloc] init];
        requestModel.gid = gid;
        requestModel.report_type = [codeNumArray tt_JSONRepresentation];
        requestModel.report_message = message;
        requestModel.api_param = apiParam;
        requestModel.type = WDObjectTypeQUESTION;
        
        [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
            WDWendaCommitReportResponseModel *resp = (WDWendaCommitReportResponseModel *)responseModel;
            if (finishBlock) {
                finishBlock(error,resp.err_tips);
            }
            [[WDQuestionService sharedInstance] broadcastQuestionWithQid:qid actionType:WDQuestionActionTypeReport error:error];
        }];
    }
}

+ (void)postQuestionWithTitle:(NSString *)title
                 questionDesc:(NSString *)questionDesc
                    imageList:(NSString *)imageList
                 apiParameter:(NSDictionary *)apiParameter
                       source:(NSString *)source
                 listEntrance:(NSString *)listEntrance
                    gdExtJson:(NSString *)gdExtJson
                  finishBlock:(void(^)(WDWendaCommitPostquestionResponseModel *responseModel, NSError *error))finishBlock {
    WDWendaCommitPostquestionRequestModel *requestModel = [[WDWendaCommitPostquestionRequestModel alloc] init];
    requestModel.title = title;
    requestModel.content = questionDesc;
    if (!isEmptyString(imageList)) {
        requestModel.pic_list = imageList;
    }
    requestModel.api_param = [apiParameter tt_JSONRepresentation];
    if (!isEmptyString(source)) {
        requestModel.source = source;
    }
    if (!isEmptyString(listEntrance)) {
        requestModel.list_entrance = listEntrance;
    }
    if (!isEmptyString(gdExtJson)) {
        requestModel.gd_ext_json = gdExtJson;
    }
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        WDWendaCommitPostquestionResponseModel *resp = (WDWendaCommitPostquestionResponseModel *)responseModel;
        if (finishBlock) {
            finishBlock(resp, error);
        }
        [[WDQuestionService sharedInstance] broadcastQuestionWithQid:resp.qid actionType:WDQuestionActionTypePost error:error];
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTWDFollowPublishQASuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(WDPushNoteGuideFireReasonWDPublishQuestion)}];
        }
    }];
}

+ (void)editQuestionWithQiD:(NSString *)qid
                      title:(NSString *)title
               questionDesc:(NSString *)questionDesc
                  imageList:(NSString *)imageList
               apiParameter:(NSDictionary *)apiParameter
                finishBlock:(void(^)(WDWendaCommitEditquestionResponseModel *responseModel, NSError *error))finishBlock {
    if (isEmptyString(qid)) {
        return;
    }
    WDWendaCommitEditquestionRequestModel *requestModel = [[WDWendaCommitEditquestionRequestModel alloc] init];
    requestModel.qid = qid;
    requestModel.title = title;
    requestModel.content = questionDesc;
    if (!isEmptyString(imageList)) {
        requestModel.pic_list = imageList;
    }
    requestModel.api_param = [apiParameter tt_JSONRepresentation];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaCommitEditquestionResponseModel *)responseModel, error);
        }
        [[WDQuestionService sharedInstance] broadcastQuestionWithQid:qid actionType:WDQuestionActionTypeEdit error:error];
    }];
}

+ (void)editQuestionWithQuestionID:(NSString *)qid
                        corcernIds:(NSString *)concernIds
                      apiParameter:(NSDictionary *)apiParameter
                       finishBlock:(void(^)(WDWendaCommitEditquestiontagResponseModel *responseModel, NSError *error))finishBlock {
    if (isEmptyString(qid)) {
        return;
    }
    WDWendaCommitEditquestiontagRequestModel *requestModel = [[WDWendaCommitEditquestiontagRequestModel alloc] init];
    requestModel.qid = qid;
    if (!isEmptyString(concernIds)) {
        requestModel.concern_ids = concernIds;
    }
    requestModel.api_param = [apiParameter tt_JSONRepresentation];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaCommitEditquestiontagResponseModel *)responseModel, error);
        }
        [[WDQuestionService sharedInstance] broadcastQuestionWithQid:qid actionType:WDQuestionActionTypeTagModify error:error];
    }];
}

@end
