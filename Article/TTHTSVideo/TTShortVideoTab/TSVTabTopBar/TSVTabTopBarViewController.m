//
//  TSVTabTopBarViewController.m
//  Article
//
//  Created by 王双华 on 2017/10/26.
//

#import "TSVTabTopBarViewController.h"
#import "TSVTabViewModel.h"
#import <TTThemed/SSThemed.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTThemed/TTThemeManager.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "ExploreSearchViewController.h"
#import "TTCustomAnimationDelegate.h"
#import "TSVCategorySelectorButton.h"
#import "TTTopBarManager.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <TTServiceKit/TTModuleBridge.h>
#import <TTPlatformUIModel/TTRecordedVideo.h>
#import "TTUGCPostCenterProtocol.h"
#import "TSVShortVideoPostTaskProtocol.h"
#import <TTBubbleView.h>
#import "TTBubbleViewHeader.h"
//#import "TTUGCPermissionService.h"
#import "TSVRedPackPublishButton.h"
#import "NewsBaseDelegate.h"
#import "TTAccountLoginManager.h"

//爱看
#import "AKUIHelper.h"

//#import "TTSFHelper.h"

static const NSInteger kCategoryItemHeight = 44;

@interface TSVTabTopBarViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) TSVTabViewModel *viewModel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TTAlphaThemedButton *searchButton;
@property (nonatomic, strong) TSVRedPackPublishButton *publishButton;
@property (nonatomic, strong) TTBubbleView *publishIntroBubble;
@property (nonatomic, strong) CALayer *rightBackLayer;
@property (nonatomic, strong) CAGradientLayer *rightGradientLayer;
@property (nonatomic, strong) SSThemedView *bottomLine;
@property (nonatomic, strong) NSMutableArray *categoryButtons;

@property (nonatomic, strong) UIView *selectedBackView;
@property (nonatomic, strong) CAGradientLayer *selectedBackLayer;
@property (nonatomic, copy) TSVTabTopBarViewControllerCategorySelectBlock categorySelectBlock;

@end

