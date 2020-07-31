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
    CGFloat photoCellHeight = 281.0;
    photoCellHeight = round(width / 375.0f * photoCellHeight + 0.5);
    return CGSizeMake(width, photoCellHeight);
}

+ (CGSize)getDetailBuildingViewSize {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 60;
    CGFloat photoCellHeight = 177.0;
    photoCellHeight = round(width / 313.0f * photoCellHeight + 0.5);
    return CGSizeMake(width, photoCellHeight);
}

+ (CGSize)getDetailBuildingImageViewSize {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 60;
    CGFloat photoCellHeight = 281.0;
    photoCellHeight = round(width / 375.0f * photoCellHeight + 0.5);
    return CGSizeMake(width, photoCellHeight);
}
@end
