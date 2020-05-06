//
//  FHAssociateFormReportModel.m
//  FHHouseBase
//
//  Created by 张静 on 2020/4/2.
//

#import "FHAssociateFormReportModel.h"

@implementation FHAssociateFormReportModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = @"询底价";
        _subtitle = @"提交后将安排专业经纪人与您联系";
        _btnTitle = @"获取底价";
    }
    return self;
}

@end