@implementation TSVTabTopBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView;
    });
    [self.view addSubview:self.scrollView];
    
    self.selectedBackView = ({
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 52, 28)];
        backView.layer.cornerRadius = backView.height / 2;
        backView.clipsToBounds = YES;
        backView.userInteractionEnabled = NO;
        CAGradientLayer *layer = [AKUIHelper AiKanBackGrandientLayer];
        layer.bounds = backView.bounds;
        layer.position = CGPointMake(backView.width / 2, backView.height / 2);
        [backView.layer addSublayer:layer];
        self.selectedBackLayer = layer;
        backView;
    });
    [self.scrollView addSubview:self.selectedBackView];
    
    self.rightBackLayer = ({
        CALayer *layer = [CALayer layer];
        layer;
    });
    
    self.rightGradientLayer = ({
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        gradientLayer;
    });
    
    self.searchButton = ({
        TTAlphaThemedButton *searchButton = [[TTAlphaThemedButton alloc] init];
        searchButton.imageName = @"Search";
        searchButton.enableHighlightAnim = YES;
        [searchButton addTarget:self action:@selector(searchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        searchButton;
    });
    
    self.publishButton = ({
        TSVRedPackPublishButton *button = [[TSVRedPackPublishButton alloc] init];
        [button addTarget:self action:@selector(publishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    if ([[self class] rightButtonType] == TSVTabTopBarRightButtonTypeSearch) {
        [self.view.layer addSublayer:self.rightBackLayer];
        [self.view.layer addSublayer:self.rightGradientLayer];
        [self.view addSubview:self.searchButton];
    } else if ([[self class] rightButtonType] == TSVTabTopBarRightButtonTypePublish) {
        [self.view.layer addSublayer:self.rightBackLayer];
        [self.view.layer addSublayer:self.rightGradientLayer];
        [self.view addSubview:self.publishButton];
//        if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoRedpackIntro]) {
//            self.publishButton.style = TSVRedPackPublishButtonStyleRed;
//        }
//        else {
            self.publishButton.style = TSVRedPackPublishButtonStyleNormal;
//        }
    }

    self.bottomLine = ({
        SSThemedView *bottomLine = [[SSThemedView alloc] init];
        bottomLine.backgroundColorThemeKey = kColorLine7;
        bottomLine;
    });
    [self.view addSubview:self.bottomLine];
    
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kTTNotificationNameRedpackIntroUpdated object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(id x) {
         @strongify(self);
         if ([[self class] rightButtonType] == TSVTabTopBarRightButtonTypePublish) {
//             if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoRedpackIntro]) {
//                 self.publishButton.style = TSVRedPackPublishButtonStyleRed;
//             }
//             else {
                 self.publishButton.style = TSVRedPackPublishButtonStyleNormal;
//             }
         }
     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kHTSTabbarClickedNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(id x) {
         @strongify(self);
//         if ([[self class] rightButtonType] == TSVTabTopBarRightButtonTypePublish && [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoRedpackIntro]) {
//             self.publishButton.style = TSVRedPackPublishButtonStyleRed;
//             [self.publishButton startAnimation];
//         }
     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(id x) {
         @strongify(self);
         [self themeReload];
     }];
    
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTRecordedVideoPickedNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
//        @strongify(self);
//        NSDictionary *userInfo = notification.userInfo;
//        NSString *concernID = [userInfo tt_stringValueForKey:@"cid"];
//        if ([userInfo tt_boolValueForKey:@"completed"] && [concernID isEqualToString:kTTShortVideoConcernID]) {
//            TTRecordedVideo *recordedVideo = [userInfo objectForKey:@"recordedVideo"];
//            id<TTUGCPostCenterProtocol> taskCenter = [[TTServiceCenter sharedInstance] getService:NSClassFromString(TTUGCPostCenterClassName)];
//            [taskCenter protocol_postShortVideo:recordedVideo
//                                      concernID:kTTShortVideoConcernID
//                                     categoryID:kTTUGCVideoCategoryID
//                                     extraTrack:recordedVideo.extraTrackForPublish
//             ];
//        }
//    }];
    [self themeReload];
    [self bindViewModel];
}

- (void)bindViewModel
{
    @weakify(self);
    [RACObserve(self, viewModel.categoryNames) subscribeNext:^(NSArray<NSString *> *categoryNames) {
        @strongify(self);
        for (TSVCategorySelectorButton *button in self.categoryButtons) {
            [button removeFromSuperview];
        }
        self.categoryButtons = nil;
        NSMutableArray *categoryButtons = [NSMutableArray arrayWithCapacity:[categoryNames count]];
        NSInteger index = 0;
        for (NSString *name in categoryNames) {
             TSVCategorySelectorButton *button = [[TSVCategorySelectorButton alloc] initWithFrame:CGRectMake(0, 0, [TSVCategorySelectorButton buttonWidthForText:name buttonCount:[categoryNames count]], kCategoryItemHeight) textColors:[self categorySelectorTextColors] textGlowColors:[self categorySelectorTextGlowColors] textGlowSize:[self categorySelectorTextGlowSize]];
            [button setText:name];
            button.tapBlock = ^{
                @strongify(self);
                if (self.viewModel.currentIndex != index) {
                    [self.categoryButtons[self.viewModel.currentIndex] setSelected:NO animated:NO];
                    [self.categoryButtons[index] setSelected:YES animated:NO];
                    [self scrollToIndex:index animated:YES];
                    [self refreshSelectBackViewCenter:((UIButton *)self.categoryButtons[index]).center newButton:((TSVCategorySelectorButton *)self.categoryButtons[index]) with:NO];
                }
                if (self.categorySelectBlock) {
                    self.categorySelectBlock(index);
                }
            };
            if (index == self.viewModel.currentIndex) {
                [button setSelected:YES animated:NO];
            } else {
                [button setSelected:NO animated:NO];
            }
            [self.scrollView addSubview:button];
            [categoryButtons addObject:button];
            index ++;
        }
        self.categoryButtons = [categoryButtons copy];
        [self.view setNeedsLayout];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (/*![GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoRedpackIntro] && [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoTabNormalIntro]*/ YES) {
//        [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) setShortVideoTabIntroHasClicked];
//        self.publishIntroBubble = ({
//            NSString *tipText = @"点击拍小视频";
//            TTBubbleView *bubbleView = [[TTBubbleView alloc] initWithAnchorPoint:CGPointMake(self.view.width - 28.0f, self.view.height - 7.0f) imageName:nil tipText:tipText attributedText:nil arrowDirection:TTBubbleViewArrowUp lineHeight:0 viewType:TTBubbleViewTypeDefault screenMargin:10.0f];
//            bubbleView;
//        });
//        [self.view addSubview:self.publishIntroBubble];
//        @weakify(self);
//        [self.publishIntroBubble showTipWithAnimation:YES automaticHide:YES autoHideInterval:5.0f animationCompleteHandle:nil autoHideHandle:^{
//            @strongify(self);
//            [self.publishIntroBubble removeFromSuperview];
//            self.publishIntroBubble = nil;
//        } tapHandle:nil closeHandle:nil shouldShowMe:nil];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat top = height - kCategoryItemHeight;
    self.scrollView.frame = CGRectMake(0, top, width, kCategoryItemHeight);
    self.rightBackLayer.frame = CGRectMake(width - 44, top, 44, kCategoryItemHeight);
    self.rightGradientLayer.frame = CGRectMake(width - 44 - 24, top, 24, kCategoryItemHeight);
    self.searchButton.frame = CGRectMake(width - 40, top, 40, kCategoryItemHeight);
    self.publishButton.frame = CGRectMake(width - 48, top, 48, kCategoryItemHeight);
    self.bottomLine.frame = CGRectMake(0, self.view.height - [TTDeviceHelper ssOnePixel], self.view.width, [TTDeviceHelper ssOnePixel]);
    
    if ([self.categoryButtons count] == 2) {
        TSVCategorySelectorButton *firstButton = [self.categoryButtons firstObject];
        firstButton.right = width / 2;
        TSVCategorySelectorButton *secondButton = [self.categoryButtons lastObject];
        secondButton.left = width / 2;
        self.scrollView.contentSize = CGSizeMake(width, kCategoryItemHeight);
        self.scrollView.contentInset = UIEdgeInsetsZero;
    } else if ([self.categoryButtons count] == 3) {
        TSVCategorySelectorButton *midButton = [self.categoryButtons objectAtIndex:1];
        midButton.centerX = width / 2;
        TSVCategorySelectorButton *firstButton = [self.categoryButtons firstObject];
        firstButton.right = midButton.left;
        TSVCategorySelectorButton *lastButton = [self.categoryButtons lastObject];
        lastButton.left = midButton.right;
        self.scrollView.contentSize = CGSizeMake(width, kCategoryItemHeight);
        self.scrollView.contentInset = UIEdgeInsetsZero;
    } else if ([self.categoryButtons count] > 0) {
        CGFloat offsetX = 5;
        for (TSVCategorySelectorButton *button in self.categoryButtons) {
            button.left = offsetX;
            offsetX += button.width;
        }
        self.scrollView.contentSize = CGSizeMake(offsetX, kCategoryItemHeight);
        if ([[self class] rightButtonType] == TSVTabTopBarRightButtonTypeSearch ||
            [[self class] rightButtonType] == TSVTabTopBarRightButtonTypePublish) {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 50);
        } else {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 5);
        }
    }
    
    if (self.viewModel.currentIndex < self.categoryButtons.count) {
        TSVCategorySelectorButton *button = self.categoryButtons[self.viewModel.currentIndex];
        [self refreshSelectBackViewCenter:button.center newButton:button with:NO];
    }
}

- (void)scrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percentage
{
    if(fromIndex < self.categoryButtons.count && toIndex < self.categoryButtons.count && fromIndex >= 0 && toIndex >= 0 && fromIndex != toIndex)
    {
        
        TSVCategorySelectorButton *fromButton = self.categoryButtons[fromIndex];
        TSVCategorySelectorButton *toButton = self.categoryButtons[toIndex];
        
        CGFloat transformScaleDelta = ([[TSVCategorySelectorButton class] channelSelectedFontSize] / [[TSVCategorySelectorButton class] channelFontSize] - 1);
        CGFloat percent = fabs(percentage);
        
        percent = MIN(1, MAX(0, percent));
        
        CGFloat fromScale = 1 + transformScaleDelta * (1 - percent);
        CGFloat toScale = 1 + transformScaleDelta * percent;
        
        fromButton.titleLabel.transform = CGAffineTransformMakeScale(fromScale, fromScale);
        toButton.titleLabel.transform = CGAffineTransformMakeScale(toScale, toScale);
        
        fromButton.maskTitleLabel.transform = fromButton.titleLabel.transform;
        toButton.maskTitleLabel.transform = toButton.titleLabel.transform;
        
        fromButton.titleLabel.alpha = percent;
        toButton.titleLabel.alpha = 1 - percent;
        
        fromButton.maskTitleLabel.alpha = 1 - percent;
        toButton.maskTitleLabel.alpha = percent;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex scrollToPositionAnimated:(BOOL)animated
{
    if (self.viewModel.currentIndex != currentIndex) {
        [self scrollToIndex:currentIndex animated:animated];
        [self didScrollToIndex:currentIndex];
    }
}

- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated
{
    if (toIndex < self.categoryButtons.count) {
        
        TSVCategorySelectorButton *button = self.categoryButtons[toIndex];
        
        CGFloat offsetX = 0;
        CGFloat distanceFromButtonToCenter = button.centerX - self.scrollView.width / 2;
        CGFloat maxOffsetX = MAX(_scrollView.contentSize.width + self.scrollView.contentInset.right - self.scrollView.width, 0);
        
        if (distanceFromButtonToCenter > 0) {
            offsetX = distanceFromButtonToCenter;
        }
        
        if (offsetX > maxOffsetX) {
            offsetX = maxOffsetX;
        }
        
        void (^animationBlock)(void) = ^{
            [self.scrollView setContentOffset:CGPointMake(offsetX, 0)];
        };
        if (animated) {
            [UIView animateWithDuration:.4 animations:^{
                animationBlock();
            }];
        } else {
            animationBlock();
        }
    }
}

- (void)didScrollToIndex:(NSInteger)toIndex
{
    NSInteger buttonIndex = 0;
    for (TSVCategorySelectorButton *button in self.categoryButtons) {
        if (buttonIndex == toIndex) {
            [button setSelected:YES animated:NO];
        } else {
            [button setSelected:NO animated:NO];
        }
        buttonIndex ++;
    }
    self.viewModel.currentIndex = toIndex;
    TSVCategorySelectorButton *toButton = self.categoryButtons[toIndex];
    [self refreshSelectBackViewCenter:toButton.center newButton:toButton with:NO];
}

- (void)refreshSelectBackViewCenter:(CGPoint)position newButton:(TSVCategorySelectorButton *)categoryButton with:(BOOL)animation
{
    if (self.selectedBackView.alpha == 0) {
        [UIView animateWithDuration:.25 animations:^{
            self.selectedBackView.alpha = 1;
        }];
    }
    if (fabs(self.selectedBackView.width - categoryButton.width) > 10) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.selectedBackView.width = categoryButton.width;
        self.selectedBackLayer.frame = self.selectedBackView.bounds;
        [CATransaction commit];
    }
    if (animation && self.selectedBackView.alpha == 1) {
        
    } else {
        self.selectedBackView.center = position;
    }
}

- (void)searchBtnClicked:(id)sender
{
    ExploreSearchViewController * viewController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:NO queryStr:nil fromType:ListDataSearchFromTypeHotsoonVideo];
    viewController.animatedWhenDismiss = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

static NSString * const TTShortVideoTabIntroHasOpenedUserDefaulsKey = @"TTShortVideoTabIntroHasOpenedUserDefaulsKey";
static NSString * const kTTNotificationNameRedpackIntroUpdated = @"kTTNotificationNameRedpackIntroUpdated";

- (void)publishBtnClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TTShortVideoTabIntroHasOpenedUserDefaulsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

//    [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) setShortVideoTabIntroHasClicked];
    
////    if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) shouldShowSpringShortVideoRedPackGuide]) {
//        [self openSpringShortVideoTemplatePage];
//    } else {
        [TTTrackerWrapper eventV3:@"click_publisher_shortvideo_top" params:@{
                                                                             @"tab_name": @"hotsoon_video",
                                                                             @"category_name": [self.viewModel currentCategoryName],
                                                                             }];
        [[TTModuleBridge sharedInstance_tt] triggerAction:@"TTRecordVideoViewControllerPresentAction"
                                                   object:nil
                                               withParams:@{
                                                            @"cid" : kTTShortVideoConcernID,
                                                            @"style" : @"shortvideo",
                                                            @"shoot_entrance" : @"shortvideo_top",
                                                            @"tab_name" : @"hotsoon_video", //当前tap，从小视频右上角来肯定是小视频tab
                                                            @"category_name" : [self.viewModel currentCategoryName], //当前用户所在的小视频子频道
                                                            }
                                                 complete:nil];
//    }
}

- (void)openSpringShortVideoTemplatePage {
//    [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) didEnterSpringShortVideoRedPackEntrance];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://sf_video_style"];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:nil];
    }
}
    
- (void)themeReload
{
    UIColor *color = [UIColor tt_themedColorForKey:kColorBackground4];
    self.view.backgroundColor = color;
    self.scrollView.backgroundColor = color;
    self.rightBackLayer.backgroundColor = color.CGColor;
    self.rightGradientLayer.colors = @[(__bridge id)[color colorWithAlphaComponent:0].CGColor, (__bridge id)[color colorWithAlphaComponent:1].CGColor];
}

- (NSArray<NSString *> *)categorySelectorTextColors {
    return nil;
}

- (NSArray <NSString *> *)categorySelectorTextGlowColors {
    return nil;
}

- (CGFloat)categorySelectorTextGlowSize {
    return 0;
}

+ (TSVTabTopBarRightButtonType)rightButtonType
{
    NSUInteger buttonTypeIndex = [[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_tab_show_search" defaultValue:@(0) freeze:YES] integerValue];
    if (buttonTypeIndex == 1) {
        return TSVTabTopBarRightButtonTypeSearch;
    } else if (buttonTypeIndex == 2) {
        return TSVTabTopBarRightButtonTypePublish;
    } else {
        return TSVTabTopBarRightButtonTypeNone;
    }
}

@end
