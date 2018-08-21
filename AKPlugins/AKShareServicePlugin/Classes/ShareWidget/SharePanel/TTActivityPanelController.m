//
//  TTActivityPanelController.m
//  Article
//
//  Created by zhaopengwei on 15/7/26.
//
//

#import "TTActivityPanelController.h"
#import "TTActivityPanelDefine.h"

#import <TTShare/TTActivityProtocol.h>
#import <TTShare/TTShareAdapterSetting.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTThemed/SSThemed.h>
#import <TTThemed/TTThemeManager.h>
#import <TTUIWidget/TTAlphaThemedButton.h>

#import <SDWebImage/UIImageView+WebCache.h>
#import "TTSharePanelTransformMessage.h"
#import <Aspects/Aspects.h>

static const CGFloat kTTActivityPanelSingleRowHeight = 116.f;
static const CGFloat kTTActivityPanelRowHorizontalEdgeInset = 16.f;
static const CGFloat kTTActivityPanelRowSeparateLineHorizontalPadding = 22.f;

static const CGFloat kTTActivityPanelItemTopPadding = 10.f;
static const CGFloat kTTActivityPanelItemWidth = 72.f;
static const CGFloat kTTActivityPanelItemImageViewLeftPadding = 6.f;
static const CGFloat kTTActivityPanelItemImageViewTopPadding = 12.f;
static const CGFloat kTTActivityPanelItemImageViewWidth = 60.f;

static const CGFloat kTTActivityPanelCancelButtonHeight = 48.f;

#pragma mark - TTActivityPanelThemedButton

@interface TTActivityPanelThemedButton : SSThemedButton

@property (nonatomic, strong) id<TTActivityProtocol> activity;
@property (nonatomic, strong) id<TTActivityContentItemProtocol> contentItem;
@property (nonatomic, strong) NSIndexPath *itemIndexPath;
@property (nonatomic, strong) SSThemedImageView *itemImageView;
@property (nonatomic, strong) SSThemedLabel *itemTitleLabel;

@end

@implementation TTActivityPanelThemedButton

- (instancetype)initWithFrame:(CGRect)frame
                         item:(id<TTActivityProtocol>)activity
                itemIndexPath:(NSIndexPath *)itemIndexPath {
    self = [super initWithFrame:frame];
    if (self) {
        self.activity = activity;
        self.contentItem = [activity contentItem];
        [(NSObject *)self.contentItem addObserver:self
                                       forKeyPath:@"selected"
                                          options:NSKeyValueObservingOptionNew
                                          context:nil];
        self.itemIndexPath = itemIndexPath;
        self.itemImageView = [[SSThemedImageView alloc] initWithFrame:
                              CGRectMake(kTTActivityPanelItemImageViewLeftPadding,
                                         kTTActivityPanelItemImageViewTopPadding,
                                         kTTActivityPanelItemImageViewWidth,
                                         kTTActivityPanelItemImageViewWidth)];
        [self addSubview:self.itemImageView];
        
        self.itemTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 78, 72, 12)];
        self.itemTitleLabel.font = [UIFont systemFontOfSize:10.0f];
        self.itemTitleLabel.textColorThemeKey = kColorText1;
        self.itemTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.itemTitleLabel];
        
        [self refreshUI];
    }
    
    return self;
}

- (void)dealloc {
    [(NSObject *)self.contentItem removeObserver:self forKeyPath:@"selected"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.contentItem && [keyPath isEqualToString:@"selected"]) {
        [self refreshUI];
    }
}

