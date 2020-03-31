//
//  FHInterceptionManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/20.
//

#import "FHInterceptionManager.h"
#import "HMDTTMonitor.h"

#define InterceptionManagerContinue @"InterceptionManagerContinue"

@interface FHInterceptionManager ()
//接口字典，保证接口不会重复调用，保证最后一次接口调用结果
@property(nonatomic , strong) NSMutableDictionary *requestList;

@end

@implementation FHInterceptionManager

+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestList = [NSMutableDictionary dictionary];
    }
    return self;
}

- (TTHttpTask *)addInterception:(NSString *)uniqueId config:(FHInterceptionConfig *)config Condition:(Condition)condition operation:(Operation)operation complete:(Complete)complete task:(Task)task {
    if(uniqueId.length > 0){
        FHInterception *interception = self.requestList[uniqueId];
        if(interception){
            [interception cancel];
        }else{
            interception = [[FHInterception alloc] init];
        }

        self.requestList[uniqueId] = interception;
        
        return [interception addParamInterceptionWithConfig:config Condition:condition operation:operation complete:^(BOOL success, TTHttpTask * _Nullable httpTask) {
            self.requestList[uniqueId] = nil;
            if(complete){
                complete(success,httpTask);
            }
            
        } task:task];
    }
    return nil;
}

@end
