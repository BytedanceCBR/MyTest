//
//  SSControllerViewBase.h
//  Article
//
//  Created by Zhang Leonardo on 13-2-24.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

@protocol SSControllerViewBaseDelegate;

@interface SSControllerViewBase : SSViewBase
@property(nonatomic, weak)id<SSControllerViewBaseDelegate> delegate;

@end

@protocol SSControllerViewBaseDelegate <NSObject>

@required
- (void)controllerViewBaseLayoutSubviews:(SSControllerViewBase *)viewBase;

@end

