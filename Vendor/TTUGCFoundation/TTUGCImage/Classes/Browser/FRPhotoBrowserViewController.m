//
//  FRPhotoBrowserViewController.m
//  Article
//
//  Created by 王霖 on 17/1/18.
//
//

#import "FRPhotoBrowserViewController.h"
#import "FRPhotoBrowserCell.h"
#import "UIColor+TTThemeExtension.h"
#import "FRPhotoBrowserModel.h"
#import "TTImagePreviewAnimateManager.h"
#import "NetworkUtilities.h"
#import "TTInteractExitHelper.h"
#import "UIViewAdditions.h"
#import "TTTrackerWrapper.h"
#import "TTUIResponderHelper.h"
#import "Masonry.h"
#import "TTAlphaThemedButton.h"
#import "UIImage+TTThemeExtension.h"
#import "SSMotionRender.h"
#import <TTKitchen.h>
#import "TTDeviceHelper.h"
#import "UIViewController+NavigationBarStyle.h"
//#import <BDMobileRuntime/BDContext.h>
//#import <TTRegistry/TTRegistryDefines.h>
//#import <TTServiceProtocols/TTUGCDiggActionIconHelperProtocol.h>

static NSString * const kPhotoBrowserCellIdentifier = @"kPhotoBrowserCellIdentifier";

static NSString * const kShowMaskViewAnimationKey = @"kShowMaskViewAnimationKey";
static NSString * const kHideMaskViewAnimationKey = @"kHideMaskViewAnimationKey";
static NSString * const kShowBottomBarAnimationKey = @"kShowBottomBarAnimationKey";
static NSString * const kHideBottomBarAnimationKey = @"kHideBottomBarAnimationKey";
static NSString * const kShowTopBarAnimationKey = @"kShowTopBarAnimationKey";
static NSString * const kHideTopBarAnimationKey = @"kHideTopBarAnimationKey";
static NSString * const kShowBottomCoverAnimationKey = @"kShowBottomCoverAnimationKey";
static NSString * const kHideBottomCoverAnimationKey = @"kHideBottomCoverAnimationKey";

static const CGFloat kTopToolBarHeight = 44.f;
static const CGFloat kBottomToolBarHeight = 38.f;
static const CGFloat kComplexBottomToolBarHeight = 44.f;
static const CGFloat kBottomToolBarItemHorizontalMargin = 5.f;
static const CGFloat kBottomToolBarItemMinWidth = 50.f;
static const CGFloat kBottomToolBarItemHeight = 28.f;
static const CGFloat kBottomToolBarItemTextSize = 14.f;
static const CGFloat kMoveDirectionStartOffset = 20.f;

typedef NS_ENUM(NSInteger, FRPhotoBrowserViewControllerMoveDirection) {
    FRPhotoBrowserViewControllerMoveDirectionNone, //未知
    FRPhotoBrowserViewControllerMoveDirectionVerticalTop, //向上
    FRPhotoBrowserViewControllerMoveDirectionVerticalBottom //向下
};

@protocol _TTMultiDiggManagerProtocol<NSObject>

+ (BOOL)multiDiggAnimationEnable;

+ (void)registMulitDiggEmojiAnimationWithButton:(UIControl *)button
                             withTransformAngle:(CGFloat)angle
                                   contentInset:(NSValue *)inset
                                 buttonPosition:(NSInteger)position;

+ (BOOL)isMulitDiggEmojiAnimationAlreadyRegisteredWithButton:(UIControl *)button;

@end

@interface FRPhotoBrowserViewUGCParams ()
@property (nonatomic, copy) NSString *forwardTitle;
@property (nonatomic, copy) NSString *commentTitle;
@property (nonatomic, copy) NSString *diggTitle;
@property (nonatomic, assign) BOOL showSave;
@property (nonatomic, assign) BOOL hasDigged;
@property (nonatomic, weak) id<FRPhotoBrowserViewUGCDelegate> delegate;
@property (nonatomic, copy) NSString *diggIconKey;
@end

@implementation FRPhotoBrowserViewUGCParams
+ (FRPhotoBrowserViewUGCParams *)ugcParamsForwardTitle:(NSString *)sForward
                                          commentTitle:(NSString *)sComment
                                             diggTitle:(NSString *)sDigg
                                             hasDigged:(BOOL)digged
                                              showSave:(BOOL)showSave
                                                 delegate:(nonnull id<FRPhotoBrowserViewUGCDelegate>)delegate {
    FRPhotoBrowserViewUGCParams *params = [FRPhotoBrowserViewUGCParams new];
    params.forwardTitle = isEmptyString(sForward) || sForward.integerValue == 0 ? @"转发" : sForward;
    params.commentTitle = isEmptyString(sComment) || sComment.integerValue == 0 ? @"评论" : sComment;
    params.diggTitle = isEmptyString(sDigg) || sDigg.integerValue == 0 ? @"赞" : sDigg;
    params.showSave = showSave;
    params.hasDigged = digged;
    params.delegate = delegate;
    return params;
}

+ (FRPhotoBrowserViewUGCParams *)ugcParamsForwardTitle:(NSString *)sForward
                                          commentTitle:(NSString *)sComment
                                             diggTitle:(NSString *)sDigg
                                           diggIconKey:(NSString *)diggIconKey
                                             hasDigged:(BOOL)digged
                                              showSave:(BOOL)showSave
                                              delegate:(nonnull id<FRPhotoBrowserViewUGCDelegate>)delegate {
    FRPhotoBrowserViewUGCParams *params = [FRPhotoBrowserViewUGCParams new];
    params.forwardTitle = isEmptyString(sForward) || sForward.integerValue == 0 ? @"转发" : sForward;
    params.commentTitle = isEmptyString(sComment) || sComment.integerValue == 0 ? @"评论" : sComment;
    params.diggTitle = isEmptyString(sDigg) || sDigg.integerValue == 0 ? @"赞" : sDigg;
    params.showSave = showSave;
    params.hasDigged = digged;
    params.diggIconKey = diggIconKey;
    params.delegate = delegate;
    return params;
}

@end

@interface FRPhotoBrowserViewController () <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, FRPhotoBrowserCellDelegate, CAAnimationDelegate,TTPreviewPanBackDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSArray <FRPhotoBrowserModel *> * models;
@property (nonatomic, assign) NSUInteger startIndex;

@property (nonatomic, strong) UIView * maskView;
@property (nonatomic, strong) UICollectionView * photoBrowserCollectionView;

