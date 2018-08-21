//
//  WDAnswerService.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/11/6.
//

#import <Foundation/Foundation.h>
#import "WDApiModel.h"
#import "WDDefines.h"

/*
 * 11.6 回答模型服务类：将针对回答模型的操作进行收敛
 */

typedef NS_ENUM(NSUInteger, WDAnswerActionType) {
    WDAnswerActionTypeNone = 0,
    WDAnswerActionTypeDigg,
    WDAnswerActionTypeBury,
    WDAnswerActionTypeDelete,
    WDAnswerActionTypeReport,
    WDAnswerActionTypeOpAnswer,
    WDAnswerActionTypePost,
    WDAnswerActionTypeEdit,
};

@protocol WDAnswerServiceProtocol <NSObject>

- (void)answerStatusChangedWithAnsId:(NSString *)ansId
                          actionType:(WDAnswerActionType)actionType
                               error:(NSError *)error;

@end

@interface WDAnswerService : NSObject

+ (void)registerDelegate:(id<WDAnswerServiceProtocol>)delegate;
+ (void)unRegisterDelegate:(id<WDAnswerServiceProtocol>)delegate;

+ (void)digWithAnswerID:(NSString *)ansID
               diggType:(WDDiggType)diggType
              enterFrom:(NSString *)enterFrom
               apiParam:(NSDictionary *)apiParam
            finishBlock:(void(^)(NSError * error))finishBlock;

+ (void)buryWithAnswerID:(NSString *)ansID
                buryType:(WDBuryType)buryType
               enterFrom:(NSString *)enterFrom
                apiParam:(NSDictionary *)apiParam
             finishBlock:(void(^)(NSError * error))finishBlock;

+ (void)deleteWithAnswerID:(NSString *)ansID
                  apiParam:(NSDictionary *)apiParam
               finishBlock:(void(^)(WDWendaCommitDeleteanswerResponseModel *responseModel, NSError * error))finishBlock;

+ (void)reportWithAnswerID:(NSString *)ansID
              reportParams:(NSDictionary *)reportParams
                       gid:(NSString *)gid
                  apiParam:(NSString *)apiParam
               finishBlock:(void(^)(NSError *error, NSString* tips))finishBlock;

+ (void)opAnswerCommentForAnswerID:(NSString *)ansID
                        objectType:(WDOPCommentType)objectType
                      apiParameter:(NSDictionary *)apiParameter
                       finishBlock:(void(^)(WDWendaOpanswerCommentResponseModel *responseModel, NSError *error))finishBlock;

+ (void)postAnswerWithQid:(NSString *)qid
                  content:(NSString *)content
             isBanComment:(BOOL)isBanComment
             apiParameter:(NSDictionary *)apiParameter
                   source:(NSString *)source
             listEntrance:(NSString *)listEntrance
                gdExtJson:(NSString *)gdExtJson
              finishBlock:(void(^)(WDWendaCommitPostanswerResponseModel * responseModel, NSError * error))finishBlock;

+ (void)editAnswerWithAnsid:(NSString *)ansID
                    content:(NSString *)content
               isBanComment:(BOOL)isBanComment
               apiParameter:(NSDictionary *)apiParameter
                finishBlock:(void(^)(WDWendaCommitEditanswerResponseModel * responseModel,  NSError *error))finishBlock;

@end


