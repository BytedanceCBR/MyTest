//
//  WDAnswerService.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/11/6.
//

#import "WDAnswerService.h"
#import <TTBaseLib/JSONAdditions.h>
#import "WDNetWorkPluginManager.h"

@interface WDAnswerService ()

@property (nonatomic, strong) NSHashTable<id<WDAnswerServiceProtocol>>*delegates;

@end

@implementation WDAnswerService

+ (instancetype)sharedInstance {
    static WDAnswerService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WDAnswerService alloc] init];
    });
    return sharedInstance;
}

+ (void)registerDelegate:(id<WDAnswerServiceProtocol>)delegate {
    [[WDAnswerService sharedInstance] registerDelegate:delegate];
}

+ (void)unRegisterDelegate:(id<WDAnswerServiceProtocol>)delegate {
    [[WDAnswerService sharedInstance] unRegisterDelegate:delegate];
}

- (instancetype)init {
    if (self = [super init]) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)registerDelegate:(id<WDAnswerServiceProtocol>)delegate {
    if (!delegate) return;
    [self.delegates addObject:delegate];
}

- (void)unRegisterDelegate:(id<WDAnswerServiceProtocol>)delegate {
    if (!delegate) return;
    [self.delegates removeObject:delegate];
}

- (void)broadcastAnswerWithAnsId:(NSString *)ansId
                      actionType:(WDAnswerActionType)actionType
                           error:(NSError *)error {
    NSArray <id<WDAnswerServiceProtocol>>*allDelegates = [self.delegates allObjects];
    for (id<WDAnswerServiceProtocol> delegate in allDelegates) {
        if ([delegate respondsToSelector:@selector(answerStatusChangedWithAnsId:actionType:error:)]) {
            [delegate answerStatusChangedWithAnsId:ansId actionType:actionType error:error];
        }
    }
}

#pragma mark - Action

+ (void)digWithAnswerID:(NSString *)ansID
               diggType:(WDDiggType)diggType
              enterFrom:(NSString *)enterFrom
               apiParam:(NSDictionary *)apiParam
            finishBlock:(void(^)(NSError * error))finishBlock {
    if (isEmptyString(ansID)) {
        return;
    }
    WDWendaCommitDigganswerRequestModel *requestModel = [[WDWendaCommitDigganswerRequestModel alloc] init];
    requestModel.ansid = ansID;
    requestModel.digg_type = @(diggType);
    requestModel.enter_from = enterFrom;
    requestModel.api_param = [apiParam tt_JSONRepresentation];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock(error);
        }
        [[WDAnswerService sharedInstance] broadcastAnswerWithAnsId:ansID actionType:WDAnswerActionTypeDigg error:error];
    }];
}

+ (void)buryWithAnswerID:(NSString *)ansID
                buryType:(WDBuryType)buryType
               enterFrom:(NSString *)enterFrom
                apiParam:(NSDictionary *)apiParam
             finishBlock:(void(^)(NSError * error))finishBlock {
    if (isEmptyString(ansID)) {
        return;
    }
    WDWendaCommitBuryanswerRequestModel *requestModel = [[WDWendaCommitBuryanswerRequestModel alloc] init];
    requestModel.ansid = ansID;
    requestModel.bury_type = @(buryType);
    requestModel.enter_from = enterFrom;
    requestModel.api_param = [apiParam tt_JSONRepresentation];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock(error);
        }
        [[WDAnswerService sharedInstance] broadcastAnswerWithAnsId:ansID actionType:WDAnswerActionTypeBury error:error];
    }];
}

+ (void)deleteWithAnswerID:(NSString *)ansID
                  apiParam:(NSDictionary *)apiParam
               finishBlock:(void(^)(WDWendaCommitDeleteanswerResponseModel *responseModel, NSError * error))finishBlock {
    if (isEmptyString(ansID)) {
        return;
    }
    WDWendaCommitDeleteanswerRequestModel *model = [[WDWendaCommitDeleteanswerRequestModel alloc] init];
    model.ansid = ansID;
    model.api_param = [apiParam tt_JSONRepresentation];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:model callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaCommitDeleteanswerResponseModel *)responseModel, error);
        }
        [[WDAnswerService sharedInstance] broadcastAnswerWithAnsId:ansID actionType:WDAnswerActionTypeDelete error:error];
    }];
}