@property (nonatomic, strong) UIView * bottomToolBar;
@property (nonatomic, strong) UIView * topToolBar;
@property (nonatomic, strong) UIView * photoIndexIndicatorLabelContainerView;
@property (nonatomic, strong) UILabel * photoIndexIndicatorLabel;
@property (nonatomic, strong) UIButton * savePhotoButton;

@property (nonatomic, strong) TTAlphaThemedButton * moreButton;
@property (nonatomic, strong) TTAlphaThemedButton * forwardButton;
@property (nonatomic, strong) TTAlphaThemedButton * commentButton;
@property (nonatomic, strong) TTAlphaThemedButton * diggButton;
@property (nonatomic, strong) CAGradientLayer *bottomCoverLayer;

@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;
@property (nonatomic, assign) FRPhotoBrowserViewControllerMoveDirection direction;
@property (nonatomic, assign) BOOL reachDismissCondition;
@property (nonatomic, assign) BOOL reachDragCondition;

@property (nonatomic, assign) BOOL isFirstLayout;
@property (nonatomic, assign) BOOL hasShowStartIndex;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL innerSaveButton;

@property (nonatomic, assign) NSUInteger pageIndex;

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, weak) UIView *finishBackView;
@property (nonatomic, strong) TTImagePreviewAnimateManager *animateManager;
@property (nonatomic, assign) BOOL inList;
@property (nonatomic, assign, readonly) BOOL isComplexToolbar;
@property (nonatomic, strong) FRPhotoBrowserViewUGCParams *ugcParams;
@property (nonatomic, weak) id<FRPhotoBrowserViewUGCDelegate> delegate;
@property (nonatomic, assign) BOOL handlingDetailComment;

@property (nonatomic, copy) NSString *diggDescriptionTitle;

@end

@implementation FRPhotoBrowserViewController

#pragma mark - Life circle

- (instancetype)initWithModels:(NSArray<FRPhotoBrowserModel *> *)models startIndex:(NSUInteger)startIndex{
    return [self initWithModels:models startIndex:startIndex targetView:nil];
}

- (instancetype)initWithModels:(NSArray <FRPhotoBrowserModel *> *)models startIndex:(NSUInteger)startIndex targetView:(nullable UIView *)targetView {
    return [self initWithModels:models startIndex:startIndex targetView:targetView ugcParams:nil];
}

- (instancetype)initWithModels:(NSArray<FRPhotoBrowserModel *> *)models startIndex:(NSUInteger)startIndex targetView:(UIView *)targetView ugcParams:(FRPhotoBrowserViewUGCParams *)uParams {
    self = [super init];
    if (self) {
        self.models = models;
        if (startIndex >= models.count) {
            startIndex = 0;
        }
        self.startIndex = startIndex;
        self.pageIndex = startIndex;
        self.ugcParams = uParams;
        self.innerSaveButton = NO;
        self.delegate = uParams.delegate;
        _targetView = targetView;
        [self frameTransform];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSavePictureNotification:) name:kFRPhotoBrowserSavePictureNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveQRCodeNotification:) name:kFRPhotoBrowserQrcodeNotification object:nil];
    }
    return self;
}

- (void)updatePlaceholderImage:(UIImage *)placeholderImage atIndex:(NSUInteger)index {
    if (index < [self.models count]) {
        FRPhotoBrowserModel *model = [self.models objectAtIndex:index];
        model.placeholderImage = placeholderImage;
    }
}

- (void)updateOriginFrame:(NSValue *)originalFrame atIndex:(NSUInteger)index {
    if (index < [self.models count]) {
        FRPhotoBrowserModel *model = [self.models objectAtIndex:index];
        model.originalFrame = originalFrame;
        UIView *targetView = [self ttPreviewPanBackGetBackMaskView];
        CGRect origionFrame = model.originalFrame.CGRectValue;
        if (!CGRectEqualToRect(origionFrame, CGRectZero)){
            CGRect animateFrame = [targetView convertRect:origionFrame fromView:nil];
            model.animateFrame = [NSValue valueWithCGRect:animateFrame];
        }
    }
}