- (void)refreshUI {
    self.itemImageView.enableNightCover = NO;
    self.itemImageView.imageName = nil;
    self.itemImageView.image = nil;
    self.itemImageView.layer.borderColor = nil;
    self.itemImageView.layer.masksToBounds = NO;
    self.itemImageView.layer.borderWidth = 0;
    self.itemImageView.layer.cornerRadius = 0;
    self.itemImageView.clipsToBounds = YES;
    
    TTActivityPanelControllerItemLoadImageType itemLoadImageType = TTActivityPanelControllerItemLoadImageTypeThemed;
    TTActivityPanelControllerItemUIType itemUIType = 0;
    if ([self.activity conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]) {
        if ([self.activity respondsToSelector:@selector(itemLoadImageType)]) {
            itemLoadImageType = [(id<TTActivityPanelActivityProtocol>)self.activity itemLoadImageType];
        }
        if ([self.activity respondsToSelector:@selector(itemUIType)]) {
            itemUIType = [(id<TTActivityPanelActivityProtocol>)self.activity itemUIType];
        }
    }
    
    switch (itemLoadImageType) {
        case TTActivityPanelControllerItemLoadImageTypeThemed: {
            NSString * imageName = nil;
            if ([self.activity conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]
                && [self.activity respondsToSelector:@selector(itemImageName)]) {
                imageName = [(id<TTActivityPanelActivityProtocol>)self.activity itemImageName];
            }else {
                imageName = [self.activity activityImageName];
            }
            self.itemImageView.imageName = imageName;
        }
            break;
        case TTActivityPanelControllerItemLoadImageTypeURL: {
            self.itemImageView.enableNightCover = YES;
            NSString * imageURL = nil;
            if ([self.activity conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]
                && [self.activity respondsToSelector:@selector(itemImageURL)]) {
                imageURL = [(id<TTActivityPanelActivityProtocol>)self.activity itemImageURL];
            }
            if (!isEmptyString(imageURL)) {
                [self.itemImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                                      placeholderImage:nil];
            }
        }
            break;
        case TTActivityPanelControllerItemLoadImageTypeImage: {
            UIImage * image = nil;
            if ([self.activity conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]
                && [self.activity respondsToSelector:@selector(itemImage)]) {
                image = [(id<TTActivityPanelActivityProtocol>)self.activity itemImage];
            }
            self.itemImageView.image = image;
        }
            break;
        default:
            break;
    }
    if (itemUIType & TTActivityPanelControllerItemUITypeBorder) {
        NSString *borderColor = TTThemeModeNight == [[TTThemeManager sharedInstance_tt] currentThemeMode]?@"363636":@"cacaca";
        self.itemImageView.layer.borderColor = [UIColor colorWithHexString:borderColor].CGColor;
        self.itemImageView.layer.masksToBounds = YES;
        self.itemImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    }
    if (itemUIType & TTActivityPanelControllerItemUITypeCornerRadius) {
        self.itemImageView.layer.cornerRadius = kTTActivityPanelItemImageViewWidth/2;
    }
    
    NSString * title = [self.activity contentTitle];
    if ([self.contentItem conformsToProtocol:@protocol(TTActivityContentItemSelectedDigProtocol)]) {
        int64_t count = [(id<TTActivityContentItemSelectedDigProtocol>)self.contentItem count];
        self.itemTitleLabel.text = [NSString stringWithFormat:@"%@%lld", title, count];
    }else {
        self.itemTitleLabel.text = title;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.3
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.itemImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                         } completion:nil];
    } else {
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.3
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.itemImageView.transform = CGAffineTransformIdentity;
                         } completion:nil];
    }
}

@end

#pragma mark - TTActivityPanelControllerWindow

@interface TTActivityPanelControllerWindow : UIWindow

@property (strong, nonatomic) TTActivityPanelController *panel;

@end

@implementation TTActivityPanelControllerWindow

@end

#pragma mark - TTActivityPanelRootViewController

@interface TTActivityPanelRootViewController : UIViewController
@end

@implementation TTActivityPanelRootViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end

#pragma mark - TTActivityPanelController

@interface TTActivityPanelController ()<TTSharePanelTransformMessage> {
    CGFloat _itemWidth;
}

@property (strong, nonatomic) NSMutableArray *scrollViews;
@property (strong, nonatomic) NSMutableArray <NSMutableArray *> *itemViews;
@property (strong, nonatomic) SSThemedView *backView;
@property (strong, nonatomic) SSThemedView *maskView;
@property (strong, nonatomic) SSThemedButton *cancelButton;
@property (strong, nonatomic) SSThemedView   *bottomSafeAreaView;
@property (strong, nonatomic) TTActivityPanelControllerWindow *backWindow;
@property (strong, nonatomic) TTActivityPanelRootViewController *rootViewController;
@property (strong, nonatomic) NSArray <NSArray *> *items;
@property (strong, nonatomic) NSString *cancelTitle;
@property (strong, nonatomic) UIWindow *originalKeyWindow;

@property (strong, nonatomic) TTSharePanelFullScreenTransformHandler fullScreenTransformHandlerBlock;

@end

@implementation TTActivityPanelController

#pragma mark -- Life cycle

+ (void)load {
    [[TTShareAdapterSetting sharedService] setPanelClassName:NSStringFromClass([self class])];
}

