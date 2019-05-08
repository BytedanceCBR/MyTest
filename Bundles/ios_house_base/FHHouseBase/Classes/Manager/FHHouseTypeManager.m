//
//  FHHouseTypeManager.m
//  FHHouseBase
//
//  Created by 张元科 on 2018/12/23.
//

#import "FHHouseTypeManager.h"

@implementation FHHouseTypeManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (NSString *)searchBarPlaceholderForType:(FHHouseType)houseType {
    NSString *placeHolder = @"请输入小区/商圈/地铁";
    switch (houseType) {
        case FHHouseTypeNewHouse:
            placeHolder = @"请输入楼盘名/地址";
            break;
        case FHHouseTypeSecondHandHouse:
            placeHolder = @"请输入小区/商圈/地铁";
            break;
        case FHHouseTypeRentHouse:
            placeHolder = @"请输入小区/商圈/地铁";
            break;
        case FHHouseTypeNeighborhood:
            placeHolder = @"请输入小区/商圈/地铁";
            break;
        default:
            break;
    }
    return placeHolder;
}

- (NSString *)traceValueForType:(FHHouseType)houseType {
    NSString *trace = @"";
    switch (houseType) {
        case FHHouseTypeNewHouse:
            trace = @"new";
            break;
        case FHHouseTypeSecondHandHouse:
            trace = @"old";
            break;
        case FHHouseTypeRentHouse:
            trace = @"rent";
            break;
        case FHHouseTypeNeighborhood:
            trace = @"neighborhood";
            break;
        default:
            break;
    }
    return trace;
}

- (NSString *)stringValueForType:(FHHouseType)houseType {
    NSString *value = @"";
    switch (houseType) {
        case FHHouseTypeNewHouse:
            value = @"新房";
            break;
        case FHHouseTypeSecondHandHouse:
            value = @"二手房";
            break;
        case FHHouseTypeRentHouse:
            value = @"租房";
            break;
        case FHHouseTypeNeighborhood:
            value = @"小区";
            break;
        default:
            break;
    }
    return value;
}

@end
