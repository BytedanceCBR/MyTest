//
//  ZDLoadingView.h
//  PullToRefreshControlDemo
//
//  Created by Nick Yu on 12/26/13.
//  Copyright (c) 2013 Zhang Kai Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TTLoadingArrowDown,
    TTLoadingArrowUp,
} TTLoadingArrowDirectionType;

@interface TTLoadingView : UIView

//@property (nonatomic,assign) CGFloat percent;
@property (nonatomic, assign) TTLoadingArrowDirectionType arrowDirection;
 
- (void)startLoading;
- (void)stopLoading;

//- (void)showNoMoreIcon:(BOOL)show;

@end
