//
//  FRThreadSmartDetailManager.h
//  Article
//
//  Created by 王霖 on 4/22/16.
//
//

#import <Foundation/Foundation.h>
#import "FRRequestManager.h"

@interface FRThreadSmartDetailManager : NSObject

+ (void)requestDetailInfoWithThreadID:(int64_t)threadID userID:(int64_t)userID callback:(void(^ _Nullable)(NSError * _Nullable error, NSObject<TTResponseModelProtocol> * _Nullable responseModel ,FRForumMonitorModel *_Nullable monitorModel))callback;

+ (instancetype _Nonnull )sharedManager;

@end
