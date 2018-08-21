//
//  TTUGCDetailNavigationTitleView.h
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/2/1.
//

#import <TTThemed/SSThemed.h>


typedef enum : NSUInteger {
    TTUGCDetailNavigationTitleViewTypeDefault,
    TTUGCDetailNavigationTitleViewTypeFollow,
    TTUGCDetailNavigationTitleViewTypeFollowLeft,//左对齐
    TTUGCDetailNavigationTitleViewTypeShowFans,
} TTUGCDetailNavigationTitleViewType;

typedef void (^TitleViewTapHandler)(void);

@interface TTUGCDetailNavigationTitleView : SSThemedView

@property(nonatomic, assign, readonly) BOOL isShow;
@property (nonatomic, assign) TTUGCDetailNavigationTitleViewType type;

- (void)updateNavigationTitle:(NSString *)title
                     imageURL:(NSString *)url;

- (void)updateNavigationTitle:(NSString *)title
                     imageURL:(NSString *)url
                   verifyInfo:(NSString *)verifyInfo
                 decoratorURL:(NSString *)decoratorURL
                      fansNum:(long long)fansNum;

- (void)setTapHandler:(TitleViewTapHandler)tapHandler;

- (void)setTitleAlpha:(CGFloat)alpha;

- (void)show:(BOOL)bShow animated:(BOOL)animated;

@end
