//
//  WDNewDetailTitleView.h
//  Article
//
//  Created by 延晋 张 on 2016/12/6.
//
//

#import "SSThemed.h"

typedef void (^WDNewTitleViewTapHandler)();

@interface WDNewDetailTitleView : SSThemedView

@property (nonatomic, assign, readonly) BOOL isShow;

- (void)updateNavigationTitle:(NSString *)title
                     imageURL:(NSString *)url
                   verifyInfo:(NSString *)verifyInfo
                   decoration:(NSString *)decoration
                      fansNum:(long long)fansNum;

- (void)setTapHandler:(WDNewTitleViewTapHandler)tapHandler;

- (void)setTitleAlpha:(CGFloat)alpha;

- (void)show:(BOOL)bShow animated:(BOOL)animated;

@end
