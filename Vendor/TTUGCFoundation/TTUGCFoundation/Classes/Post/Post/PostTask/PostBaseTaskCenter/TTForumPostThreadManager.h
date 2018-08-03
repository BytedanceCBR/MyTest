//
//  TTForumPostThreadManager.h
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import <Foundation/Foundation.h>
#import "TTForumPostThreadTask.h"
#import "FRRequestManager.h"

@interface TTForumPostThreadManager : NSObject

+ (BOOL)isTaskValid:(TTForumPostThreadTask *)task;
+ (void)postThreadTask:(TTForumPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, FRForumMonitorModel *monitorModel ,uint64_t networkConsume))finishBlock;
+ (void)postRepostTask:(TTForumPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, FRForumMonitorModel *monitorModel,uint64_t networkConsume))finishBlock;
+ (void)postVideoThreadTask:(TTForumPostThreadTask *)task finishBlock:(void(^)(NSError *error, id respondObj, FRForumMonitorModel *monitorModel ,uint64_t networkConsume))finishBlock;

@end
