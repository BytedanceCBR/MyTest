//
//  TTForwardSharePanelController.m
//  TTShareService
//
//  Created by jinqiushi on 2018/1/17.
//


#import "TTForwardSharePanelController.h"
#import "SSThemed.h"
#import <Masonry/Masonry.h>
#import "TTRichSpanText.h"
#import "TTCategoryDefine.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"

#import "UIImageView+WebCache.h"
#import "TTUGCPodBridge.h"
#import "TTDeviceUIUtils.h"
#import "TTRepostThreadSchemaQuoteView.h"

#import <TTShare/TTActivityProtocol.h>
#import <TTShare/TTShareAdapterSetting.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTThemed/SSThemed.h>
#import <TTThemed/TTThemeManager.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "UIButton+TTAdditions.h"
#import "TTActivityPanelDefine.h"

#import "TTWechatActivity.h"
#import "TTWechatTimelineActivity.h"
#import "TTQQZoneActivity.h"
#import "TTQQFriendActivity.h"
//#import "TTDingTalkActivity.h"
//#import "TTSystemActivity.h"
//#import "TTCopyActivity.h"
#import "TTForwardWeitoutiaoActivity.h"
#import "TTDirectForwardWeitoutiaoActivity.h"
#import "TTForwardWeitoutiaoContentItem.h"
#import "TTDirectForwardWeitoutiaoContentItem.h"
#import "TTRepostServiceProtocol.h"


#define kShareRegionHeight ([TTDeviceUIUtils tt_newPadding:124.0])
#define kForwardRegionHeight ([TTDeviceUIUtils tt_newPadding:184.0])
#define kForwardSharePanelHeight (kShareRegionHeight + kForwardRegionHeight + 1.0)
#define kForwardSharePanelPadding 8.0
#define kShareImageWidth 60.0
#define kSharePanelButtonWidth  ([UIScreen mainScreen].bounds.size.width<375 ? 68:80)
#define kForwardShareCancelButtonHeight ([TTDeviceUIUtils tt_newPadding:44.0])

@interface TTForwardSharePanelButton : SSThemedButton

- (instancetype)initWithFrame:(CGRect)frame item:(id<TTActivityProtocol>)item index:(NSUInteger)index;

@property (nonatomic, strong) SSThemedImageView *iconImageView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, assign) NSUInteger index;

@end

@implementation TTForwardSharePanelButton

- (instancetype)initWithFrame:(CGRect)frame item:(id<TTActivityProtocol>)item index:(NSUInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _iconImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kShareImageWidth, kShareImageWidth)];
        _iconImageView.centerX = kSharePanelButtonWidth / 2.0;

        //不知道为啥他的这段逻辑这么啰嗦
        TTActivityPanelControllerItemLoadImageType itemLoadImageType = TTActivityPanelControllerItemLoadImageTypeThemed;
        TTActivityPanelControllerItemUIType itemUIType = 0;
        if ([item conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]) {
            if ([item respondsToSelector:@selector(itemLoadImageType)]) {
                itemLoadImageType = [(id<TTActivityPanelActivityProtocol>)item itemLoadImageType];
            }
            if ([item respondsToSelector:@selector(itemUIType)]) {
                itemUIType = [(id<TTActivityPanelActivityProtocol>)item itemUIType];
            }
        }
        
        switch (itemLoadImageType) {
            case TTActivityPanelControllerItemLoadImageTypeThemed: {
                NSString * imageName = nil;
                if ([item conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]
                    && [item respondsToSelector:@selector(itemImageName)]) {
                    imageName = [(id<TTActivityPanelActivityProtocol>)item itemImageName];
                }else {
                    imageName = [item activityImageName];
                }
                _iconImageView.imageName = imageName;
            }
                break;
            case TTActivityPanelControllerItemLoadImageTypeURL: {
                _iconImageView.enableNightCover = YES;
                NSString * imageURL = nil;
                if ([item conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]
                    && [item respondsToSelector:@selector(itemImageURL)]) {
                    imageURL = [(id<TTActivityPanelActivityProtocol>)item itemImageURL];
                }
                if (!isEmptyString(imageURL)) {
                    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                                          placeholderImage:nil];
                }
            }
                break;
            case TTActivityPanelControllerItemLoadImageTypeImage: {
                UIImage * image = nil;
                if ([item conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]
                    && [item respondsToSelector:@selector(itemImage)]) {
                    image = [(id<TTActivityPanelActivityProtocol>)item itemImage];
                }
                _iconImageView.image = image;
            }
                break;
            default:
                break;
        }
        
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kSharePanelButtonWidth, 14.0)];
        _nameLabel.textColorThemeKey = kColorText1;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:10.0];
        _nameLabel.text = item.contentTitle;
        
        _nameLabel.bottom = self.height - [TTDeviceUIUtils tt_newPadding:20.0];
        _iconImageView.bottom = _nameLabel.bottom - 14.0 + 2.0;
        
        self.index = index;
        
        [self addSubview:_iconImageView];
        [self addSubview:_nameLabel];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.iconImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.iconImageView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

