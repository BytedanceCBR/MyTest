//
//  TTActionSheetAnimated.h
//  Article
//
//  Created by zhaoqin on 8/31/16.
//
//

#import <Foundation/Foundation.h>
#import "TTActionSheetConst.h"

@interface TTActionSheetAnimated : NSObject<UIViewControllerAnimatedTransitioning>
+ (instancetype)transitionWithTransitionType:(TTActionSheetTransitionType)type;
@end
