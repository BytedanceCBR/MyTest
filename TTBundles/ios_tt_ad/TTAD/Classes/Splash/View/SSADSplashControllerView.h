//
//  SSADSplashControllerView.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-26.
//
//

#import "SSViewBase.h"
#import "SSADModel.h"

extern NSString *const kChangeMainControlerNotification;

@protocol SSADSplashControllerViewDelegate;

@interface SSADSplashControllerView : SSViewBase

@property (nonatomic, weak) id<SSADSplashControllerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame model:(SSADModel *)model;
//用户点击了之后， 进行跳转的url
//- (NSString *)openURLString;
- (SSADModel *)openActionModel;

@end

@protocol SSADSplashControllerViewDelegate <NSObject>

@required

- (void)splashControllerViewShowFinished:(SSADSplashControllerView *)view animation:(BOOL)animation;
- (void)splashControllerViewWithAction:(SSADModel *)adModel;
- (void)splashControllerViewClickBackgroundAction:(SSADModel *)adModel;

@end