- (void)dealloc {
    self.indexUpdatedBlock = nil;
    self.willDismissBlock = nil;
    //加个保护，避免在手势滑动返回异常的时候（用户胡乱滑动打断动画等原因），status bar显隐状态没有恢复
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden
                                            withAnimation:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstLayout = YES;
    [self createComponents];
    self.ttStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.view.accessibilityViewIsModal = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.isFirstLayout) {
        self.isFirstLayout = NO;
        [self.photoBrowserCollectionView setContentOffset:CGPointMake(self.startIndex*self.view.width, 0)];
        [self updatePhotoIndexIndicator];
        WeakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            FRPhotoBrowserCell * cell = (FRPhotoBrowserCell *)[wself.photoBrowserCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:wself.startIndex inSection:0]];
            [cell show];
            
            CABasicAnimation * maskViewAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            maskViewAnimation.removedOnCompletion = NO;
            maskViewAnimation.delegate = wself;
            maskViewAnimation.duration = kAnimationDuration;
            maskViewAnimation.timingFunction = [FRPhotoBrowserCell getAnimationTimingFunction];
            maskViewAnimation.fillMode = kCAFillModeForwards;
            maskViewAnimation.fromValue = [NSNumber numberWithDouble:0];
            maskViewAnimation.toValue = [NSNumber numberWithDouble:1];
            [wself.maskView.layer addAnimation:maskViewAnimation forKey:kShowMaskViewAnimationKey];
            
            CABasicAnimation * bottomToolBarAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            bottomToolBarAnimation.removedOnCompletion = NO;
            bottomToolBarAnimation.delegate = wself;
            bottomToolBarAnimation.duration = kAnimationDuration;
            bottomToolBarAnimation.timingFunction = [FRPhotoBrowserCell getAnimationTimingFunction];
            bottomToolBarAnimation.fillMode = kCAFillModeForwards;
            bottomToolBarAnimation.fromValue = [NSNumber numberWithDouble:0];
            bottomToolBarAnimation.toValue = [NSNumber numberWithDouble:1];
            [wself.bottomToolBar.layer addAnimation:bottomToolBarAnimation forKey:kShowBottomBarAnimationKey];
            
            if (wself.isComplexToolbar) {
                [wself.topToolBar.layer addAnimation:bottomToolBarAnimation forKey:kShowTopBarAnimationKey];
                [wself.bottomCoverLayer addAnimation:bottomToolBarAnimation forKey:kShowBottomCoverAnimationKey];
            }
        });
    }
    self.maskView.frame = self.view.bounds;
    self.photoBrowserCollectionView.frame = self.view.bounds;
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    CGFloat toolbarHeight = self.isComplexToolbar ? kComplexBottomToolBarHeight :  kBottomToolBarHeight;
    self.bottomToolBar.frame = CGRectMake(0, self.view.height - toolbarHeight - bottomInset, self.view.width, toolbarHeight);
    if (self.isComplexToolbar) {
        CGFloat indexContainerHeight = self.topToolBar.height - 8 - kBottomToolBarItemHeight;
        if ([TTDeviceHelper isIPhoneXSeries]){
            indexContainerHeight -= 11;
        }
        self.photoIndexIndicatorLabelContainerView.frame = CGRectMake(0, indexContainerHeight, kBottomToolBarItemMinWidth + 6, kBottomToolBarItemHeight);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createComponents {
    self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.layer.opacity = 0;
    [self.view addSubview:self.maskView];
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = self.view.size;
    flowLayout.minimumLineSpacing = 0;
    
    self.photoBrowserCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.photoBrowserCollectionView.pagingEnabled = YES;
    self.photoBrowserCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.photoBrowserCollectionView.showsHorizontalScrollIndicator = NO;
    self.photoBrowserCollectionView.showsVerticalScrollIndicator = NO;
    self.photoBrowserCollectionView.scrollsToTop = NO;
    self.photoBrowserCollectionView.backgroundColor = [UIColor clearColor];
    self.photoBrowserCollectionView.delegate = self;
    self.photoBrowserCollectionView.dataSource = self;
    self.photoBrowserCollectionView.alwaysBounceHorizontal = YES;
    [self.photoBrowserCollectionView registerClass:[FRPhotoBrowserCell class] forCellWithReuseIdentifier:kPhotoBrowserCellIdentifier];
    [self.view addSubview:self.photoBrowserCollectionView];
    CGFloat topInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top;
    CGFloat topToolBarHeight = kTopToolBarHeight;
    if ([TTDeviceHelper isIPhoneXSeries]){
        topToolBarHeight += topInset;
    }
    self.topToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, topToolBarHeight)];
    self.topToolBar.layer.opacity = 0;
    // 添加渐变图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.topToolBar.bounds;
    gradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0.6f].CGColor,
                             (id)[[UIColor blackColor] colorWithAlphaComponent:0.0f].CGColor];
    [self.topToolBar.layer addSublayer:gradientLayer];
    [self.view addSubview:self.topToolBar];

    self.bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - kBottomToolBarHeight, self.view.width, kBottomToolBarHeight)];
    self.bottomToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.bottomToolBar.layer.opacity = 0;
    [self.view addSubview:self.bottomToolBar];
    
    self.bottomCoverLayer = [CAGradientLayer layer];
    self.bottomCoverLayer.opacity = 0;
    self.bottomCoverLayer.frame = CGRectMake(0, self.view.height - 270, self.view.width, 270);
    self.bottomCoverLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0.0f].CGColor,
                                     (id)[[UIColor blackColor] colorWithAlphaComponent:0.3f].CGColor];
    [self.view.layer insertSublayer:self.bottomCoverLayer below:self.bottomToolBar.layer];
    
    if (!self.isComplexToolbar) {
        self.photoIndexIndicatorLabelContainerView = [[UIView alloc] initWithFrame:CGRectMake(kBottomToolBarItemHorizontalMargin, (kBottomToolBarHeight - kBottomToolBarItemHeight)/2, kBottomToolBarItemMinWidth, kBottomToolBarItemHeight)];
        self.photoIndexIndicatorLabelContainerView.layer.cornerRadius = 6.f;
        self.photoIndexIndicatorLabelContainerView.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground9];
        self.photoIndexIndicatorLabelContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.bottomToolBar addSubview:self.photoIndexIndicatorLabelContainerView];
        
        self.photoIndexIndicatorLabel = [[UILabel alloc] init];
        self.photoIndexIndicatorLabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)(self.pageIndex + 1),(unsigned long)self.models.count];
        [self.photoIndexIndicatorLabel sizeToFit];
        [self.photoIndexIndicatorLabel setTextColor:[UIColor tt_defaultColorForKey:kColorBackground4]];
        [self.photoIndexIndicatorLabel setFont:[UIFont systemFontOfSize:kBottomToolBarItemTextSize]];
        [self.photoIndexIndicatorLabelContainerView addSubview:self.photoIndexIndicatorLabel];
        self.photoIndexIndicatorLabel.center = CGPointMake(self.photoIndexIndicatorLabelContainerView.width/2, self.photoIndexIndicatorLabelContainerView.height/2);
        
        self.savePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bottomToolBar.width - kBottomToolBarItemHorizontalMargin - kBottomToolBarItemMinWidth, (kBottomToolBarHeight - kBottomToolBarItemHeight)/2, kBottomToolBarItemMinWidth, kBottomToolBarItemHeight)];
        [self.savePhotoButton addTarget:self
                                 action:@selector(savePhotoToAlbum)
                       forControlEvents:UIControlEventTouchUpInside];
        self.savePhotoButton.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground9];
        [self.savePhotoButton setTitle:@"保存" forState:UIControlStateNormal];
        [self.savePhotoButton setTitleColor:[UIColor tt_defaultColorForKey:kColorBackground4] forState:UIControlStateNormal];
        [self.savePhotoButton.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        self.savePhotoButton.layer.cornerRadius = 6.f;
        self.savePhotoButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.bottomToolBar addSubview:self.savePhotoButton];
    } else {
        CGFloat indexContainerHeight = self.topToolBar.height - 8 - kBottomToolBarItemHeight;
        if ([TTDeviceHelper isIPhoneXSeries]){
            indexContainerHeight -= 11;
        }
        self.photoIndexIndicatorLabelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, indexContainerHeight, kBottomToolBarItemMinWidth + 6, kBottomToolBarItemHeight)];
        self.photoIndexIndicatorLabelContainerView.layer.cornerRadius = 6.f;
        self.photoIndexIndicatorLabelContainerView.backgroundColor = [UIColor clearColor];
        self.photoIndexIndicatorLabelContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        self.photoIndexIndicatorLabel = [[UILabel alloc] init];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 2.0;
        shadow.shadowOffset = CGSizeMake(0.5, 0.2);
        shadow.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];;
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%lu",(long)(self.pageIndex + 1),(unsigned long)self.models.count] attributes:@{NSShadowAttributeName:shadow, NSFontAttributeName:[UIFont systemFontOfSize:kBottomToolBarItemTextSize], NSForegroundColorAttributeName:[UIColor tt_defaultColorForKey:kColorBackground4]}];
        self.photoIndexIndicatorLabel.attributedText = attributedTitle;
        [self.photoIndexIndicatorLabel sizeToFit];
        [self.photoIndexIndicatorLabelContainerView addSubview:self.photoIndexIndicatorLabel];
        self.photoIndexIndicatorLabel.center = CGPointMake(self.photoIndexIndicatorLabelContainerView.width/2, self.photoIndexIndicatorLabelContainerView.height/2);
        [self.topToolBar addSubview:self.photoIndexIndicatorLabelContainerView];
        
        self.bottomToolBar.height = 44;
        
        if (self.innerSaveButton) {
            self.moreButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(self.topToolBar.width - 37, 11 + topInset, 24, 24)];
            [self.moreButton addTarget:self
                                action:@selector(moreButtonAction:)
                      forControlEvents:UIControlEventTouchUpInside];
            self.moreButton.backgroundColor = [UIColor clearColor];
            [self.moreButton setTitleColor:[UIColor tt_defaultColorForKey:kColorBackground4] forState:UIControlStateNormal];
            [self.moreButton setImage:[UIImage imageNamed:@"picbrowser_more_white"] forState:UIControlStateNormal];
            self.moreButton.tintColorThemeKey = kColorText8;
            self.moreButton.tag = kFRPhotoUGCActionTag;
            [self.moreButton.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
            [self.topToolBar addSubview:self.moreButton];
        } else {
            CGFloat savePhotoButtonTop = 11;
            if ([TTDeviceHelper isIPhoneXSeries]){
                savePhotoButtonTop = topInset - 3;
            }
            self.savePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.topToolBar.width - kBottomToolBarItemMinWidth - 13, savePhotoButtonTop, kBottomToolBarItemMinWidth, kBottomToolBarItemHeight)];
            [self.savePhotoButton addTarget:self
                                     action:@selector(savePhotoToAlbum)
                           forControlEvents:UIControlEventTouchUpInside];
            self.savePhotoButton.backgroundColor = [UIColor clearColor];
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowBlurRadius = 2.0;
            shadow.shadowOffset = CGSizeMake(0.5, 0.2);
            shadow.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];;
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"保存" attributes:@{NSShadowAttributeName:shadow, NSFontAttributeName:[UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName:[UIColor tt_defaultColorForKey:kColorBackground4]}];
            [self.savePhotoButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
            self.savePhotoButton.layer.cornerRadius = 6.f;
            self.savePhotoButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            [self.topToolBar addSubview:self.savePhotoButton];
        }
       
        self.forwardButton = [[TTAlphaThemedButton alloc] init];
        [self.forwardButton addTarget:self
                               action:@selector(forwardAction:)
                    forControlEvents:UIControlEventTouchUpInside];
        self.forwardButton.backgroundColor = [UIColor clearColor];
        [self.forwardButton setTitleColor:[UIColor tt_defaultColorForKey:kColorBackground4] forState:UIControlStateNormal];
        [self.forwardButton setTitle:self.ugcParams.forwardTitle forState:UIControlStateNormal];
        [self.forwardButton setImage:[UIImage imageNamed:@"u13_share_feed"] forState:UIControlStateNormal];
        if (![self.ugcParams.forwardTitle isEqualToString:@"转发"]) {
            self.forwardButton.accessibilityLabel = [NSString stringWithFormat:@"转发%@", self.ugcParams.forwardTitle];
        }
        self.forwardButton.tintColorThemeKey = kColorText8;
        self.forwardButton.tag = kFRPhotoUGCActionTag;
        [self.forwardButton.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
        self.forwardButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [self.bottomToolBar addSubview:self.forwardButton];
        [self.forwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.height.equalTo(self.bottomToolBar);
            make.width.equalTo(@(self.bottomToolBar.width / 3));
        }];
        
        self.commentButton = [[TTAlphaThemedButton alloc] init];
        [self.commentButton addTarget:self
                               action:@selector(commentAction:)
                     forControlEvents:UIControlEventTouchUpInside];
        self.commentButton.backgroundColor = [UIColor clearColor];
        self.commentButton.tag = kFRPhotoUGCActionTag;
        [self.commentButton setTitleColor:[UIColor tt_defaultColorForKey:kColorBackground4] forState:UIControlStateNormal];
        [self.commentButton setTitle:self.ugcParams.commentTitle forState:UIControlStateNormal];
        [self.commentButton setImage:[UIImage imageNamed:@"u13_comment_feed"] forState:UIControlStateNormal];
        if (![self.ugcParams.commentTitle isEqualToString:@"评论"]) {
            self.commentButton.accessibilityLabel = [NSString stringWithFormat:@"评论%@", self.ugcParams.commentTitle];
        }
        self.commentButton.tintColorThemeKey = kColorText8;
        [self.commentButton.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
        self.commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [self.bottomToolBar addSubview:self.commentButton];
        [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(self.bottomToolBar);
            make.left.equalTo(self.forwardButton.mas_right);
            make.width.equalTo(@(self.bottomToolBar.width / 3));
        }];
        
        
        self.diggButton = [[TTAlphaThemedButton alloc] init];
        self.diggButton.backgroundColor = [UIColor clearColor];
        self.diggButton.tag = kFRPhotoUGCActionTag;
        [self.diggButton setTitleColor:[UIColor tt_defaultColorForKey:kColorBackground4] forState:UIControlStateNormal];
        [self.diggButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText4] forState:UIControlStateSelected];
        [self.diggButton.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
        [self.diggButton setTitle:self.ugcParams.diggTitle forState:UIControlStateNormal];
        if (![self.ugcParams.diggTitle isEqualToString:@"赞"]) {
            self.diggButton.accessibilityLabel = [NSString stringWithFormat:@"赞%@", self.ugcParams.diggTitle];
        }
        self.diggButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        
        [self.bottomToolBar addSubview:self.diggButton];
        
        [self.diggButton setSelectedImageName:@"feed_like_press"];
        [self.diggButton setImageName:@"u13_like_feed"];
        [self registerMultiDiggAnimation];
        if (isEmptyString(self.ugcParams.diggIconKey)) {
            self.diggButton.tintColorThemeKey = kColorText8;
        } else {
            WeakSelf;
//            [[BDContextGet() findServiceByName:TTUGCDiggActionIconHelperServiceName] setDiggActionButton:self.diggButton useDynamicActionIconKey:self.ugcParams.diggIconKey selectTitleColorKey:kTTkUGCDiggActionTitleSelectedColorPhotoBrowserKey scale:TTUGCDiggActionIconScaleMiddle redrawRect:CGRectZero scaleIconToSize:CGSizeMake(24.f, 24.f) completionBlock:^(BOOL isSucceed){
//                StrongSelf;
//                [self.diggButton setImage:[[self.diggButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//                self.diggButton.tintColorThemeKey = kColorText8;
//            }];
//            
//            if ([self.ugcParams.diggTitle isEqualToString:@"赞"]) {
//                WeakSelf;
//                [[BDContextGet() findServiceByName:TTUGCDiggActionIconHelperServiceName] asyncGetDiggDescriptionTitleWithActionIconKey:self.ugcParams.diggIconKey completionBlock:^(NSString * _Nullable diggDescriptionTitle) {
//                    StrongSelf;
//                    [self.diggButton setTitle:diggDescriptionTitle forState:UIControlStateNormal];
//                    self.diggDescriptionTitle = diggDescriptionTitle;
//                }];
//            }
        }
        
        
        // frame 必须再multiDigg之后设置，否则动效视图大小为0
        self.diggButton.frame = CGRectMake(2 * self.bottomToolBar.width / 3, 0, self.bottomToolBar.width / 3, self.bottomToolBar.height);
        self.diggButton.selected = self.ugcParams.hasDigged;
        [self.diggButton addTarget:self
                            action:@selector(diggAction:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    if ([TTImagePreviewAnimateManager interativeExitEnable]){
        self.animateManager.panDelegate = self;
        [self.animateManager registeredPanBackWithGestureView:self.view];
    }
}

- (void)registerMultiDiggAnimation {
    Class multiDiggManager = NSClassFromString(@"TTMultiDiggManager");
    if ([multiDiggManager respondsToSelector:@selector(multiDiggAnimationEnable)] && [multiDiggManager multiDiggAnimationEnable] && ![multiDiggManager isMulitDiggEmojiAnimationAlreadyRegisteredWithButton:self.diggButton]) {
        if ([multiDiggManager respondsToSelector:@selector(registMulitDiggEmojiAnimationWithButton:withTransformAngle:contentInset:buttonPosition:)]) {
            [multiDiggManager registMulitDiggEmojiAnimationWithButton:self.diggButton
                                                   withTransformAngle:M_PI / 4.5
                                                         contentInset:nil
                                                       buttonPosition:3];
        }
    }
}

- (void)updatePhotoIndexIndicator {
    CGFloat pageWidth = self.photoBrowserCollectionView.frame.size.width;
    float fractionalPage = (self.photoBrowserCollectionView.contentOffset.x + pageWidth / 2) / pageWidth;
    NSInteger page = floor(fractionalPage);
    
    if (self.pageIndex != page) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 2.0;
        shadow.shadowOffset = CGSizeMake(0.5, 0.2);
        shadow.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];;
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%lu",(long)(page + 1),(unsigned long)self.models.count] attributes:@{NSShadowAttributeName:shadow, NSFontAttributeName:[UIFont systemFontOfSize:kBottomToolBarItemTextSize], NSForegroundColorAttributeName:[UIColor tt_defaultColorForKey:kColorBackground4]}];
        self.photoIndexIndicatorLabel.attributedText = attributedTitle;
        [self.photoIndexIndicatorLabel sizeToFit];
        self.photoIndexIndicatorLabel.center = CGPointMake(self.photoIndexIndicatorLabelContainerView.width/2, self.photoIndexIndicatorLabelContainerView.height/2);
        
        if (self.indexUpdatedBlock) {
            self.indexUpdatedBlock(self.pageIndex, page);
        }
    }
    
    self.pageIndex = page;
}

