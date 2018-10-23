//
//  TSVTransitionAnimationManager.h
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/11/15.
//

#import <Foundation/Foundation.h>

@interface TSVTransitionAnimationManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign) CGRect listSelectedCellFrame;
@property (nonatomic, assign) CGRect profileListSelectedCellFrame;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *enterProfilePercentDrivenTransition;

@end
