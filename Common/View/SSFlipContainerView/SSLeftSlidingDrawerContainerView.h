//
//  SSLeftSlidingDrawerContainerView.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-10-12.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

@interface SSLeftSlidingDrawerContainerView : SSViewBase
{
    UIView * _drawerView;
}

@property(nonatomic, retain)UIView * drawerView;

- (id)initWithOrientation:(UIInterfaceOrientation)currentOrientation;

- (void)show;
- (void)close;

//protected
- (void)buildViews;
@end