@end

@interface TTPanelForwardView : SSThemedView

- (instancetype)initWithWeitoutiaoContentItem:(TTForwardWeitoutiaoContentItem *)weitoutiaoContentItem toucheAction:(void(^)(void))toucheAction publishAction:(void(^)(void))publishAction;

@property (nonatomic, strong) TTForwardWeitoutiaoContentItem * weitoutiaoContentItem;
@property (nonatomic, strong) TTRepostThreadSchemaQuoteView *quoteView;
@property (nonatomic, strong) SSThemedButton *titleButton;
@property (nonatomic, strong) SSThemedButton *publishButton;
@property (nonatomic, strong) SSThemedView *cursorView;
@property (nonatomic, assign) BOOL stopCursorAnimating;
@property (nonatomic, strong) SSThemedLabel *indicateLabel;
@property (nonatomic, strong) SSThemedButton *backgroundButton;

@property (nonatomic, strong) void(^touchBlock)(void);
@property (nonatomic, strong) void(^publishBlock)(void);


@end

@implementation TTPanelForwardView

- (instancetype)initWithWeitoutiaoContentItem:(TTForwardWeitoutiaoContentItem *)weitoutiaoContentItem toucheAction:(void(^)(void))toucheAction publishAction:(void(^)(void))publishAction
{
    if (self = [super init]) {
        self.quoteView = [[TTRepostThreadSchemaQuoteView alloc] initWithRepostParam:weitoutiaoContentItem.repostParams];
        self.quoteView.userInteractionEnabled = NO;
        self.publishBlock = publishAction;
        self.touchBlock = toucheAction;
        
        self.backgroundColorThemeKey = kColorBackground4;
        [self configViews];
        [self configLayout];
        [self animateCursor];
    }
    return self;
}

- (void)configViews
{
    [self addSubview:self.backgroundButton];
    [self addSubview:self.quoteView];
    [self addSubview:self.titleButton];
    [self addSubview:self.publishButton];
    [self addSubview:self.indicateLabel];
    [self addSubview:self.cursorView];
}

- (void)configLayout
{
    [self.backgroundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset([TTDeviceUIUtils tt_newPadding:15.0]);
        make.top.equalTo(self.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:12.0]);
        make.height.equalTo(@([TTDeviceUIUtils tt_newPadding:22.0]));
        make.width.lessThanOrEqualTo(@(MAX(82.0, [TTDeviceUIUtils tt_newPadding:82.0])));
    }];
    
    [self.publishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset([TTDeviceUIUtils tt_newPadding:-15.0]);
        make.top.equalTo(self.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:12.0]);
        make.height.equalTo(@([TTDeviceUIUtils tt_newPadding:22.0]));
        make.width.lessThanOrEqualTo(@(MAX(64.0, [TTDeviceUIUtils tt_newPadding:64.0])));
    }];
    
    [self.quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@70.0);
        make.left.equalTo(self.mas_left).with.offset([TTDeviceUIUtils tt_newPadding:15.0]);
        make.right.equalTo(self.mas_right).with.offset([TTDeviceUIUtils tt_newPadding:-15.0]);
        make.bottom.equalTo(self.mas_bottom).with.offset([TTDeviceUIUtils tt_newPadding:-15.5]);
    }];
    
    [self.indicateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset([TTDeviceUIUtils tt_newPadding:21.0]);
        make.right.equalTo(self.quoteView.mas_right);
        make.bottom.equalTo(self.quoteView.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:-10.5]);
        make.height.equalTo(@([TTDeviceUIUtils tt_newPadding:24.0]));
    }];
    
    [self.cursorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.quoteView.mas_left);
        make.height.equalTo(@([TTDeviceUIUtils tt_newPadding:18.0]));
        make.width.equalTo(@(2));
        make.bottom.equalTo(self.quoteView.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:-13.5]);
    }];
}

