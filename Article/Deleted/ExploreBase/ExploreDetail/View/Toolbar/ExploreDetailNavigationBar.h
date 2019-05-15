//
//  ExploreDetailNavigationBar.h
//  Article
//
//  Created by SunJiangting on 15/7/31.
//
//

#import "SSThemed.h"
//#import "STDefines.h"
#import "TTAlphaThemedButton.h"
#import "TTImageView.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import "TTFollowThemeButton.h"
#import "TTLabel.h"

typedef NS_ENUM(NSInteger, ExploreDetailNavigationBarType){
    ExploreDetailNavigationBarTypeDefault = 0,
    ExploreDetailNavigationBarTypeShowFans = 1,
};

@class Article;
NS_ASSUME_NONNULL_BEGIN
@interface ExploreDetailNavigationBar : SSThemedView

@property(nonatomic, strong, readonly) SSThemedButton  *backButton;

@property(nonatomic, strong, readonly) SSThemedView    *functionView;
@property(nonatomic, strong, readonly) TTAlphaThemedButton  *moreButton;
@property(nonatomic, strong, readonly) ExploreAvatarView  *avatarView;
@property (nonatomic, strong, readonly) SSThemedLabel  *recomLabel;
@property (nonatomic, strong, readonly) SSThemedLabel  *adLabel;
@property (nonatomic, strong, readonly) TTFollowThemeButton *followButton;
@property (nonatomic, assign) BOOL showFollowedButton;
@property (nonatomic, strong, readonly) SSThemedLabel *mediaName;
@property(nonatomic, strong) SSThemedLabel        *fansLabel;
@property (nonatomic, assign)ExploreDetailNavigationBarType barType;

- (void)updateAvartarViewWithArticleInfo:(Article *)article isSelf:(BOOL)isSelf;
- (void)setupFollowedButtonWithScrollPercent:(CGFloat)scrollPercent;
//- (void)showAvartarViewWithUrl:(NSString *)url;
//- (void)showVerifyIcon:(BOOL)showVerifyIcon;

@end


typedef enum : NSUInteger {
    TTArticleDetailNavigationTitleViewTypeDefault,
    TTArticleDetailNavigationTitleViewTypeFollow,
    TTArticleDetailNavigationTitleViewTypeFollowLeft,//左对齐
    TTArticleDetailNavigationTitleViewTypeShowFans,
} TTArticleDetailNavigationTitleViewType;

typedef void (^TitleViewTapHandler)();

@interface TTArticleDetailNavigationTitleView : SSThemedView

@property(nonatomic, assign, readonly) BOOL isShow;
@property (nonatomic, assign) TTArticleDetailNavigationTitleViewType type;

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

NS_ASSUME_NONNULL_END
