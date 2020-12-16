//
//  FHHousedetailModelManager.m
//  FHHouseBase
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHousedetailModelManager.h"
#import "FHDetailNewModel.h"
#import "YYCache.h"
#import "FHEnvContext.h"

@interface FHHousedetailModelManager ()

@property (nonatomic, strong) YYCache   *houseDtailManagerCache;

@end

@implementation FHHousedetailModelManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (YYCache *)houseDtailManagerCache{
    if(! _houseDtailManagerCache){
        _houseDtailManagerCache = [[YYCache alloc] initWithName:@"old_house_detail_cache"];
        [_houseDtailManagerCache.memoryCache setAgeLimit:604800];
        [_houseDtailManagerCache.diskCache setAgeLimit:604800];
    }
    return  _houseDtailManagerCache;
}

- (void)saveHouseDetailModel:(id)model With:(NSString *)key{
    if(![FHEnvContext isOldDetailLoadOptimization]){
        return ;
    }
    if([model isKindOfClass:[FHDetailOldModel class]] && key){
        [self.houseDtailManagerCache setObject:model forKey:key];
    }
}

- (id)getHouseDetailModelWith:(NSString *)key{
    if(![FHEnvContext isOldDetailLoadOptimization]){
        return nil;
    }
    if ([self.houseDtailManagerCache containsObjectForKey:key]) {
        id value = [self.houseDtailManagerCache objectForKey:key];
        if([value isKindOfClass:[FHDetailOldModel class]]){
            return value;
        }
    }
    return nil;
}

- (CGFloat)getSizeOfCache{
    NSInteger size = [self.houseDtailManagerCache.diskCache totalCost];
    return size;
}

- (void )cleanCache{
    [self.houseDtailManagerCache.diskCache removeAllObjects];
    [self.houseDtailManagerCache.memoryCache removeAllObjects];
}

@end