- (void)animateCursor
{
    if (self.stopCursorAnimating) {
        return;
    }
    WeakSelf;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.cursorView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.cursorView.alpha = 0.0;
        } completion:^(BOOL finished) {
            StrongSelf;
            [self animateCursor];
        }];
    }];
}

- (SSThemedButton *)titleButton
{
    if (!_titleButton) {
        _titleButton = [[SSThemedButton alloc] init];
        _titleButton.backgroundColor = [UIColor clearColor];
        _titleButton.titleColorThemeKey = kColorText1;
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _titleButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:[TTDeviceUIUtils tt_newPadding:16.0]];
        } else {
            _titleButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:16.0]];
        }
        if ([UIScreen mainScreen].bounds.size.width < 375) {
            _titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, [TTDeviceUIUtils tt_newPadding:-1.0], 0, 0);
        }
        [_titleButton setTitle:@"转发到爱看" forState:UIControlStateNormal];
        _titleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleButton.userInteractionEnabled = NO;
    }
    return _titleButton;
}

- (SSThemedButton *)publishButton
{
    if (!_publishButton) {
        _publishButton = [[SSThemedButton alloc] init];
        _publishButton.backgroundColor = [UIColor clearColor];
        _publishButton.titleColorThemeKey = kColorText6;
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _publishButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:[TTDeviceUIUtils tt_newPadding:16.0]];
        } else {
            _publishButton.titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newPadding:16.0]];
        }
        if ([UIScreen mainScreen].bounds.size.width <375) {
            _publishButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, [TTDeviceUIUtils tt_newPadding:-4.0]);
        } else {
            _publishButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, [TTDeviceUIUtils tt_newPadding:-2.0]);
        }
        [_publishButton setTitle:@"立即转发" forState:UIControlStateNormal];
        _publishButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [_publishButton setHitTestEdgeInsets:UIEdgeInsetsMake(-15.0, -5.0, -5.0, -15.0)];
        [_publishButton addTarget:self withActionBlock:self.publishBlock forControlEvent:UIControlEventTouchUpInside];
    }
    return _publishButton;
}

- (SSThemedButton *)backgroundButton
{
    if (!_backgroundButton) {
        _backgroundButton = [[SSThemedButton alloc] init];
        _backgroundButton.backgroundColor = [UIColor clearColor];
        [_backgroundButton addTarget:self withActionBlock:self.touchBlock forControlEvent:UIControlEventTouchUpInside];
        _backgroundButton.userInteractionEnabled = YES;
    }
    return _backgroundButton;
}

- (SSThemedLabel *)indicateLabel
{
    if (!_indicateLabel) {
        _indicateLabel = [[SSThemedLabel alloc] init];
        _indicateLabel.backgroundColor = [UIColor clearColor];
        _indicateLabel.textColorThemeKey = kColorText3;
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _indicateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:[TTDeviceUIUtils tt_newPadding:17.0]];
        } else {
            _indicateLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:17.0]];
        }
        _indicateLabel.text = @"说说你的看法";
        _indicateLabel.textAlignment = NSTextAlignmentLeft;
        _indicateLabel.userInteractionEnabled = NO;
    }
    return _indicateLabel;
}
- (SSThemedView *)cursorView
{
    if (!_cursorView) {
        _cursorView = [[SSThemedView alloc] init];
        _cursorView.backgroundColorThemeKey = kColorText6;
        _cursorView.layer.cornerRadius = 1;
        _cursorView.clipsToBounds = YES;
        _cursorView.alpha = 0.0;
    }
    return _cursorView;
}
@end

@interface TTForwardSharePanelWindow ()

@property (nonatomic, strong) TTForwardSharePanelController *panel;

@end

@implementation TTForwardSharePanelWindow
@end

@interface TTForwardSharePanelController()

