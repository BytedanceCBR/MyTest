//
//  FRPhotoBrowserViewController.m
//  Article
//
//  Created by 王霖 on 17/1/18.
//
//

#import "FRPhotoBrowserViewController.h"
#import "FRPhotoBrowserCell.h"
#import <UIColor+TTThemeExtension.h>
#import "FRPhotoBrowserModel.h"
#import "TTImagePreviewAnimateManager.h"
#import <NetworkUtilities.h>
#import <TTInteractExitHelper.h>
#import "UIViewAdditions.h"
#import "Answers.h"
#import "TTTrackerWrapper.h"
#import <TTUIResponderHelper.h>

static NSString * const kPhotoBrowserCellIdentifier = @"kPhotoBrowserCellIdentifier";

static NSString * const kShowMaskViewAnimationKey = @"kShowMaskViewAnimationKey";
static NSString * const kHideMaskViewAnimationKey = @"kHideMaskViewAnimationKey";
static NSString * const kShowBottomBarAnimationKey = @"kShowBottomBarAnimationKey";
static NSString * const kHideBottomBarAnimationKey = @"kHideBottomBarAnimationKey";

static const CGFloat kBottomToolBarHeight = 38.f;
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

@interface FRPhotoBrowserViewController () <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, FRPhotoBrowserCellDelegate, CAAnimationDelegate,TTPreviewPanBackDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSArray <FRPhotoBrowserModel *> * models;
@property (nonatomic, assign) NSUInteger startIndex;

@property (nonatomic, strong) UIView * maskView;
@property (nonatomic, strong) UICollectionView * photoBrowserCollectionView;

@property (nonatomic, strong) UIView * bottomToolBar;
@property (nonatomic, strong) UIView * photoIndexIndicatorLabelContainerView;
@property (nonatomic, strong) UILabel * photoIndexIndicatorLabel;
@property (nonatomic, strong) UIButton * savePhotoButton;

@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;
@property (nonatomic, assign) FRPhotoBrowserViewControllerMoveDirection direction;
@property (nonatomic, assign) BOOL reachDismissCondition;
@property (nonatomic, assign) BOOL reachDragCondition;

@property (nonatomic, assign) BOOL isFirstLayout;
@property (nonatomic, assign) BOOL hasShowStartIndex;
@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign) NSUInteger pageIndex;

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, weak) UIView *finishBackView;
@property (nonatomic, strong) TTImagePreviewAnimateManager *animateManager;
@property (nonatomic, assign) BOOL inList;
@end

@implementation FRPhotoBrowserViewController

#pragma mark - Life circle

- (instancetype)initWithModels:(NSArray<FRPhotoBrowserModel *> *)models startIndex:(NSUInteger)startIndex{
    return [self initWithModels:models startIndex:startIndex targetView:nil];
}

- (instancetype)initWithModels:(NSArray <FRPhotoBrowserModel *> *)models startIndex:(NSUInteger)startIndex targetView:(nullable UIView *)targetView {
    self = [super init];
    if (self) {
        self.models = models;
        if (startIndex >= models.count) {
            startIndex = 0;
        }
        self.startIndex = startIndex;
        self.pageIndex = startIndex;
        _targetView = targetView;
        [self frameTransform];
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
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstLayout = YES;
    [self createComponents];
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
        });
    }
    self.maskView.frame = self.view.bounds;
    self.photoBrowserCollectionView.frame = self.view.bounds;
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    self.bottomToolBar.frame = CGRectMake(0, self.view.height - kBottomToolBarHeight - bottomInset, self.view.width, kBottomToolBarHeight);
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
    
    self.bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - kBottomToolBarHeight, self.view.width, kBottomToolBarHeight)];
    self.bottomToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.bottomToolBar.layer.opacity = 0;
    [self.view addSubview:self.bottomToolBar];
    
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
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    if ([TTImagePreviewAnimateManager interativeExitEnable]){
        self.animateManager.panDelegate = self;
        [self.animateManager registeredPanBackWithGestureView:self.view];
    }
}

- (void)updatePhotoIndexIndicator {
    CGFloat pageWidth = self.photoBrowserCollectionView.frame.size.width;
    float fractionalPage = (self.photoBrowserCollectionView.contentOffset.x + pageWidth / 2) / pageWidth;
    NSInteger page = floor(fractionalPage);
    
    if (self.pageIndex != page) {
        self.photoIndexIndicatorLabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)(page + 1),(unsigned long)self.models.count];
        [self.photoIndexIndicatorLabel sizeToFit];
        self.photoIndexIndicatorLabel.center = CGPointMake(self.photoIndexIndicatorLabelContainerView.width/2, self.photoIndexIndicatorLabelContainerView.height/2);
        
        if (self.indexUpdatedBlock) {
            self.indexUpdatedBlock(self.pageIndex, page);
        }
    }
    
    self.pageIndex = page;
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

#pragma mark - Actions

- (void)savePhotoToAlbum {
    FRPhotoBrowserCell * cell = [self.photoBrowserCollectionView visibleCells].firstObject;
    [cell savePhoto];
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
            [self hidePhotoBrowser];
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
}

- (void)tapPhotoBrowserCell:(FRPhotoBrowserCell *)cell {
    [Answers logCustomEventWithName:@"interactive_exit" customAttributes:@{@"weitoutiao_tap_close" : _inList ? @"列表页":@"详情页"}];
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
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }else if (anim == [self.maskView.layer animationForKey:kHideMaskViewAnimationKey]) {
        self.maskView.layer.opacity = 0;
        [self.maskView.layer removeAnimationForKey:kHideMaskViewAnimationKey];
        self.bottomToolBar.layer.opacity = 0;
        [self.bottomToolBar.layer removeAnimationForKey:kHideBottomBarAnimationKey];
        
        [self hidePhotoBrowser];
    }
}

#pragma mark - Publics

static BOOL staticPhotoBrowserAtTop = NO;
+ (BOOL)photoBrowserAtTop
{
    return staticPhotoBrowserAtTop;
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
    [self finishBackView];
    [Answers logCustomEventWithName:@"interactive_exit" customAttributes:@{@"weitoutiao_open" : _inList ? @"列表页":@"详情页"}];
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
}

- (void)hidePhotoBrowser {
    
    staticPhotoBrowserAtTop = NO;
    [self beginAppearanceTransition:NO animated:YES];
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
            break;
        case TTPreviewAnimateStateChange:
            //20倍的速率
            self.maskView.alpha =  MAX(0,(scale*14-13 - _animateManager.minScale)/(1 - _animateManager.minScale));
            break;
        case TTPreviewAnimateStateDidFinish:
            [self hidePhotoBrowser];
            cell.hidden = NO;
            [cell resetImageViews];
            [Answers logCustomEventWithName:@"interactive_exit" customAttributes:@{@"weitoutiao_pan_close" : _inList ? @"列表页":@"详情页"}];
            wrapperTrackEventWithCustomKeys(@"slide_over", @"random_slide_close",nil, nil, nil);
            break;
        case TTPreviewAnimateStateWillCancel:
            [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                    withAnimation:NO];
            break;
        case TTPreviewAnimateStateDidCancel:
            self.bottomToolBar.alpha = 1;
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