- (NSDictionary *)_photoBrowserTrackDict {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserTrackDict)]) {
        return [self.delegate photoBrowserTrackDict];
    }
    return nil;
}

#pragma Setter & Getter

- (UIView *)finishBackView{
    if (_finishBackView == nil){
        _finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    }
    return _finishBackView;
}

- (TTImagePreviewAnimateManager *)animateManager{
    if (_animateManager == nil){
        _animateManager = [[TTImagePreviewAnimateManager alloc] init];
    }
    return _animateManager;
}

- (BOOL)isComplexToolbar {
    return self.ugcParams != nil;
}

#pragma mark - Actions

- (void)receiveSavePictureNotification:(NSNotification *)notification {
    NSMutableDictionary *mDict = [self _photoBrowserTrackDict].mutableCopy;
    [mDict setValue:@"image_top_bar" forKey:@"section"];
    [TTTrackerWrapper eventV3:@"save_image" params:mDict.copy];
    [self savePhotoToAlbum];
}

- (void)receiveQRCodeNotification:(NSNotification *)notification {
    NSMutableDictionary *mDict = [self _photoBrowserTrackDict].mutableCopy;
    [mDict setValue:@"image_top_bar" forKey:@"section"];
    [TTTrackerWrapper eventV3:@"qr_scan" params:mDict.copy];
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    [cell handleQrCodeParse];
}

