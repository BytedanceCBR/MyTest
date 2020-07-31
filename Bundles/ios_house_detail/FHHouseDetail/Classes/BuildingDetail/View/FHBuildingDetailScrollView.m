//
//  FHBuildingDetailScrollView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/31.
//

#import "FHBuildingDetailScrollView.h"

@implementation FHBuildingDetailScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event     {
         if (point.x < 10) {
             return nil;
         } else {
             return [super hitTest:point withEvent:event];
         }
}

@end