- (void)dealloc {
    [self removeNotification];
    UNREGISTER_MESSAGE(TTSharePanelTransformMessage, self);
}

- (instancetype)initWithItems:(NSArray <NSArray *> *)items cancelTitle:(NSString *)cancelTitle {
    self = [super init];
    if (self) {
        
        REGISTER_MESSAGE(TTSharePanelTransformMessage, self);
        self.scrollViews = [NSMutableArray array];
        self.itemViews = [NSMutableArray array];
        self.items = items;
        self.cancelTitle = cancelTitle;
        
        //熊zi: 分享中，iPhone6下，分享间距需要单图调整，统一间距要增加4PX（2X）保证分享露出半个图标，不然不知道还可以滑动
        _itemWidth = kTTActivityPanelItemWidth + ([TTDeviceHelper is667Screen] ? 8 : 0);
        
        [self addFullScreenTransformHandlerBlock];
        [self createComponents];
        [self addNotification];
    }
    
    return self;
}

#pragma mark -- Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rootViewWillTransitionToSize:)
                                                 name:kRootViewWillTransitionToSize
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationStautsBarDidRotate)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationStautsBarDidRotate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self willTransitionToSize:[UIApplication sharedApplication].delegate.window.bounds.size];
    });
}

- (void)rootViewWillTransitionToSize:(NSNotification *)noti {
    CGSize size = [noti.object CGSizeValue];
    [self willTransitionToSize:size];
}

- (void)willTransitionToSize:(CGSize)size {
    if ([TTDeviceHelper OSVersionNumber] < 8){
        CGRect frame = CGRectZero;
        frame.size = size;
        self.backWindow.frame = frame;
    }
    CGFloat hInset = 16;
    BOOL landscapeMode = _backWindow.bounds.size.width > _backWindow.bounds.size.height;
    if ([TTDeviceHelper isIPhoneXDevice] && landscapeMode){
        hInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.left;
    }
    if (hInset > 0){
        for (UIScrollView *scrollView in self.scrollViews){
            scrollView.contentInset = UIEdgeInsetsMake(0, hInset, 0, hInset);
        }
    }
}

- (void)addFullScreenTransformHandlerBlock
{
    __weak __typeof(self) wself = self;
    self.fullScreenTransformHandlerBlock = ^(BOOL isFullScreen,UIInterfaceOrientation orientation) {
        __strong __typeof(wself) sself = wself;
        if (isFullScreen) {
            sself.backWindow.transform = [sself transformForRotationAngle:orientation];;
        }else{
            sself.backWindow.transform = CGAffineTransformIdentity;
        }
        
    };
}

- (void)refreshStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    id<AspectToken> aspectToken = [UIViewController aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        BOOL result = NO;
        [[info originalInvocation] setReturnValue:&result];
    }error:nil];
    NSArray *windowsArray = [UIApplication sharedApplication].windows;
    NSMutableArray *tokenArray = [[NSMutableArray alloc] initWithCapacity:windowsArray.count];
    for (UIWindow *window in windowsArray) {
        id<AspectToken> token = [window.rootViewController aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
            BOOL result = NO;
            [[info originalInvocation] setReturnValue:&result];
        }error:nil];
        if (token) {
            [tokenArray addObject:token];
        }
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:NO];
    if (aspectToken) {
        [aspectToken remove];
    }
    for (id<AspectToken> token in tokenArray) {
        [token remove];
    }
}

