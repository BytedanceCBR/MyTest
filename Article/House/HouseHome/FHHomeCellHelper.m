//
//  FHHomeCellHelper.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeCellHelper.h"

@implementation FHHomeCellHelper

+(instancetype)sharedInstance
{
    static FHHomeCellHelper *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHomeCellHelper alloc] init];
    });
    return manager;
}

+ (CGFloat)heightForFHHomeHeaderCellViewType
{
    return 300;
}

@end
