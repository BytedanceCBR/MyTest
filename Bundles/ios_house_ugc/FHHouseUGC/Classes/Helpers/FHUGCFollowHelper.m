//
// Created by zhulijun on 2019-06-14.
//

#import "FHUGCFollowHelper.h"
#import "Singleton.h"

@interface FHUGCFollowHelper()
@property(strong) NSHashTable *observers;
@end

@implementation FHUGCFollowHelper
SINGLETON_GCD(FHUGCFollowHelper)

-(instancetype)init{
    self = [super init];
    if(self){
        self.observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:3];
    }
    return self;
}

+ (void)registerFollowStatusObserver:(id <FHUGCFollowObserver>)observer {
    [[FHUGCFollowHelper sharedFHUGCFollowHelper].observers addObject:observer];
}

+ (void)unregisterFollowStatusObserver:(id <FHUGCFollowObserver>)observer {
    [[FHUGCFollowHelper sharedFHUGCFollowHelper].observers removeObject:observer];
}

//TODO api接入
+ (void)followCommunity:(NSString *)communityId userInfo:(NSDictionary *)userInfo {

}

@end