- (void)savePhotoToAlbum {
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    [cell savePhoto];
}

- (void)moreButtonAction:(id)sender {
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    [self moreButtonAction:sender qrcode:cell.qrURL != nil];
}

- (void)moreButtonAction:(id)sender qrcode:(BOOL)qrcode {
    if ([self.delegate respondsToSelector:@selector(photoBrowserMoreAction:qrcode:)]) {
        NSMutableDictionary *mDict = [self _photoBrowserTrackDict].mutableCopy;
        [mDict setValue:@"image_top_bar" forKey:@"section"];
        [TTTrackerWrapper eventV3:@"click_more" params:mDict.copy];
        [self.delegate photoBrowserMoreAction:sender qrcode:qrcode];
    }
}

- (void)forwardAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(photoBrowserForwardAction:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hidePhotoBrowserWithAnimation:NO];
        });
        NSMutableDictionary *mDict = [self _photoBrowserTrackDict].mutableCopy;
        [mDict setValue:@"weitoutiao" forKey:@"platform"];
        [TTTrackerWrapper eventV3:@"rt_share_to_platform" params:mDict];
        [self.delegate photoBrowserForwardAction:sender];
    }
}

- (void)commentAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(photoBrowserCommentAction:)]) {
        self.handlingDetailComment = YES;
        [TTTrackerWrapper eventV3:@"cell_comment" params:[self _photoBrowserTrackDict]];
        [self tapPhotoBrowserCell:[self.photoBrowserCollectionView visibleCells].firstObject];
    }
}

