//
//  FHBuildingDetailUtils.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildingDetailUtils.h"
#import <UIKit/UIKit.h>

@implementation FHBuildingDetailUtils

+ (CGSize)getTopImageViewSize {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(width, 281.0 * (375.0/281.0));
}

@end
