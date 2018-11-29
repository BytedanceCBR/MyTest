//
//  FHFeedHouseCellHelper.m
//  Article
//
//  Created by 张静 on 2018/11/28.
//

#import "FHFeedHouseCellHelper.h"

@interface FHFeedHouseCellHelper ()

@property(nonatomic, strong)NSMutableDictionary *houseCacheDict;

@end

@implementation FHFeedHouseCellHelper

static id _instance;

+(instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    
    return _instance;

}
+(instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (void)removeHouseCache {
    
    [self.houseCacheDict removeAllObjects];
}

-(void)addHouseCache:(NSString *)houseId {
    
    if (houseId.length < 0) {
        return;
    }
    [self.houseCacheDict setObject:@"1" forKey:houseId];

}
-(NSMutableDictionary *)houseCacheDict {
    
    if (!_houseCacheDict) {
        _houseCacheDict = [NSMutableDictionary dictionary];
    }
    return _houseCacheDict;
}

-(NSDictionary *)houseCache {
    return self.houseCacheDict;
}
@end
