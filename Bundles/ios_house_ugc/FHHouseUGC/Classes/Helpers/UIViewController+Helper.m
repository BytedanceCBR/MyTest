//
//  UIViewController+Helper.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/12/5.
//

#import "UIViewController+Helper.h"

@implementation UIViewController(Helper)
- (BOOL)isCurrentVisible {
    return self.isViewLoaded && self.view.window;
}
@end