@property (nonatomic, strong) SSThemedScrollView *shareScrollView;
@property (nonatomic, strong) TTPanelForwardView *forwardView;
@property (nonatomic, strong) SSThemedView *panelView;
@property (nonatomic, strong) SSThemedView *separateLine;
@property (nonatomic, strong) SSThemedButton *cancelButton;
@property (nonatomic, strong) SSThemedView *maskView;
@property (nonatomic, strong) SSThemedView *alphaView;
@property (nonatomic, strong) TTForwardSharePanelWindow *backWindow;
@property (nonatomic, strong) UIWindow *originalKeyWindow;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, strong) void (^cancelBlock)(void);
@property (nonatomic, strong) NSArray<TTActivityProtocol> *notWeitoutiaoShareItems;
@property (nonatomic, strong) id<TTActivityProtocol> weitoutiaoItem;
@property (nonatomic, strong) id<TTActivityProtocol> directForwardItem;

@property (nonatomic, copy) NSString *cancelTitle;

@end

@implementation TTForwardSharePanelController

#pragma mark - 生命周期 & 协议方法
+ (void)load {
    [[TTShareAdapterSetting sharedService] setForwardSharePanelClassName:NSStringFromClass([self class])];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithItems:(NSArray <NSArray *> *)items cancelTitle:(NSString *)cancelTitle
{
    self = [super init];
    if (self) {
        _cancelTitle = cancelTitle.copy;
        
        NSMutableArray *allItems = [NSMutableArray arrayWithCapacity:9];
        [items enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [allItems addObjectsFromArray:obj];
        }];
        _weitoutiaoItem = [self weitoutiaoItemWithItems:allItems];
        _directForwardItem = [self directForwardItemWithItems:allItems];
        _notWeitoutiaoShareItems = [self notWeitoutiaoShareItemsWithItems:allItems];
        
        _originalKeyWindow = [UIApplication sharedApplication].keyWindow;
        CGRect windowFrame = [UIApplication sharedApplication].keyWindow.bounds;
        if (windowFrame.size.width != [UIScreen mainScreen].bounds.size.width && windowFrame.size.height != [UIScreen mainScreen].bounds.size.width) {
            _originalKeyWindow = [UIApplication sharedApplication].delegate.window;
            windowFrame = [UIApplication sharedApplication].delegate.window.bounds;
            
        }
        
        _rootViewController = [[UIViewController alloc] init];
        
        
        _backWindow = [[TTForwardSharePanelWindow alloc] init];
        _backWindow.rootViewController = self.rootViewController;
        _backWindow.backgroundColor = [UIColor clearColor];
        _backWindow.windowLevel = UIWindowLevelNormal;
        
        
        [_backWindow makeKeyAndVisible];
        _backWindow.frame = windowFrame;
        _backWindow.rootViewController.view.frame = _backWindow.bounds;
        
        UINavigationController *originNav = [TTUIResponderHelper correctTopNavigationControllerFor:self.originalKeyWindow.subviews.lastObject];
        [originNav.view addSubview:self.alphaView];
        
        [_rootViewController.view addSubview:self.maskView];
        [_rootViewController.view addSubview:self.shareScrollView];
        
        
        [self.rootViewController.view addSubview:self.panelView];
        [self.panelView addSubview:self.forwardView];
        [self.panelView addSubview:self.shareScrollView];
        [self.panelView addSubview:self.separateLine];
        
        SSThemedLabel *shareLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:15.0], self.shareScrollView.top + [TTDeviceUIUtils tt_newPadding:12.0], MAX(84.0, [TTDeviceUIUtils tt_newPadding:84.0]), 18.0)];
        shareLabel.text = @"分享到站外";
        shareLabel.textColorThemeKey = kColorText1;
        shareLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.0]];
        shareLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.panelView addSubview:shareLabel];
        
        
        
        [self.rootViewController.view addSubview:self.cancelButton];
        
        [self addNotifications];
    }
    return self;
}

