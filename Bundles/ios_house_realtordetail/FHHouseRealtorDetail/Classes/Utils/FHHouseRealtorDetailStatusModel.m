//
//  FHHouseRealtorDetailStatusModel.m
//  Pods
//
//  Created by liuyu on 2020/7/15.
//

#import "FHHouseRealtorDetailStatusModel.h"

@implementation FHHouseRealtorDetailStatusModel

+ (instancetype)sharedInstance
{
    static FHHouseRealtorDetailStatusModel *statusModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        statusModel = [[FHHouseRealtorDetailStatusModel alloc]init];
    });
    return statusModel;
}
- (CGFloat)currentCellHeight {
    FHHouseRealtorDetailStatus *Status =  self.statusArray[self.currentIndex];
    return Status.cellHeight;
}

- (FHHouseRealtorDetailStatus *)currentRealtorDetailStatus {
    FHHouseRealtorDetailStatus *Status =  self.statusArray[self.currentIndex];
    return Status;
}
@end

@implementation FHHouseRealtorDetailStatus 

@end
