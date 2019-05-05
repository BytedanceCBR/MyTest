//
//  TTStartupGroup.h
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import <Foundation/Foundation.h>

@class TTStartupTask;

typedef NS_ENUM(NSUInteger, TTStartupGroupType) {
    TTStartupGroupTypeSDKsRegister = 0, // SDK注册
};

@interface TTStartupGroup : NSObject

@property (nonatomic, strong) NSMutableArray<TTStartupTask *> *tasks;//本组内所有的启动项

- (BOOL)isConcurrent;//是否允许并发

@end