- (void)diggAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(photoBrowserDiggAction:)]) {
        [TTTrackerWrapper eventV3:@"rt_like" params:[self _photoBrowserTrackDict]];
        Class multiDiggManager = NSClassFromString(@"TTMultiDiggManager");
        if ([multiDiggManager respondsToSelector:@selector(multiDiggAnimationEnable)] && [multiDiggManager multiDiggAnimationEnable]) {
            [self resetDiggButtonTitle:sender];
            [self.delegate photoBrowserDiggAction:sender];
        } else {
            if (!sender.selected){
                UIImage *motionImage = [UIImage themedImageNamed:@"add_all_dynamic"];
                CGPoint motionPoint = CGPointMake(4.f, -9.f);
                [SSMotionRender motionInView:sender.imageView
                                      byType:SSMotionTypeZoomInAndDisappear
                                       image:motionImage
                                 offsetPoint:motionPoint];
                sender.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                sender.imageView.contentMode = UIViewContentModeCenter;
                [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    sender.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                    sender.alpha = 0;
                } completion:^(BOOL finished) {
                    sender.alpha = 0;
                    [self resetDiggButtonTitle:sender];
                    [self.delegate photoBrowserDiggAction:sender];
                    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                        sender.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                        sender.alpha = 1;
                    } completion:nil];
                }];
            } else {
                [self resetDiggButtonTitle:sender];
                [self.delegate photoBrowserDiggAction:sender];
            }
        }
    }
}

- (void)resetDiggButtonTitle:(UIButton *)sender {
    NSString *originText = sender.titleLabel.text;
    if (!sender.selected) {
        if (!originText.integerValue) {
            [sender setTitle:@"1" forState:UIControlStateNormal];
        } else if (![originText containsString:@"万"] && ![originText containsString:@"亿"]) {
            [sender setTitle:[NSString stringWithFormat:@"%ld", originText.integerValue + 1] forState:UIControlStateNormal];
        }
    } else {
        if (originText.integerValue && (![originText containsString:@"万"] && ![originText containsString:@"亿"])) {
            NSString *normalDescriptionTitle = isEmptyString(self.diggDescriptionTitle) ? @"赞" : self.diggDescriptionTitle;
            [sender setTitle:originText.integerValue - 1 > 0 ? [NSString stringWithFormat:@"%ld", originText.integerValue - 1] : normalDescriptionTitle forState:UIControlStateNormal];
        }
    }
    if ([sender.currentTitle isEqualToString:@"赞"]) {
        self.accessibilityLabel = @"赞";
    } else {
        self.accessibilityLabel = [NSString stringWithFormat:@"赞%@", sender.currentTitle];
    }
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view.superview];
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if ([TTImagePreviewAnimateManager interativeExitEnable]){
                cell.hidden = YES;
            }
            break;
        case UIGestureRecognizerStateChanged: {
            [self refreshPhotoBrowserViewFrame:translation velocity:velocity];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self animatePhotoViewWhenGestureEnd];
            break;
        }
        default:
            break;
    }
}

- (void)refreshPhotoBrowserViewFrame:(CGPoint)translation velocity:(CGPoint)velocity {
    if (self.direction == FRPhotoBrowserViewControllerMoveDirectionNone) {
        //刚开始识别方向
        if (translation.y > kMoveDirectionStartOffset) {
            self.direction = FRPhotoBrowserViewControllerMoveDirectionVerticalBottom;
        }
        if (translation.y < -kMoveDirectionStartOffset) {
            self.direction = FRPhotoBrowserViewControllerMoveDirectionVerticalTop;
        }
    }else {
        //重新识别方向
        FRPhotoBrowserViewControllerMoveDirection currentDirection = FRPhotoBrowserViewControllerMoveDirectionNone;
        if (translation.y > kMoveDirectionStartOffset) {
            currentDirection = FRPhotoBrowserViewControllerMoveDirectionVerticalBottom;
        } else if (translation.y < -kMoveDirectionStartOffset) {
            currentDirection = FRPhotoBrowserViewControllerMoveDirectionVerticalTop;
        } else {
            currentDirection = FRPhotoBrowserViewControllerMoveDirectionNone;
        }
        
        if (currentDirection == FRPhotoBrowserViewControllerMoveDirectionNone) {
            self.direction = currentDirection;
            return;//忽略其他手势
        }
        
        BOOL verticle = (self.direction == FRPhotoBrowserViewControllerMoveDirectionVerticalBottom || self.direction == FRPhotoBrowserViewControllerMoveDirectionVerticalTop);
        CGFloat y = 0;
        if (self.direction == FRPhotoBrowserViewControllerMoveDirectionVerticalTop) {
            y = translation.y + kMoveDirectionStartOffset;
        } else if (self.direction == FRPhotoBrowserViewControllerMoveDirectionVerticalBottom){
            y = translation.y - kMoveDirectionStartOffset;
        }
        
        CGFloat yFraction = fabs(translation.y / CGRectGetHeight(self.photoBrowserCollectionView.frame));
        yFraction = fminf(fmaxf(yFraction, 0.0), 1.0);
        
        //距离判断+速度判断
        if (verticle) {
            if (yFraction > 0.2) {
                self.reachDismissCondition = YES;
            } else {
                self.reachDismissCondition  = NO;
            }
            
            if (velocity.y > 1500) {
                self.reachDismissCondition = YES;
            }
        }
        
        CGRect frame = CGRectMake(0, y, self.photoBrowserCollectionView.width, self.photoBrowserCollectionView.height);
        self.photoBrowserCollectionView.frame = frame;
        
        //下拉动画
        if (verticle) {
            self.reachDragCondition = YES;
            [self addAnimatedViewToContainerView:yFraction];
        }
    }
}

- (void)animatePhotoViewWhenGestureEnd {
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    if (!self.reachDragCondition) {
        cell.hidden = NO;
        return; //未曾满足过一次识别手势，不触发动画
    } else {
        self.reachDragCondition = NO;
    }
    
    CGRect endRect = self.view.bounds;
    CGFloat opacity = 1;
    
    if (_reachDismissCondition) {
        if (self.direction == FRPhotoBrowserViewControllerMoveDirectionVerticalBottom) {
            endRect.origin.y += self.photoBrowserCollectionView.height;
        } else if (self.direction == FRPhotoBrowserViewControllerMoveDirectionVerticalTop) {
            endRect.origin.y -= self.photoBrowserCollectionView.height;
        }
        opacity = 0;
    }else{
        cell.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.photoBrowserCollectionView.frame = endRect;
        [self addAnimatedViewToContainerView: 1 - opacity];
    } completion:^(BOOL finished) {
        self.direction = FRPhotoBrowserViewControllerMoveDirectionNone;
        if (_reachDismissCondition) {
            [self hidePhotoBrowserWithAnimation:YES];
        } else {
            [self removeAnimatedViewToContainerView];
        }
    }];
}

