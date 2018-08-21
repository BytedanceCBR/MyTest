//
//  WDServiceHelper.h
//  Article
//
//  Created by xuzichao on 2016/11/15.
//
//

#import <Foundation/Foundation.h>

@interface WDServiceHelper : NSObject

//个人主页
+ (void)openProfileForUserID:(int64_t)uid;

//列表页
+ (void)openWendaListForQID:(NSString *)qID
                  gdExtJson:(NSDictionary *)gdExtJsonDict
                   apiParam:(NSDictionary *)apiParam;
//详情页
+ (void)openWendaDetailForAID:(NSString *)aID
                    gdExtJson:(NSDictionary *)gdExtJsonDict
                     apiParam:(NSDictionary *)apiParam;
//发送提问
+ (void)openPostQuestionForTitle:(NSString *)title
                       gdExtJson:(NSDictionary *)gdExtJsonDict
                        apiParam:(NSDictionary *)apiParam;

//发送回答
+ (void)openPostAnswerForQID:(NSString *)qID
                   gdExtJson:(NSDictionary *)gdExtJsonDict
                    apiParam:(NSDictionary *)apiParam;

@end

