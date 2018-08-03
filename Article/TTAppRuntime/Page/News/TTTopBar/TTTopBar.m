//
//  TTTopBar.m
//  Article
//
//  Created by fengyadong on 16/8/25.
//
//

#import "TTTopBar.h"
#import "TTTopBarManager.h"
#import <TTImage/TTImageView.h>
#import "UIImageView+WebCache.h"
#import "TTSettingMineTabManager.h"
#import "TTBadgeTrackerHelper.h"
#import "TTArticleSearchManager.h"
#import "TTCategoryBadgeNumberManager.h"
#import <TTTracker.h>
#import <TTAccountBusiness.h>
#import "TTSearchHomeSugModel.h"
#import "TTTintThemeButton.h"
#import "TTTabBarProvider.h"
//#import "PopoverView.h"
//#import "TTPostUGCEntrance.h"
//#import "TTUGCPermissionService.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAlphaThemedButton.h"
#import <BDWebImage/SDWebImageAdapter.h>


@interface TTTopBar ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) TTCategorySelectorView *selectorView;
@property (nonatomic, strong) SSThemedImageView *backgroundImageView;
@property (nonatomic, strong) TTTopBarManager *manager;
@end

@implementation TTTopBar

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = UIColor.whiteColor;
        _manager = [TTTopBarManager sharedInstance_tt];
    }
    return self;
}

- (void)setupSubviews
{
    ///背景图，支持下发
    _backgroundImageView = [[SSThemedImageView alloc] init];
    _backgroundImageView.clipsToBounds = YES;
    [self addSubview:_backgroundImageView];
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
//        if (self.selectorView){
//            make.bottom.equalTo(self.selectorView.mas_top);
//        }else{
            make.bottom.equalTo(self);
//        }
    }];
    self.backgroundImageView.layer.zPosition = -1;
    self.backgroundImageView.userInteractionEnabled = NO;
    
    [self refreshData];
}

#pragma mark -- Public Method

- (void)addTTCategorySelectorView:(TTCategorySelectorView *)selectorView delegate:(id<TTCategorySelectorViewDelegate>)delegate {
    self.selectorView = selectorView;
    [self addSubview:self.selectorView];
    self.selectorView.delegate = delegate;
    [self.selectorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(@(kSelectorViewHeight));
        make.bottom.equalTo(self);
    }];
}

- (void)refreshData
{
    [self refreshBackgroundImageView];
}

- (void)refreshBackgroundImageView
{
//    self.backgroundImageView.image = [[self class] searchBackgroundImage];
}

#pragma mark - dataSource

+ (UIImage *)searchBackgroundImage
{
    UIImage *image = nil;
    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
        ///top bar需要替换背景图片，且头像不在左上角时，支持替换背景图片
        image = [[TTTopBarManager sharedInstance_tt] getImageForName:kTTPublishBackgroundImageName];
    }
    return image;
}

+ (UIImage *)searchBarImage {
    UIImage *image;
    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
        ///top bar需要替换背景图片，且头像不在左上角时，支持替换背景图片
        image = [[TTTopBarManager sharedInstance_tt] getImageForName:kTTPublishSearchImageName];
    }
    
    if (!image) {
        image = [UIImage themedImageNamed:@"topbar_search_bar"];
    }
    
    CGFloat top = image.size.height/2.0 - 0.5;
    CGFloat left = image.size.width/2.0 - 0.5;
    CGFloat bottom = image.size.height/2.0 + 0.5;
    CGFloat right = image.size.width/2.0 + 0.5;
    
    UIEdgeInsets edge = UIEdgeInsetsMake(top,left,bottom,right);
    
    UIImage *stretchedImage = [image resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
    
    return stretchedImage;
}

@end