+ (void)reportWithAnswerID:(NSString *)ansID
              reportParams:(NSDictionary *)reportParams
                       gid:(NSString *)gid
                  apiParam:(NSString *)apiParam
               finishBlock:(void(^)(NSError * error, NSString* tips))finishBlock {
    if (isEmptyString(ansID)) {
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
        requestModel.type = WDObjectTypeANSWER;
        
        [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
            WDWendaCommitReportResponseModel *resp = (WDWendaCommitReportResponseModel *)responseModel;
            if (finishBlock) {
                finishBlock(error,resp.err_tips);
            }
            [[WDAnswerService sharedInstance] broadcastAnswerWithAnsId:ansID actionType:WDAnswerActionTypeReport error:error];
        }];
    }
}

+ (void)opAnswerCommentForAnswerID:(NSString *)ansID
                        objectType:(WDOPCommentType)objectType
                      apiParameter:(NSDictionary *)apiParameter
                       finishBlock:(void(^)(WDWendaOpanswerCommentResponseModel *responseModel, NSError *error))finishBlock {
    if (isEmptyString(ansID)) {
        return;
    }
    WDWendaOpanswerCommentRequestModel *requestModel = [[WDWendaOpanswerCommentRequestModel alloc] init];
    requestModel.ansid = ansID;
    requestModel.op_type = objectType;
    requestModel.api_param = [apiParameter tt_JSONRepresentation];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaOpanswerCommentResponseModel *)responseModel, error);
        }
        [[WDAnswerService sharedInstance] broadcastAnswerWithAnsId:ansID actionType:WDAnswerActionTypeOpAnswer error:error];
    }];
}

+ (void)postAnswerWithQid:(NSString *)qid
                  content:(NSString *)content
             isBanComment:(BOOL)isBanComment
             apiParameter:(NSDictionary *)apiParameter
                   source:(NSString *)source
             listEntrance:(NSString *)listEntrance
                gdExtJson:(NSString *)gdExtJson
              finishBlock:(void(^)(WDWendaCommitPostanswerResponseModel * responseModel, NSError * error))finishBlock {
    if (isEmptyString(qid)) {
        return;
    }
    WDWendaCommitPostanswerRequestModel *request = [[WDWendaCommitPostanswerRequestModel alloc] init];
    request.qid = qid;
    request.content = content;
    request.api_param = [apiParameter tt_JSONRepresentation];
    request.ban_comment = isBanComment ? @(1): (0);
    if (!isEmptyString(source)) {
        request.source = source;
    }
    if (!isEmptyString(listEntrance)) {
        request.list_entrance = listEntrance;
    }
    if (!isEmptyString(gdExtJson)) {
        request.gd_ext_json = gdExtJson;
    }
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:request callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        WDWendaCommitPostanswerResponseModel *resp = (WDWendaCommitPostanswerResponseModel *)responseModel;
        if (finishBlock) {
            finishBlock(resp, error);
        }
        [[WDAnswerService sharedInstance] broadcastAnswerWithAnsId:resp.ansid actionType:WDAnswerActionTypePost error:error];
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTWDFollowPublishQASuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(WDPushNoteGuideFireReasonWDPublishAnswer)}];
        }
    }];
}

+ (void)editAnswerWithAnsid:(NSString *)ansID
                    content:(NSString *)content
               isBanComment:(BOOL)isBanComment
               apiParameter:(NSDictionary *)apiParameter
                finishBlock:(void(^)(WDWendaCommitEditanswerResponseModel * responseModel,  NSError *error))finishBlock {
    if (isEmptyString(ansID)) {
        return;
    }
    WDWendaCommitEditanswerRequestModel *requestModel = [[WDWendaCommitEditanswerRequestModel alloc] init];
    requestModel.ansid = ansID;
    requestModel.content = content;
    requestModel.api_param = [apiParameter tt_JSONRepresentation];
    requestModel.ban_comment = isBanComment ? @(1): (0);
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaCommitEditanswerResponseModel *)responseModel, error);
        }
        [[WDAnswerService sharedInstance] broadcastAnswerWithAnsId:ansID actionType:WDAnswerActionTypeEdit error:error];
    }];
}

@end
