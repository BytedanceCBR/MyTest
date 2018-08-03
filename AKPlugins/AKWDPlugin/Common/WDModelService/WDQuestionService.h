//
//  WDQuestionService.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/11/6.
//

#import <Foundation/Foundation.h>
#import "WDApiModel.h"
#import "WDDefines.h"

/*
 * 11.6 问题模型服务类：将针对问题模型的操作进行收敛
 */

typedef NS_ENUM(NSUInteger, WDQuestionActionType) {
    WDQuestionActionTypeNone = 0,
    WDQuestionActionTypeFollow,
    WDQuestionActionTypeDelete,
    WDQuestionActionTypeReport,
    WDQuestionActionTypePost,
    WDQuestionActionTypeEdit,
    WDQuestionActionTypeTagModify,
};

@protocol WDQuestionServiceProtocol <NSObject>

- (void)questionStatusChangedWithQId:(NSString *)qid
                          actionType:(WDQuestionActionType)actionType
                               error:(NSError *)error;

@end

@interface WDQuestionService : NSObject

+ (void)registerDelegate:(id<WDQuestionServiceProtocol>)delegate;
+ (void)unRegisterDelegate:(id<WDQuestionServiceProtocol>)delegate;

+ (void)followQuestionWithQid:(NSString *)qid
                   followType:(NSUInteger)followType
                 apiParameter:(NSDictionary *)apiParameter
                  finishBlock:(void(^)(WDWendaCommitFollowquestionResponseModel *responseModel, NSError * error))finishBlock;

+ (void)deleteQuestionWithQid:(NSString *)qid
                 apiParameter:(NSDictionary *)apiParameter
                  finishBlock:(void(^)(WDWendaCommitDeletequestionResponseModel *responseModel, NSError * error))finishBlock;

+ (void)reportQuestionWithQid:(NSString *)qid
                 reportParams:(NSDictionary *)reportParams
                          gid:(NSString *)gid
                     apiParam:(NSString *)apiParam
                  finishBlock:(void(^)(NSError * error, NSString* tips))finishBlock;

+ (void)postQuestionWithTitle:(NSString *)title
                 questionDesc:(NSString *)questionDesc
                    imageList:(NSString *)imageList
                 apiParameter:(NSDictionary *)apiParameter
                       source:(NSString *)source
                 listEntrance:(NSString *)listEntrance
                    gdExtJson:(NSString *)gdExtJson
                  finishBlock:(void(^)(WDWendaCommitPostquestionResponseModel *responseModel, NSError *error))finishBlock;

+ (void)editQuestionWithQiD:(NSString *)qid
                      title:(NSString *)title
               questionDesc:(NSString *)questionDesc
                  imageList:(NSString *)imageList
               apiParameter:(NSDictionary *)apiParameter
                finishBlock:(void(^)(WDWendaCommitEditquestionResponseModel *responseModel, NSError *error))finishBlock;

+ (void)editQuestionWithQuestionID:(NSString *)qid
                        corcernIds:(NSString *)concernIds
                      apiParameter:(NSDictionary *)apiParameter
                       finishBlock:(void(^)(WDWendaCommitEditquestiontagResponseModel *responseModel, NSError *error))finishBlock;

@end
