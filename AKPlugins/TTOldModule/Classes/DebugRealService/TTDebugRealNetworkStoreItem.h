//
//  TTDebugRealNetworkStoreItem.h
//  Pods
//
//  Created by 苏瑞强 on 16/12/28.
//
//

#import <Foundation/Foundation.h>

@interface TTDebugRealNetworkStoreItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *requestID;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSInteger hasTriedTimes;
@property (nonatomic, copy) NSString * requestUrl;

@end
