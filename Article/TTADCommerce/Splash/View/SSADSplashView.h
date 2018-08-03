//
//  SSADSplashView.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-13.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

@class SSADModel;
@protocol SSADSplashViewDelegate;

@interface SSADSplashView : SSViewBase

@property(nonatomic, weak) id<SSADSplashViewDelegate> delegate;
@property(nonatomic, strong, readonly) SSADModel * model;

- (instancetype)initWithFrame:(CGRect)frame;// splashModel:(SSADModel *)adModel;

- (void)refreshModel:(SSADModel *)model;
- (void)invalidPerform;
- (BOOL)haveClickAction;


@end

@protocol SSADSplashViewDelegate<NSObject>

@required
- (void)splashViewShowFinished:(SSADSplashView *)view;
- (void)splashViewWithAction;
- (void)splashViewClickBackgroundAction;

@end
