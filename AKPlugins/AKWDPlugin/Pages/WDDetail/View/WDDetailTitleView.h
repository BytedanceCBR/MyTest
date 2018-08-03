//
//  WDDetailTitleView.h
//  Article
//
//  Created by 延晋 张 on 2016/12/6.
//
//

#import "SSThemed.h"

typedef void (^WDTitleViewTapHandler)();

@interface WDDetailTitleView : SSThemedView

@property(nonatomic, assign, readonly) BOOL isShow;

- (void)updateNavigationTitle:(NSString *)title;

- (void)setTapHandler:(WDTitleViewTapHandler)tapHandler;

- (void)setTitleAlpha:(CGFloat)alpha;

- (void)show:(BOOL)bShow animated:(BOOL)animated;

- (instancetype)initWithFrame:(CGRect)frame fontSize:(CGFloat)foneSize;

@end