- (void)addAnimatedViewToContainerView:(CGFloat)yFraction {
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden
                                            withAnimation:NO];
    self.maskView.alpha = (1 - yFraction * 2 / 3);
    [UIView animateWithDuration:0.15 animations:^{
        self.bottomToolBar.alpha = 0;
    }];
}

- (void)removeAnimatedViewToContainerView {
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:NO];
    
    self.view.frame = self.parentViewController.view.bounds;
    self.photoBrowserCollectionView.frame = self.view.bounds;
    self.photoBrowserCollectionView.alpha = 1;
    [UIView animateWithDuration:0.15 animations:^{
        self.maskView.alpha = 1;
        self.bottomToolBar.alpha = 1;
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatePhotoIndexIndicator];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FRPhotoBrowserCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoBrowserCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell refreshWithModel:[self.models objectAtIndex:indexPath.row]];
    if (self.hasShowStartIndex) {
        [cell showModel];
    }
    cell.isAccessibilityElement = YES;
    cell.accessibilityLabel = @"图片";
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.size;
}

#pragma mark - FRPhotoBrowserCellDelegate

- (void)showCompleteWithModel:(FRPhotoBrowserModel *)model {
    self.hasShowStartIndex = YES;
}

- (void)hideCompleteWithModel:(FRPhotoBrowserModel *)model {
    if ([self.targetView conformsToProtocol:@protocol(FRPhotoBrowserCellTargetViewDelegate)]
        && [self.targetView respondsToSelector:@selector(photoBrowserWillDisappear)]) {
        [(id)self.targetView photoBrowserWillDisappear];
    }
}

- (void)tapPhotoBrowserCell:(FRPhotoBrowserCell *)cell {
    if (self.willDismissBlock) {
        self.willDismissBlock(self.pageIndex);
    }
    
    //点击关闭图片浏览器，立马恢复status bar显隐状态
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden
                                            withAnimation:NO];
    
    [cell hide];
    CABasicAnimation * maskViewAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    maskViewAnimation.removedOnCompletion = NO;
    maskViewAnimation.delegate = self;
    maskViewAnimation.duration = kAnimationDuration;
    maskViewAnimation.timingFunction = [FRPhotoBrowserCell getAnimationTimingFunction];
    maskViewAnimation.fillMode = kCAFillModeForwards;
    maskViewAnimation.fromValue = [NSNumber numberWithDouble:1];
    maskViewAnimation.toValue = [NSNumber numberWithDouble:0];
    [self.maskView.layer addAnimation:maskViewAnimation forKey:kHideMaskViewAnimationKey];
    
    CABasicAnimation * bottomToolBarAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    bottomToolBarAnimation.removedOnCompletion = NO;
    bottomToolBarAnimation.delegate = self;
    bottomToolBarAnimation.duration = kAnimationDuration;
    bottomToolBarAnimation.timingFunction = [FRPhotoBrowserCell getAnimationTimingFunction];
    bottomToolBarAnimation.fillMode = kCAFillModeForwards;
    bottomToolBarAnimation.fromValue = [NSNumber numberWithDouble:1];
    bottomToolBarAnimation.toValue = [NSNumber numberWithDouble:0];
    [self.bottomToolBar.layer addAnimation:bottomToolBarAnimation forKey:kHideBottomBarAnimationKey];
    
    if (self.isComplexToolbar) {
        [self.topToolBar.layer addAnimation:bottomToolBarAnimation forKey:kHideTopBarAnimationKey];
        [self.bottomCoverLayer addAnimation:bottomToolBarAnimation forKey:kHideBottomCoverAnimationKey];
    }
}

- (void)longPressBrowserCell:(FRPhotoBrowserCell *)cell {
    if (self.innerSaveButton) {
        [self moreButtonAction:self.moreButton qrcode:cell.qrURL != nil];
    } else {
        WeakSelf;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"保存图片", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              StrongSelf;
                                                              [self savePhotoToAlbum];
                                                          }]];
        if (cell.qrURL != nil) {
            __weak FRPhotoBrowserCell *weakCell = cell;
            WeakSelf;
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"识别图中二维码", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  __strong typeof(weakCell) strongCell = weakCell;
                                                                  StrongSelf;
                                                                  NSMutableDictionary *mDict = [self _photoBrowserTrackDict].mutableCopy;
                                                                  [mDict setValue:@"list_image" forKey:@"section"];
                                                                  [TTTrackerWrapper eventV3:@"qr_scan" params:mDict.copy];
                                                                  [strongCell handleQrCodeParse];
                                                              }]];
        }
        alertController.popoverPresentationController.sourceView = cell;
        alertController.popoverPresentationController.sourceRect = cell.bounds;
        
        UIViewController *topVC = [TTUIResponderHelper topViewControllerFor:self];
        [topVC presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim == [self.maskView.layer animationForKey:kShowMaskViewAnimationKey]) {
        //图片浏览器展示动画结束，记录status bar显隐状态，并隐藏status bar
        self.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationFade];
        self.maskView.layer.opacity = 1;
        [self.maskView.layer removeAnimationForKey:kShowMaskViewAnimationKey];
        self.bottomToolBar.layer.opacity = 1;
        [self.bottomToolBar.layer removeAnimationForKey:kShowBottomBarAnimationKey];
        
        if (self.isComplexToolbar) {
            self.topToolBar.layer.opacity = 1;
            [self.topToolBar.layer removeAnimationForKey:kShowTopBarAnimationKey];
            self.bottomCoverLayer.opacity = 1;
            [self.bottomCoverLayer removeAnimationForKey:kShowBottomCoverAnimationKey];
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }else if (anim == [self.maskView.layer animationForKey:kHideMaskViewAnimationKey]) {
        self.maskView.layer.opacity = 0;
        [self.maskView.layer removeAnimationForKey:kHideMaskViewAnimationKey];
        self.bottomToolBar.layer.opacity = 0;
        [self.bottomToolBar.layer removeAnimationForKey:kHideBottomBarAnimationKey];
        if (self.isComplexToolbar) {
            self.topToolBar.layer.opacity = 0;
            [self.topToolBar.layer removeAnimationForKey:kHideTopBarAnimationKey];
            self.bottomCoverLayer.opacity = 0;
            [self.bottomCoverLayer removeAnimationForKey:kHideBottomCoverAnimationKey];
        }
        [self hidePhotoBrowserWithAnimation:YES];
        if (self.handlingDetailComment && [self.delegate respondsToSelector:@selector(photoBrowserCommentAction:)]) {
            [self.delegate photoBrowserCommentAction:self.commentButton];
            self.handlingDetailComment = NO;
        }
    }
}

