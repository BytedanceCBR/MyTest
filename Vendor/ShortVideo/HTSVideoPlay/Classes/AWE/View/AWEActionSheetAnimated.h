//
//  TTActionSheetAnimated.h
//  Article
//
//  Created by zhaoqin on 8/31/16.
//
//

#import <Foundation/Foundation.h>
#import "AWEActionSheetConst.h"

@interface AWEActionSheetAnimated : NSObject<UIViewControllerAnimatedTransitioning>
+ (instancetype)transitionWithTransitionType:(AWEActionSheetTransitionType)type;
@end