- (void)show
{
    self.backWindow.panel = self;
    for (NSInteger i = 0; i < [self.notWeitoutiaoShareItems count]; i++) {
        TTForwardSharePanelButton *button = [self shareButtonIndex:i item:self.notWeitoutiaoShareItems[i]];
        [self.shareScrollView addSubview:button];
        
    }
    if ([self.notWeitoutiaoShareItems count] > 4) {
        self.shareScrollView.contentSize = CGSizeMake([self.notWeitoutiaoShareItems count] * kSharePanelButtonWidth, kShareRegionHeight);
        self.shareScrollView.alwaysBounceHorizontal = YES;
    }
    
    CGRect panelDstFrame = self.panelView.frame;
    CGRect cancelButtonDstFrame = self.cancelButton.frame;
    
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;

    self.panelView.top = self.panelView.top + kForwardSharePanelHeight + kForwardShareCancelButtonHeight + 2 * kForwardSharePanelPadding + bottomInset;
    self.cancelButton.top = self.cancelButton.top + kForwardSharePanelHeight + kForwardShareCancelButtonHeight + 2 * kForwardSharePanelPadding + bottomInset;
    
    self.alphaView.alpha = 0.0;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{

        self.panelView.frame = panelDstFrame;
        self.cancelButton.frame = cancelButtonDstFrame;
        self.alphaView.alpha = 1;
    } completion:nil];
}

- (void)hide
{
    [self cancelWithItem:nil animated:YES];
}

#pragma mark - Private

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootViewWillTransitionToSize:) name:kRootViewWillTransitionToSize object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)rootViewWillTransitionToSize:(id)sender
{
    [self cancelWithItem:nil animated:NO];
}

- (void)statusBarOrientationDidChange
{
    if (  UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ) {
        [self cancelWithItem:nil animated:NO];
    }
}

- (id<TTActivityProtocol>)weitoutiaoItemWithItems:(NSArray<TTActivityProtocol> *)items
{
    for (id<TTActivityProtocol> activity in items) {
        if ([activity.activityType isEqualToString:TTActivityTypeForwardWeitoutiao]) {
            return activity;
        }
    }
    return nil;
}

- (id<TTActivityProtocol>)directForwardItemWithItems:(NSArray<TTActivityProtocol> *)items
{
    for (id<TTActivityProtocol> activity in items) {
        if ([activity.activityType isEqualToString:TTActivityTypeDirectForwardWeitoutiao]) {
            return activity;
        }
    }
    return nil;
}

- (NSArray<TTActivityProtocol> *)notWeitoutiaoShareItemsWithItems:(NSArray<TTActivityProtocol> *)items
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:7];
    for (id<TTActivityProtocol> activity in items) {
        if ([activity.activityType isEqualToString:TTActivityTypePostToWechat]) {
            activity.contentItem.activityImageName = @"weixin_newShare";
            [mutableArray addObject:activity];
        } else if ([activity.activityType isEqualToString:TTActivityTypePostToWechatTimeline]) {
            activity.contentItem.activityImageName = @"pyq_newShare";
            [mutableArray addObject:activity];
        } else if ([activity.activityType isEqualToString:TTActivityTypePostToQQZone]) {
            activity.contentItem.activityImageName = @"qqkj_newShare";
            [mutableArray addObject:activity];
        } else if ([activity.activityType isEqualToString:TTActivityTypePostToQQFriend]) {
            activity.contentItem.activityImageName = @"qq_newShare";
            [mutableArray addObject:activity];
        }
//        } else if ([activity.activityType isEqualToString:TTActivityTypePostToDingTalk]) {
//            activity.contentItem.activityImageName = @"dingding_newShare";
//            [mutableArray addObject:activity];
//        } else if ([activity.activityType isEqualToString:TTActivityTypePostToSystem]) {
//            activity.contentItem.activityImageName = @"airdrop_newShare";
//            [mutableArray addObject:activity];
//        } else if ([activity.activityType isEqualToString:TTActivityTypePostToCopy]) {
//            activity.contentItem.activityImageName = @"copy_newShare";
//            [mutableArray addObject:activity];
//        }
    }
    
    return [mutableArray copy];
}

