//
//  TTDebugRealConfig.h
//  Pods
//
//  Created by 苏瑞强 on 2017/5/18.
//
//

#import <Foundation/Foundation.h>
#import "TTExtensions.h"

typedef NS_ENUM(NSInteger, TTDataWillSubmitedType){
    TTDataWillSubmitedTypeNone = 0,
    TTDataWillSubmitedTypeNetwork = (1<<0),
    TTDataWillSubmitedTypeMonitor = (1<<1),
    TTDataWillSubmitedTypeDEV = (1<<2),
    TTDataWillSubmitedTypeFlags  = (TTDataWillSubmitedTypeNetwork | TTDataWillSubmitedTypeMonitor | TTDataWillSubmitedTypeDEV),
};



@interface TTDebugRealConfig : NSObject

@property (nonatomic, assign)  BOOL receiveUploadCommand;
@property (nonatomic, strong) NSString * startTime;
@property (nonatomic, strong) NSString * endTime;
@property (nonatomic, assign)  NSInteger maxCacheSize;
@property (nonatomic, assign)  NSInteger maxCacheAge;
@property (nonatomic, assign)  NSInteger maxCacheDBSize;
@property (nonatomic, assign)  BOOL needNetworkReponse;
@property (nonatomic, assign)  TTDataWillSubmitedType submitTypeFlags;

+ (instancetype)sharedInstance;

- (void)configDataCollectPolicy : (NSDictionary *)params;

@end