- (CGAffineTransform)transformForRotationAngle:(UIInterfaceOrientation)statusBarOri {
    if (statusBarOri == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (statusBarOri == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if (statusBarOri == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

#pragma mark -- TTSharePanelTransformMessage

- (void)message_sharePanelIfNeedTransform:(BOOL)isMovieFullScreen
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect windowFrame = [UIApplication sharedApplication].keyWindow.bounds;
    _backWindow.frame = windowFrame;
    
    if (isMovieFullScreen) {
        _backWindow.transform = [self transformForRotationAngle:orientation];
    } else {
        _backWindow.transform = CGAffineTransformIdentity;
    }
    _backWindow.frame = windowFrame;
    _backWindow.rootViewController.view.frame = _backWindow.bounds;
    
}

#pragma mark - Create UI components

- (void)createComponents {
    //Root view controller
    self.rootViewController = [[TTActivityPanelRootViewController alloc] init];
    UIInterfaceOrientation rightOrientation  = [[UIApplication sharedApplication] statusBarOrientation];
    
    //Back window
    self.backWindow = [[TTActivityPanelControllerWindow alloc] init];
    
    CGRect windowFrame = [UIApplication sharedApplication].keyWindow.bounds;
    self.originalKeyWindow = [UIApplication sharedApplication].keyWindow;
    if (windowFrame.size.width != [UIScreen mainScreen].bounds.size.width && windowFrame.size.height != [UIScreen mainScreen].bounds.size.width) {
        windowFrame = [UIApplication sharedApplication].delegate.window.bounds;
        self.originalKeyWindow = [UIApplication sharedApplication].delegate.window;
    }
    
    //主动询问movieView是否全屏，视情况旋转
    SAFECALL_MESSAGE(TTSharePanelTransformMessage, @selector(message_sharePanelIfNeedTransformWithBlock:), message_sharePanelIfNeedTransformWithBlock:self.fullScreenTransformHandlerBlock);
    
    self.backWindow.rootViewController = self.rootViewController;
    self.backWindow.windowLevel = UIWindowLevelNormal;
    self.backWindow.backgroundColor = [UIColor clearColor];
    [self.backWindow makeKeyAndVisible];
    self.backWindow.frame = windowFrame;
    self.backWindow.rootViewController.view.frame = self.backWindow.bounds;
    
    //旋转后，刷新原来的statusbar的方向
    if ([TTDeviceHelper OSVersionNumber] < 10) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshStatusBarOrientation:rightOrientation];
        });
    } else {
        [self refreshStatusBarOrientation:rightOrientation];
    }
    self.backWindow.hidden = YES;
    //Mask view
    self.maskView = [[SSThemedView alloc] initWithFrame:self.backWindow.bounds];
    self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.maskView.backgroundColorThemeKey = kColorBackground9;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(cancelButtonAction:)];
    [self.maskView addGestureRecognizer:tap];
    [self.rootViewController.view addSubview:self.maskView];
    
    //Back view
    CGFloat bottomSafeAreaInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    CGFloat backViewHeight = kTTActivityPanelItemTopPadding + kTTActivityPanelSingleRowHeight*self.items.count + kTTActivityPanelCancelButtonHeight + bottomSafeAreaInset;
    self.backView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.maskView.height-backViewHeight, self.maskView.width, backViewHeight)];
    self.backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.backView.backgroundColorThemeKey = kColorBackground18;
    [self.maskView addSubview:self.backView];
    
    
    //Create scroll views
    [self.items enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray * itemViews = [NSMutableArray array];
        //Scroll view
        SSThemedScrollView *scrollView = [self createScrollViewWithSection:idx];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.contentSize = CGSizeMake(_itemWidth*[self.items[idx] count], kTTActivityPanelSingleRowHeight);
        if (self.items.count != 1 || self.items.firstObject.count >= 4) {
            CGFloat hInset = kTTActivityPanelRowHorizontalEdgeInset;
            BOOL landscapeMode = _backWindow.bounds.size.width > _backWindow.bounds.size.height;
            if ([TTDeviceHelper isIPhoneXDevice] && landscapeMode){
                hInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.left;
            }
            scrollView.contentInset = UIEdgeInsetsMake(0,
                                                       hInset,
                                                       0,
                                                       hInset);
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.x = -kTTActivityPanelRowHorizontalEdgeInset;
            scrollView.contentOffset = contentOffset;
        }
        scrollView.top = kTTActivityPanelSingleRowHeight * idx + kTTActivityPanelItemTopPadding;
        scrollView.width = self.backView.width;
        scrollView.height = kTTActivityPanelSingleRowHeight;
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.scrollViews addObject:scrollView];
        [self.backView addSubview:scrollView];
        
        //Current scroll view's item views
        [self.items[idx] enumerateObjectsUsingBlock:^(id  _Nonnull jobj, NSUInteger jidx, BOOL * _Nonnull jstop) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:jidx inSection:idx];
            TTActivityPanelThemedButton *itemView = [self itemViewWithIndex:indexPath
                                                                       item:self.items[idx][jidx]];
            [itemViews addObject:itemView];
            [scrollView addSubview:itemView];
        }];
        [self.itemViews addObject:itemViews];
        
        //Separate line view
        SSThemedView *separateLineView = [self createSeparateLineViewWithSection:idx];
        separateLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        BOOL isLastSection = ((self.items.count - 1) == idx);
        if (isLastSection) {
            separateLineView.left = 0;
            separateLineView.width = self.backView.width;
        }else {
            separateLineView.left = kTTActivityPanelRowSeparateLineHorizontalPadding;
            separateLineView.width = self.backView.width - kTTActivityPanelRowSeparateLineHorizontalPadding*2;
        }
        separateLineView.top = scrollView.bottom - [TTDeviceHelper ssOnePixel];
        separateLineView.height = [TTDeviceHelper ssOnePixel];
        [self.backView addSubview:separateLineView];
    }];
    //Cancel button
    self.cancelButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, self.backView.height - kTTActivityPanelCancelButtonHeight - bottomSafeAreaInset, self.backView.width, kTTActivityPanelCancelButtonHeight)];
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    self.cancelButton.titleColorThemeKey = kColorText1;
    self.cancelButton.backgroundColors = @[[UIColor colorWithHexString:@"0xf8f8f8"], [UIColor colorWithHexString:@"0x303030"]];
    self.cancelButton.highlightedBackgroundColors = @[[UIColor colorWithHexString:@"0xe8e8e8"], [UIColor colorWithHexString:@"0x252525"]];
    [self.cancelButton setTitle:self.cancelTitle
                       forState:UIControlStateNormal];
    [self.cancelButton addTarget:self
                          action:@selector(cancelButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.cancelButton];
    
    self.bottomSafeAreaView =  [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.backView.height - bottomSafeAreaInset, self.backView.width, bottomSafeAreaInset)];
    self.bottomSafeAreaView.backgroundColors = @[[UIColor colorWithHexString:@"0xf8f8f8"], [UIColor colorWithHexString:@"0x303030"]];
    [self.backView addSubview:self.bottomSafeAreaView];