- (TTForwardSharePanelButton *)shareButtonIndex:(NSUInteger)index item:(id<TTActivityProtocol>)item
{
    TTForwardSharePanelButton *button;
    if (self.notWeitoutiaoShareItems.count < 4) {
        CGFloat width = self.shareScrollView.width;
        CGFloat devideWidth = width/self.notWeitoutiaoShareItems.count;
        CGFloat centerX = devideWidth * index + devideWidth/2.0;
        button = [[TTForwardSharePanelButton alloc] initWithFrame:CGRectMake(centerX - kSharePanelButtonWidth/2.0, 0, kSharePanelButtonWidth, self.shareScrollView.height) item:item index:index];
        return button;
    } else {
        CGRect frame = CGRectMake(index * kSharePanelButtonWidth, 0, kSharePanelButtonWidth, self.shareScrollView.height);
        button = [[TTForwardSharePanelButton alloc] initWithFrame:frame item:item index:index];
    }
    [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}



#pragma mark - Getters

- (SSThemedScrollView *)shareScrollView
{
    if (!_shareScrollView) {

        _shareScrollView = [[SSThemedScrollView alloc] initWithFrame:CGRectMake(0, kForwardRegionHeight + 1.0, self.panelView.width, kShareRegionHeight)];

        if (@available(iOS 11.0, *)){
            _shareScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _shareScrollView.backgroundColorThemeKey = kColorBackground4;
        _shareScrollView.clipsToBounds = YES;

        _shareScrollView.showsHorizontalScrollIndicator = NO;
        _shareScrollView.showsVerticalScrollIndicator = NO;
       
        _shareScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
    }
    return _shareScrollView;
}

- (TTPanelForwardView *)forwardView
{
    if (!_forwardView) {
        WeakSelf;
        _forwardView = [[TTPanelForwardView alloc] initWithWeitoutiaoContentItem:self.weitoutiaoItem.contentItem toucheAction:^{
            StrongSelf;
            [self enterForwardAction:nil];
        } publishAction:^{
            StrongSelf;
            [self publishAction:nil];
        }];
        _forwardView.frame = CGRectMake(0, 0, self.panelView.width, kForwardRegionHeight);
        _forwardView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
    }
    return _forwardView;
}

- (SSThemedView *)separateLine
{
    if (!_separateLine) {
        _separateLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, floor(kForwardRegionHeight), self.panelView.width, 1.0)];
        _separateLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _separateLine.backgroundColorThemeKey = kColorBackground9;
    }
    return _separateLine;
}

- (SSThemedView *)panelView
{
    if (!_panelView) {
        CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;

        _panelView = [[SSThemedView alloc] initWithFrame:CGRectMake(kForwardSharePanelPadding, self.maskView.height - 2 * kForwardSharePanelPadding - kForwardShareCancelButtonHeight - kForwardSharePanelHeight - bottomInset, self.maskView.width - 2 * kForwardSharePanelPadding, kForwardSharePanelHeight)];
        _panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _panelView.layer.cornerRadius = 8.0;
        _panelView.clipsToBounds = YES;
        _panelView.backgroundColorThemeKey = kColorBackground4;

    }
    return _panelView;
}

- (SSThemedButton *)cancelButton
{
    if (!_cancelButton) {
        CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;

        _cancelButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(kForwardSharePanelPadding, self.maskView.height - kForwardSharePanelPadding - kForwardShareCancelButtonHeight - bottomInset, self.maskView.width - 2 * kForwardSharePanelPadding, kForwardShareCancelButtonHeight)];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _cancelButton.layer.cornerRadius = 8.0;
        _cancelButton.clipsToBounds = YES;
        _cancelButton.backgroundColorThemeKey = kColorBackground4;
        [_cancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
        _cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _cancelButton.titleColorThemeKey = kColorText1;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.0]];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (SSThemedView *)maskView
{
    if (!_maskView) {
        _maskView = [[SSThemedView alloc] initWithFrame:self.backWindow.bounds];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonAction:)];
        [_maskView  addGestureRecognizer:tap];
    }
    return _maskView;
}

- (SSThemedView *)alphaView;
{
    if (!_alphaView) {
        _alphaView = [[SSThemedView alloc] initWithFrame:self.originalKeyWindow.bounds];
        _alphaView.backgroundColorThemeKey = kColorBackground9;
        _alphaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _alphaView;
}

#pragma mark - Actions

- (void)enterForwardAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
        [self.delegate activityPanel:self clickedWith:self.weitoutiaoItem];
    }
    
    [self cancelWithItem:self.weitoutiaoItem animated:NO keepAlphaView:YES];
}

