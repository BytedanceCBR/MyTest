//
//  TTPostThreadManager.h
//  Article
//
//  Created by 王霖 on 3/16/16.
//
//

#import "TTPostThreadTask.h"

#import <TTUGCFoundation/FRApiModel.h>
#import <TTUGCFoundation/TTUGCRequestManager.h>


@interface TTPostThreadManager : NSObject

+ (BOOL)isTaskValid:(TTPostThreadTask *)task;
+ (void)postThreadTask:(TTPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, TTUGCRequestMonitorModel *monitorModel ,uint64_t networkConsume))finishBlock;
+ (void)postEditedThreadTask:(TTPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, TTUGCRequestMonitorModel *monitorModel ,uint64_t networkConsume))finishBlock;
+ (void)postRepostTask:(TTPostThreadTask *)task finishBlock:(void(^)(NSError * error, id respondObj, TTUGCRequestMonitorModel *monitorModel,uint64_t networkConsume))finishBlock;

+ (void)checkPostNeedBindPhoneOrNotWithCompletion:(void(^ _Nullable)(FRPostBindCheckType checkType))completion;

@end