#warning 王霖 下面的待验证
    //    if ([TTDeviceHelper OSVersionNumber] < 8.f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
    //        CGFloat temp = screenWidth;
    //        screenWidth = screenHeight;
    //        screenHeight = temp;
    //    }
}

- (SSThemedScrollView *)createScrollViewWithSection:(NSUInteger)section {
    SSThemedScrollView *scrollView = [[SSThemedScrollView alloc] init];
    scrollView.tag = section;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    return scrollView;
}

- (SSThemedView *)createSeparateLineViewWithSection:(NSUInteger)section {
    SSThemedView *separateLine = [[SSThemedView alloc] init];
    separateLine.backgroundColorThemeKey = kColorLine10;
    return separateLine;
}

- (TTActivityPanelThemedButton *)itemViewWithIndex:(NSIndexPath *)indexPath item:(id<TTActivityProtocol>)item {
    TTActivityPanelThemedButton *view = nil;
    CGRect frame;
    CGFloat amount = [(NSArray *)self.items[0] count];
    if (self.items.count == 1 && amount < 4) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        CGFloat windowWidth = window.size.width;
        CGFloat internalWidth = windowWidth * 0.0625;
        CGFloat leftPading = (windowWidth-kTTActivityPanelItemWidth*amount-internalWidth*(amount-1))/2;
        frame = CGRectMake(leftPading+indexPath.row*(internalWidth+kTTActivityPanelItemWidth), 0, kTTActivityPanelItemWidth, kTTActivityPanelSingleRowHeight);
        view = [[TTActivityPanelThemedButton alloc] initWithFrame:frame
                                                             item:item
                                                    itemIndexPath:indexPath];
    }else {
        frame = CGRectMake(indexPath.row*_itemWidth, 0, _itemWidth, kTTActivityPanelSingleRowHeight);
        if ([TTDeviceHelper isPadDevice]) {
            frame.origin.x += [TTUIResponderHelper paddingForViewWidth:0];
        }
        view = [[TTActivityPanelThemedButton alloc] initWithFrame:frame
                                                             item:item
                                                    itemIndexPath:indexPath];
    }
    id <TTActivityContentItemProtocol> contentItem = [item contentItem];
    if ([contentItem conformsToProtocol:@protocol(TTActivityContentItemSelectedDigProtocol)]) {
        [view addTarget:self action:@selector(selectedDigIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        id<TTActivityContentItemSelectedDigProtocol> selectedItem = (id<TTActivityContentItemSelectedDigProtocol>)item.contentItem;
        view.selected = selectedItem.selected;
    }else if ([contentItem conformsToProtocol:@protocol(TTActivityContentItemSelectedProtocol)]) {
        [view addTarget:self action:@selector(selectedIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        id<TTActivityContentItemSelectedProtocol> selectedItem = (id<TTActivityContentItemSelectedProtocol>)item.contentItem;
        view.selected = selectedItem.selected;
    }else {
        [view addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return view;
}

#pragma mark -- Item action

- (void)selectedDigIconButtonAction:(TTActivityPanelThemedButton *)sender {
    id<TTActivityProtocol> activity = self.items[sender.itemIndexPath.section][sender.itemIndexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
        [self.delegate activityPanel:self clickedWith:activity];
    }
    [activity performActivityWithCompletion:^(id<TTActivityProtocol> activity, NSError *error, NSString *desc) {
        
        if ([self.delegate respondsToSelector:@selector(activityPanel:completedWith:error:desc:)]) {
            [self.delegate activityPanel:self completedWith:activity error:error desc:desc];
        }
    }];
}

- (void)selectedIconButtonAction:(TTActivityPanelThemedButton *)sender {
    sender.selected = !sender.selected;
    id<TTActivityProtocol> activity = self.items[sender.itemIndexPath.section][sender.itemIndexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
        [self.delegate activityPanel:self clickedWith:activity];
    }
    [activity performActivityWithCompletion:^(id<TTActivityProtocol> activity, NSError *error, NSString *desc) {
        TTActivityPanelControllerItemActionType itemActionType = TTActivityPanelControllerItemActionTypeDismiss;
        if ([activity conformsToProtocol:@protocol(TTActivityPanelActivityProtocol)]
            && [activity respondsToSelector:@selector(itemActionType)]) {
            itemActionType = [(id<TTActivityPanelActivityProtocol>)activity itemActionType];
        }
        switch (itemActionType) {
            case TTActivityPanelControllerItemActionTypeDismiss:
                [self hide];
                break;
            default:
                break;
        }
        if ([self.delegate respondsToSelector:@selector(activityPanel:completedWith:error:desc:)]) {
            [self.delegate activityPanel:self completedWith:activity error:error desc:desc];
        }
    }];
}

- (void)buttonClickAction:(TTActivityPanelThemedButton *)sender {
    id<TTActivityProtocol> activity = self.items[sender.itemIndexPath.section][sender.itemIndexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
        [self.delegate activityPanel:self clickedWith:activity];
    }
    [self cancelWithItem:activity];
}

- (void)cancelButtonAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
        [self.delegate activityPanel:self clickedWith:nil];
    }
    [self cancelWithItem:nil];
}

- (void)cancelWithItem:(id<TTActivityProtocol>)activity {
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:10
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backView.bottom = self.maskView.height + self.backView.height;
                         self.backWindow.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self.originalKeyWindow makeKeyAndVisible];
                         self.backWindow.hidden = YES;
                         self.backWindow.panel = nil;
                         
                         //提前到panel收起之前。
                         //                         if ([self.delegate respondsToSelector:@selector(activityPanel:clickedWith:)]) {
                         //                             [self.delegate activityPanel:self clickedWith:activity];
                         //                         }
                         
                         [activity performActivityWithCompletion:^(id<TTActivityProtocol> activity, NSError *error, NSString *desc) {
                             if ([self.delegate respondsToSelector:@selector(activityPanel:completedWith:error:desc:)]) {
                                 [self.delegate activityPanel:self completedWith:activity error:error desc:desc];
                             }
                         }];
                     }];
}

#pragma mark -- Public

- (void)show {
    self.backWindow.panel = self;
    
    CGFloat bottom = self.maskView.height;
    self.backView.bottom = bottom + self.backView.height;
    self.backWindow.alpha = 0.0f;
    self.backWindow.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backView.bottom = bottom;
                         self.backWindow.alpha = 1.0f;
                     } completion:nil];
    
    [self.itemViews enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(TTActivityPanelThemedButton * _Nonnull jobj, NSUInteger jidx, BOOL * _Nonnull jstop) {
            CGFloat top = jobj.top;
            jobj.top = 100.f;
            jobj.alpha = 0.f;
            
            NSTimeInterval delay = 0.1f;
            NSTimeInterval delayI = 0.1f;
            NSTimeInterval delayJ = 0.025f;
            
            [UIView animateWithDuration:0.5
                                  delay:delay + idx*delayI + jidx * delayJ
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:10
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 jobj.top = top;
                                 jobj.alpha = 1.0f;
                             }
                             completion:nil];
        }];
    }];
}

- (void)hide {
    [self cancelWithItem:nil];
}

@end