- (void)publishAction:(id)sender
{
    if ([self.directForwardItem.contentItem isKindOfClass:[TTDirectForwardWeitoutiaoContentItem class]]) {
        TTDirectForwardWeitoutiaoContentItem *directWeitoutiaoContentItem = (TTDirectForwardWeitoutiaoContentItem *)self.directForwardItem.contentItem;
        NSDictionary *repostParams = directWeitoutiaoContentItem.repostParams;
        if (SSIsEmptyDictionary(repostParams)) {
            TTForwardWeitoutiaoContentItem *forwardWeitoutiaoContentItem = (TTForwardWeitoutiaoContentItem *)self.weitoutiaoItem.contentItem;
            repostParams = forwardWeitoutiaoContentItem.repostParams;
        }
        UIViewController *baseVC = [TTUIResponderHelper correctTopmostViewController];
        id<TTRepostServiceProtocol> repostServiceIMP = GET_SERVICE_BY_PROTOCOL(TTRepostServiceProtocol);
        [repostServiceIMP directSendRepostWithRepostParams:repostParams baseViewController:baseVC trackDict:@{@"section":@"detail_bottom_bar"}];
    } 
    
    if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
        [self.delegate activityPanel:self clickedWith:self.directForwardItem];
    }
    [self cancelWithItem:self.directForwardItem animated:YES];
}


- (void)buttonClickAction:(TTForwardSharePanelButton *)sender
{
    if (sender.index > self.notWeitoutiaoShareItems.count - 1) {
        return;
    }
    id<TTActivityProtocol> activity = self.notWeitoutiaoShareItems[sender.index];
    
    if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
        [self.delegate activityPanel:self clickedWith:activity];
    }
    [self cancelWithItem:activity animated:YES];
}

- (void)cancelButtonAction:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
        [self.delegate activityPanel:self clickedWith:nil];
    }
    [self cancelWithItem:nil animated:YES];
}


- (void)cancelWithItem:(id<TTActivityProtocol>)activity animated:(BOOL)animated
{
    [self cancelWithItem:activity animated:animated keepAlphaView:NO];
}

- (void)cancelWithItem:(id<TTActivityProtocol>)activity animated:(BOOL)animated keepAlphaView:(BOOL)keepAlphaView
{
    //面板消失之后，由于shareManager持有面板类，因此面板暂时不会被dealloc
    //这里必须手动关掉模拟光标的动画，否则会导致cpu占有率一直100%
    self.forwardView.stopCursorAnimating = YES;
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _panelView.top = _panelView.top + kForwardSharePanelHeight + kForwardShareCancelButtonHeight + 2 * kForwardSharePanelPadding;
            _cancelButton.top = _cancelButton.top + kForwardSharePanelHeight + kForwardShareCancelButtonHeight + 2 * kForwardSharePanelPadding;
            _backWindow.alpha = 0.0;
            _alphaView.alpha = 0.0;
        } completion:^(BOOL finished) {
            _backWindow.windowLevel = UIWindowLevelNormal - 1.0;
            [_originalKeyWindow makeKeyAndVisible];
            _backWindow.hidden = YES;
            _backWindow.panel = nil;
            _backWindow.rootViewController = nil;
            [_backWindow removeFromSuperview];
            _backWindow = nil;
            [_alphaView removeFromSuperview];
            _alphaView = nil;
            WeakSelf;
            [activity performActivityWithCompletion:^(id<TTActivityProtocol> activity, NSError *error, NSString *desc) {
                StrongSelf;
                if ([self.delegate respondsToSelector:@selector(activityPanel:completedWith:error:desc:)]) {
                    [self.delegate activityPanel:self completedWith:activity error:error desc:desc];
                }
                
                
            }];
        }];
    } else {
        _backWindow.windowLevel = UIWindowLevelNormal - 1.0;
        [_originalKeyWindow makeKeyAndVisible];
        _backWindow.hidden = YES;
        _backWindow.panel = nil;
        _backWindow.rootViewController = nil;
        [_backWindow removeFromSuperview];
        _backWindow = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((keepAlphaView ? 1.0:0.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_alphaView removeFromSuperview];
            _alphaView = nil;
        });
        WeakSelf;
        [activity performActivityWithCompletion:^(id<TTActivityProtocol> activity, NSError *error, NSString *desc) {
            StrongSelf;
            if ([self.delegate respondsToSelector:@selector(activityPanel:completedWith:error:desc:)]) {
                [self.delegate activityPanel:self completedWith:activity error:error desc:desc];
            }
        }];
    }
    
}

@end


