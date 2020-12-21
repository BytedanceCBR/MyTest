//
//  FHHouseCardManager.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/12/21.
//

#import "FHHouseCardStatusManager.h"

@interface FHHouseCardStatusManager()

@property (nonatomic, copy) NSMutableDictionary *dict;

@end

@implementation FHHouseCardStatusManager


+ (instancetype)sharedInstance {
    static FHHouseCardStatusManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSMutableDictionary *)dict {
    if (!_dict) {
        _dict = [[NSMutableDictionary alloc] init];
    }
    return _dict;
}

- (void)readHouseId:(NSString *)houseId withHouseType:(NSInteger)houseType {
    if (!houseId || [houseId isEqualToString:@""]) {
        return;
    }
    NSString *Id = [NSString stringWithFormat:@"%ld%@", houseType, houseId];
    [self.dict setObject:@(YES) forKey:Id];
}

- (BOOL)isReadHouseId:(NSString *)houseId withHouseType:(NSInteger)houseType {
    if (!houseId || [houseId isEqualToString:@""]) {
        return NO;
    }
    NSString *Id = [NSString stringWithFormat:@"%ld%@", houseType, houseId];
    if ([self.dict objectForKey:Id]) {
        return YES;
    }
    return NO;
}

@end