#pragma mark - Publics

static BOOL staticPhotoBrowserAtTop = NO;
+ (BOOL)photoBrowserAtTop
{
    return staticPhotoBrowserAtTop;
}

static FRPhotoBrowserViewController *currentController = nil;
+ (void)dismissPhotoBrowserAnimated:(BOOL)animated {
    if (currentController) {
        [currentController dismissAnimated:animated];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    if (animated) {
        [self tapPhotoBrowserCell:[self.photoBrowserCollectionView visibleCells].firstObject];
    } else {
        if (self.willDismissBlock) {
            self.willDismissBlock(self.pageIndex);
        }
        [self hidePhotoBrowserWithAnimation:NO];
    }
}

- (void)frameTransform{
    //转换一下坐标，解决偏移问题
    UIView *targetView = [self ttPreviewPanBackGetBackMaskView];
    if (targetView == nil){
        return;
    }
    for (FRPhotoBrowserModel *model in _models){
        CGRect origionFrame = CGRectZero;
        if (![model.originalFrame isKindOfClass:[NSNull class]]){
            origionFrame = model.originalFrame.CGRectValue;
        }
        CGRect animateFrame = origionFrame;
        if (!CGRectEqualToRect(origionFrame, CGRectZero)){
            animateFrame = [targetView convertRect:origionFrame fromView:nil];
        }
        model.animateFrame = [NSValue valueWithCGRect:animateFrame];
    }
}

- (void)showPhotoBrowserInViewController:(UIViewController *)viewController {
    //初始化
    staticPhotoBrowserAtTop = YES;
    currentController = self;
    [self finishBackView];
    if (nil == viewController) {
        if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
            viewController = [[UIApplication sharedApplication].delegate window].rootViewController;
        }
        if (!viewController) {
            viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        }
        while (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        }
    }
    
    [viewController addChildViewController:self];
    
    [self beginAppearanceTransition:YES animated:YES];
    [viewController.view addSubview:self.view];
    self.view.frame = self.parentViewController.view.bounds;
    [self endAppearanceTransition];
    
    [self didMoveToParentViewController:viewController];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.photoBrowserCollectionView.visibleCells.firstObject);
}

- (void)hidePhotoBrowserWithAnimation:(BOOL)animated {
    
    staticPhotoBrowserAtTop = NO;
    currentController = nil;
    [self beginAppearanceTransition:NO animated:animated];
    [self.view removeFromSuperview];
    [self endAppearanceTransition];
    
    [self willMoveToParentViewController:nil];
    [self removeFromParentViewController];
}

#pragma TTPreviewPanBackDelegate

- (UIView *)ttPreviewPanBackGetOriginView{
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    return cell.getImageView;
};

- (UIView *)ttPreviewPanBackGetBackMaskView{
    return _targetView ? _targetView : self.finishBackView;
};

- (UIImage *)ttPreviewPanBackImageForSwitch{
    if (self.models.count <= _pageIndex){
        return nil;
    }
    FRPhotoBrowserModel *model = [self.models objectAtIndex:_pageIndex];
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    if (cell.isGIF && self.models.count < 3 && TTNetworkWifiConnected()){
        //bad code
        //判断外部是否是可以播放的。
        //因为当前拿到的占位图是正常的图片，所以不能够作为switch来使用
        return nil;
    }
    return model.placeholderImage;
}

- (CGRect)ttPreviewPanBackTargetViewFrame{
    if (self.models.count <= _pageIndex){
        return CGRectZero;
    }
    FRPhotoBrowserModel *model = [self.models objectAtIndex:_pageIndex];
    return model.animateFrame.CGRectValue;
};

- (void)ttPreviewPanBackStateChange:(TTPreviewAnimateState)currentState scale:(float)scale{
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    switch (currentState) {
        case TTPreviewAnimateStateWillBegin:
            [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden
                                                    withAnimation:NO];
            cell.hidden = YES;
            self.bottomToolBar.alpha = 0;
            if (self.isComplexToolbar) {
                self.topToolBar.alpha = 0;
                self.bottomCoverLayer.opacity = 0;
            }
            break;
        case TTPreviewAnimateStateChange:
            //20倍的速率
            self.maskView.alpha =  MAX(0,(scale*14-13 - _animateManager.minScale)/(1 - _animateManager.minScale));
            break;
        case TTPreviewAnimateStateDidFinish:
            [self hidePhotoBrowserWithAnimation:YES];
            cell.hidden = NO;
            [cell resetImageViews];
            if ([self.targetView conformsToProtocol:@protocol(FRPhotoBrowserCellTargetViewDelegate)]
                && [self.targetView respondsToSelector:@selector(photoBrowserWillDisappear)]) {
                [(id)self.targetView photoBrowserWillDisappear];
            }
            wrapperTrackEventWithCustomKeys(@"slide_over", @"random_slide_close",nil, nil, nil);
            break;
        case TTPreviewAnimateStateWillCancel:
            [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                    withAnimation:NO];
            break;
        case TTPreviewAnimateStateDidCancel:
            self.bottomToolBar.alpha = 1;
            if (self.isComplexToolbar) {
                self.topToolBar.alpha = 1;
                self.bottomCoverLayer.opacity = 1;
            }
            cell.hidden = NO;
            [cell resetImageViews];
            break;
        default:
            break;
    }
}

- (UIView *)ttPreviewPanBackGetFinishBackgroundView{
    return self.finishBackView;
}

- (void)ttPreviewPanBackFinishAnimationCompletion{
    self.maskView.alpha = 0;
}

- (void)ttPreviewPanBackCancelAnimationCompletion{
    self.maskView.alpha = 1;
}

- (UIView *)ttPreviewPanBackViewForSwitch
{
    return nil;
}

- (BOOL)ttPreviewPanGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    return cell.getImageView.image != nil;
}

#pragma UIPanGestureDelegte

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    if (gestureRecognizer == self.panGestureRecognizer){
        if (![TTImagePreviewAnimateManager interativeExitEnable]){
            return YES;
        }
        CGRect origionViewFrame = [self ttPreviewPanBackGetOriginView].frame;
        if (CGRectGetWidth(origionViewFrame) == 0 || CGRectGetHeight(origionViewFrame) == 0){
            return YES;
        }
        return cell.getImageView.image == nil;
    }
    return YES;
}

@end
