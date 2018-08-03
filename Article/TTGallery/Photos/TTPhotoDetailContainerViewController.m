//
//  TTPhotoDetailContainerViewController.m
//  Article
//
//  Created by xuzichao on 16/7/7.
//
//

#import "TTPhotoDetailContainerViewController.h"
#import "TTPhotoDetailViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "ArticleTabBarStyleNewsListViewController.h"
#import "TTArticleTabBarController.h"
#import "TTDetailContainerViewController.h"
#import "TTDeviceHelper.h"

#import "UIView+CustomTimingFunction.h"
#import "TTArticlePicView.h"
#import "TTTopBar.h"
#import "TTImagePreviewAnimateManager.h"
#import "TTPhotoTabViewController.h"
#import "TTCollectionPageViewController.h"
#import <TTInteractExitHelper.h>

#define TTPhotoRelationPhotosBeganOffSet 64

#pragma mark -- 图集包裹控制器
@interface TTPhotoDetailContainerViewController ()<TTPhotoDetailViewContainerDelegate,UIGestureRecognizerDelegate,TTPreviewPanBackDelegate>

@property(nonatomic, assign) NewsGoDetailFromSource fromSource;
@property (nonatomic ,assign) CGRect originRect;
@property (nonatomic, strong) UIView *snapShotView;
@property (nonatomic, strong) TTPhotoDetailViewController *realPhotoDetailController;
@property (nonatomic, assign) TTPhotoDetailMoveDirection direction;
@property (nonatomic, strong) UIViewController  *needDisplayVC;

@property (nonatomic, strong) SSThemedView *blackLayer;
@property (nonatomic, assign) UIInterfaceOrientation initOrientation;

//处理图集推荐手势并行
@property (nonatomic, weak) id picturesRecommendViewDelegate;
@property (nonatomic, strong) UICollectionView *picturesRecommendView;
@property (nonatomic, strong) UIPanGestureRecognizer *picturesGesture;
@property (nonatomic, assign) CGFloat beginDragY;
@property (nonatomic, assign) BOOL panRun;//表示是否是手势拖动导致图集退出

@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, strong) UIPanGestureRecognizer *horiPanGesture;//处理垂直滑动退出的手势

@property (nonatomic, assign) CGRect picViewFrame;
@property (nonatomic, assign) TTArticlePicViewStyle picViewStyle;
@property (nonatomic, strong) SSThemedImageView *fakeImageView;
@property (nonatomic, strong) TTArticlePicView *fakePicView;

@property (nonatomic, assign) BOOL hasCleanPreviousVCIfNeed;

@property (nonatomic, strong) TTImagePreviewAnimateManager *animateManager;
@property (nonatomic, weak) UIView *finishBackView;
@property (nonatomic, strong) UIView *bottomSnapShotView;
@property (nonatomic, weak)UIView *targetView;
@property (nonatomic, assign)CGRect animateFrame;
@property (nonatomic, weak) UIView *popToView;//pop之后回到的view
@property (nonatomic, strong)UIView *navViewSnapshotView;
@property (nonatomic, assign)BOOL hasInstallBackView;
@property (nonatomic, assign)BOOL transitionAnimated;
@property (nonatomic, assign)BOOL preStatusBarHidden;
@end

static NSInteger screenshotViewTag = 1119;
@implementation TTPhotoDetailContainerViewController
{
    BOOL _initPresent;
    BOOL _reachDismissCondition;
    CGFloat _initNativeNatantViewAlpha; //动画前原生图集浮层alpha值
    CGFloat _initTopViewAlpha; //动画前顶部工具栏alpha值
    CGFloat _initToolbarViewAlpha; //动画前底部工具栏alpha值
    CGFloat _initNextViewAlpha;
    BOOL _hideWhenMove;//拖动过程中隐藏顶部工具栏、图集浮层、底部工具栏
}

@synthesize leftBarButton;
@synthesize rightBarButtons;
@synthesize dataSource;
@synthesize delegate;

- (instancetype)initWithDetailViewModel:(TTDetailModel *)model
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSDictionary *params = model.baseCondition;
        self.transitionAnimated = model.transitionAnimated;
        self.fromSource = model.fromSource;
        self.picViewFrame = CGRectFromString([params tt_stringValueForKey:@"picViewFrame"]);
        self.picViewStyle = [params tt_intValueForKey:@"picViewStyle"];
        self.targetView = [params valueForKey:@"targetView"];
        self.realPhotoDetailController = [[TTPhotoDetailViewController alloc] initWithDetailViewModel:model];
        self.realPhotoDetailController.containerDelegate = self;
        self.ttNavBarStyle = self.realPhotoDetailController.ttNavBarStyle;
        self.ttHideNavigationBar = self.realPhotoDetailController.ttHideNavigationBar;
        self.ttStatusBarStyle = self.realPhotoDetailController.ttStatusBarStyle;
        self.realPhotoDetailController.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [self.realPhotoDetailController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.detailModel = model;
        [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self frameTransform];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    parent.ttDragToRoot = [self p_shouldResponseToQuickExit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.initOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self fixOSLessThanSevenFrameRect];
    
    //正常视图加载
    self.realPhotoDetailController.dataSource = self.dataSource;
    self.realPhotoDetailController.delegate = self.delegate;
    
    [self.realPhotoDetailController willMoveToParentViewController:self];
    [self addChildViewController:self.realPhotoDetailController];
    CGRect originRect =  self.originRect;
    originRect.origin.y = + CGRectGetHeight(originRect);
    self.realPhotoDetailController.view.frame = originRect;
    [self.view addSubview:self.realPhotoDetailController.view];
    [self.realPhotoDetailController didMoveToParentViewController:self];
    
    //相关的推荐图集代理需要在这个位置设置
    self.realPhotoDetailController.nativeDetailView.imageCollectionView.cellScrolldelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:self.ttStatusBarStyle animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_initPresent) {
        self.realPhotoDetailController.view.alpha = 0;
        self.realPhotoDetailController.view.frame = self.originRect;
        [UIView animateWithDuration:0.25 animations:^{
            self.realPhotoDetailController.view.alpha = 1;
        } completion:^(BOOL finished) {
            _snapShotView.alpha = 0;
            self.blackLayer.alpha = 1;
            [self prepareViewAfterAppear];
            [self p_cleanPhotoDetailViewControllersInNavIfNeed];
        }];
        //准备手势监听
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveGesture:)];
        gesture.delegate = self;
        _horiPanGesture = gesture;
        [self.view addGestureRecognizer:gesture];
        if ([TTImagePreviewAnimateManager interativeExitEnable]) {
            [self.animateManager registeredPanBackWithGestureView:self.view];
        }
        _initPresent = YES;
        //第一次进来的时候强制显示statusbar
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } else {
        self.originRect = self.realPhotoDetailController.view.frame;
    }
    [Answers logCustomEventWithName:@"interactive_exit" customAttributes:@{@"album_open" : @"1"}];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if ([parent.view viewWithTag:screenshotViewTag] == nil){
        _snapShotView = [TTPhotoDetailManager addScreenShotViewBeforePushSelf:parent];
        [parent.view insertSubview:_snapShotView atIndex:0];
    }
    parent.view.backgroundColor = [UIColor clearColor];
}

- (void)prepareViewAfterAppear
{
    _initPresent = YES;
    _reachDismissCondition = NO;
    self.direction = kPhotoDetailMoveDirectionNone;
}

- (void)handleMoveGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
        return;
    }
    
    if (![[TTPhotoDetailManager shareInstance] moveAnimateSwicth]) {
        return;
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panRun = YES;
            [self installBackViewIfNeed];
            CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
            if ([self _isGesturePortraitWithTranslation:translation] &&
                !self.realPhotoDetailController.isShowingRelated) {
                [self _hideGalleryIntroWithFastHide:YES];
            }
            break;
        case UIGestureRecognizerStateChanged: {
            
            [self slidePhotoViewWhenGestureChanged:gestureRecognizer];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self animatePhotoViewWhenGestureEnd];
            
            self.panRun = NO;
            break;
        }
        default:
            break;
    }
}

//释放的动画
- (void)animatePhotoViewWhenGestureEnd
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.realPhotoDetailController.view.alpha = 1;
    
    CGRect endRect = self.originRect;
    CGFloat opacity = 1;
    
    if (_reachDismissCondition) {
    
        if (self.direction == kPhotoDetailMoveDirectionVerticalBottom)
        {
            endRect.origin.y += CGRectGetHeight(self.originRect);
            if (self.panRun){
                wrapperTrackEventWithCustomKeys(@"slide_over", @"down_slide_close", [@(self.realPhotoDetailController.detailModel.article.uniqueID?:0)stringValue], nil, nil);
            }
        }
        else if (self.direction == kPhotoDetailMoveDirectionVerticalTop)
        {
            endRect.origin.y -= CGRectGetHeight(self.originRect);
            if (self.panRun){
                wrapperTrackEventWithCustomKeys(@"slide_over", @"up_slide_close", [@(self.realPhotoDetailController.detailModel.article.uniqueID?:0)stringValue], nil, nil);
            }
        }
        opacity = 0;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.realPhotoDetailController.view.frame = endRect;
        self.blackLayer.alpha = opacity;
        
    } completion:^(BOOL finished) {
        [self uninstallBackViewIfNeed];
        [self animationCompletion];
    }];
}

- (void)animationCompletion {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    self.direction = kPhotoDetailMoveDirectionNone;
    [self showTopViewAndBottomView];
    self.realPhotoDetailController.isInVertiMoveGesture = NO;
    if (_reachDismissCondition) {
        if ([self p_shouldResponseToQuickExit]) {
            if ([TTDeviceHelper OSVersionNumber] < 8.0){
                if (self.needDisplayVC) {
                    [self.realPhotoDetailController.navigationController popToViewController:self.needDisplayVC animated:NO];
                }
                else {
                    [self.realPhotoDetailController.navigationController popToRootViewControllerAnimated:NO];
                }
            }else{
                [self.realPhotoDetailController.navigationController popViewControllerAnimated:NO];
            }
        }
        else {
            [self.realPhotoDetailController.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (void)slidePhotoViewWhenGestureChanged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view.superview];
    
    [self refreshPhotoViewFrame:translation velocity:velocity];
    
}

//整体的动画
- (void)refreshPhotoViewFrame:(CGPoint)translation velocity:(CGPoint)velocity
{
    
    if (self.direction == kPhotoDetailMoveDirectionNone) {
        //刚开始识别方向
        if (translation.y > KPhotoDeMoveDirectionRecognizer) {
            self.direction = kPhotoDetailMoveDirectionVerticalBottom;
        }
        
        if (translation.y < - KPhotoDeMoveDirectionRecognizer) {
            self.direction = kPhotoDetailMoveDirectionVerticalTop;
        }
    }else{
        
        //重新识别方向
        TTPhotoDetailMoveDirection currentDirection = kPhotoDetailMoveDirectionNone;
        if (translation.y > KPhotoDeMoveDirectionRecognizer) {
            currentDirection = kPhotoDetailMoveDirectionVerticalBottom;
        }
        else if (translation.y < - KPhotoDeMoveDirectionRecognizer) {
            currentDirection = kPhotoDetailMoveDirectionVerticalTop;
        }
        else {
            currentDirection = kPhotoDetailMoveDirectionNone;
        }
        
        if (currentDirection == kPhotoDetailMoveDirectionNone) {
            self.direction = currentDirection;
        }
        
        CGFloat xFraction = translation.x / CGRectGetHeight(self.originRect);
        xFraction = fminf(fmaxf(xFraction, 0.0), 1.0);
        
        BOOL verticle = self.direction == kPhotoDetailMoveDirectionVerticalBottom || self.direction == kPhotoDetailMoveDirectionVerticalTop;
        CGFloat y = 0;
        if (self.direction == kPhotoDetailMoveDirectionVerticalTop) {
            
            y = translation.y + KPhotoDeMoveDirectionRecognizer;
        }
        else if (self.direction == kPhotoDetailMoveDirectionVerticalBottom){
            y = translation.y - KPhotoDeMoveDirectionRecognizer;
        }
        
        CGFloat yFraction = fabs(translation.y / CGRectGetHeight(self.originRect));
        yFraction = fminf(fmaxf(yFraction, 0.0), 1.0);
        
        if (verticle) {
            if (yFraction > 0.2) {
                _reachDismissCondition = YES;
            }
            else {
                _reachDismissCondition  = NO;
            }
            
            if (velocity.y > 1500) {
                _reachDismissCondition = YES;
            }
            
            
            self.blackLayer.alpha = (1 - yFraction * 2 / 3);
            
            self.realPhotoDetailController.isInVertiMoveGesture = YES;
        }
        
        
        CGRect frame = CGRectMake(0, y, CGRectGetWidth(self.originRect), CGRectGetHeight(self.originRect));
        self.realPhotoDetailController.view.frame = frame;
        
        //fake动画处理
        if (verticle) {
            [self hideTopViewAndBottomView];
        }
        
    }
}

///隐藏顶部和底部view
- (void)hideTopViewAndBottomView
{
    if (_hideWhenMove) {
        return;
    }
    _hideWhenMove = YES;
    
    ///web 图集
    self.realPhotoDetailController.webContainer.backgroundColor = [UIColor clearColor];
    self.realPhotoDetailController.webContainer.containerScrollView.backgroundColor = [UIColor clearColor];
    self.realPhotoDetailController.webContainer.webView.backgroundColor = [UIColor clearColor];
    [self.realPhotoDetailController.webContainer.webView evaluateJavaScriptFromString:@"TTGallery.setBackgroundColor('transparent')" completionBlock:nil];
    
    ///native 图集
    self.realPhotoDetailController.nativeDetailView.backgroundColor = [UIColor clearColor];
    
    _initTopViewAlpha = self.realPhotoDetailController.topView.alpha;
    self.realPhotoDetailController.topView.alpha = 0;
    if (!self.realPhotoDetailController.isShowingRelated) {
        [self _hideGalleryIntroWithFastHide:NO];
    }
    _initToolbarViewAlpha = self.realPhotoDetailController.toolbarView.alpha;
    self.realPhotoDetailController.toolbarView.alpha = 0;
    
    if ([self.realPhotoDetailController shouldLoadNativeGallery]) {
        // 存储图集浮层alpha值
        _initNativeNatantViewAlpha = self.realPhotoDetailController.nativeDetailView.imageCollectionView.natantView.alpha;
        self.realPhotoDetailController.nativeDetailView.imageCollectionView.natantView.alpha = 0;
    }
    
    _initNextViewAlpha = self.realPhotoDetailController.nativeDetailView.imageCollectionView.nextView.alpha;
    
    self.realPhotoDetailController.nativeDetailView.imageCollectionView.nextView.alpha = 0;
}


- (void)showTopViewAndBottomView
{
    _hideWhenMove = NO;
    
    //web图集
    self.realPhotoDetailController.webContainer.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    self.realPhotoDetailController.webContainer.containerScrollView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    self.realPhotoDetailController.webContainer.webView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    [self.realPhotoDetailController.webContainer.webView evaluateJavaScriptFromString:@"TTGallery.setBackgroundColor('')" completionBlock:nil];
    //在非点击态下需要恢复文字描述
    if (![self.realPhotoDetailController shouldLoadNativeGallery]) {
        if (!self.realPhotoDetailController.tapOn && !self.realPhotoDetailController.isShowingRelated) {
            [self.realPhotoDetailController.webContainer.webView stringByEvaluatingJavaScriptFromString:@"TTGallery.ui.showControls()" completionHandler:nil];
        }
    }
    
    //native图集
    self.realPhotoDetailController.nativeDetailView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    //顶部
    if (_initTopViewAlpha != 0) {
        [UIView animateWithDuration:0.15 animations:^{
            self.realPhotoDetailController.topView.alpha = _initTopViewAlpha;
        }];
    }
    
    //底部
    if (_initToolbarViewAlpha != 0) {
        [UIView animateWithDuration:0.15 animations:^{
            self.realPhotoDetailController.toolbarView.alpha = _initToolbarViewAlpha;
            if ([self.realPhotoDetailController shouldLoadNativeGallery]) {
                self.realPhotoDetailController.nativeDetailView.imageCollectionView.natantView.alpha = _initNativeNatantViewAlpha;
            }
        }];
    }
    
    //浏览相关图集
    if (_initNextViewAlpha != 0) {
        [UIView animateWithDuration:0.15 animations:^{
            self.realPhotoDetailController.nativeDetailView.imageCollectionView.nextView.alpha = _initNextViewAlpha;
        }];
    }
}

//修复ios7系统bug
- (void)fixOSLessThanSevenFrameRect
{
    BOOL isHorizonal = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
    [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight;
    BOOL osLessThan7 = [TTDeviceHelper OSVersionNumber] < 8;
    BOOL isPad = [TTDeviceHelper isPadDevice];
    if (isPad && isHorizonal && osLessThan7) {
        self.originRect = CGRectMake(0, 0, self.realPhotoDetailController.view.frame.size.height, self.realPhotoDetailController.view.frame.size.width);
    }
    else {
        self.originRect = self.realPhotoDetailController.view.bounds;
    }
}

- (BOOL)p_shouldResponseToQuickExit
{
    return self.detailModel.needQuickExit || [SSCommonLogic detailQuickExitEnabled];
}

- (void)fixRotateSnapView:(UIInterfaceOrientation)fromOrientation
{
    
    BOOL notInitPortrait = self.initOrientation == UIInterfaceOrientationLandscapeLeft
    || self.initOrientation == UIInterfaceOrientationLandscapeRight;
    BOOL currentIsPortrait =  [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait;
    
    BOOL fromInitPortrait = fromOrientation == self.initOrientation;
    
    if ([TTDeviceHelper isPadDevice] && notInitPortrait && currentIsPortrait && fromInitPortrait) {
        
        TTDetailContainerViewController *detailContainer = (TTDetailContainerViewController *)self.parentViewController;
        UIView *aimView = [self p_shouldResponseToQuickExit]? self.snapShotView: detailContainer.shotScreenView;
        CGFloat len = aimView.frame.size.height;
        CGFloat wid = aimView.frame.size.width;
        aimView.transform = CGAffineTransformIdentity;
        
        
        if (fromOrientation == UIInterfaceOrientationLandscapeLeft) {
            CGAffineTransform t = CGAffineTransformMakeTranslation(len/2-wid/2, wid/2 - len/2);
            aimView.transform = CGAffineTransformRotate(t, -M_PI_2);
        }
        else if (fromOrientation == UIInterfaceOrientationLandscapeRight) {
            
            CGAffineTransform t = CGAffineTransformMakeTranslation(len/2-wid/2, wid/2 - len/2);
            aimView.transform = CGAffineTransformRotate(t, M_PI_2);
        }
    }
    
}

- (void)frameTransform{
    UIView *targetView = [self ttPreviewPanBackGetBackMaskView];
    if (nil == targetView){
        return;
    }
    _animateFrame = _picViewFrame;
    _picViewFrame = [targetView convertRect:_picViewFrame toView:nil];
}

- (void)p_cleanPhotoDetailViewControllersInNavIfNeed
{
    if (_hasCleanPreviousVCIfNeed) {
        return;
    }
    
    _hasCleanPreviousVCIfNeed = YES;
    
    if (![self p_shouldResponseToQuickExit]) {
        return;
    }
    
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        return;
    }
    
    NSArray *reverseViewControllers = [[[self.navigationController viewControllers] reverseObjectEnumerator] allObjects];
    NSMutableArray *mutableReverse = reverseViewControllers.mutableCopy;
    
    if (reverseViewControllers.count <= 1) {
        return;
    }
    
    UIViewController *previousVC = reverseViewControllers[1];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (![previousVC isKindOfClass:NSClassFromString(@"TTDetailContainerViewController")] || ![previousVC respondsToSelector:NSSelectorFromString(@"detailViewController")]) {
        return;
    }
    
    TTPhotoDetailContainerViewController *previousDetailVC = (TTPhotoDetailContainerViewController *)[previousVC performSelector:NSSelectorFromString(@"detailViewController")];
#pragma clang diagnostic pop
    if (![previousDetailVC isKindOfClass:self.class] || [previousDetailVC isEqual:self]) {
        return;
    }
    
    [mutableReverse removeObject:previousVC];
    
    NSArray *normalViewControllers = [[mutableReverse reverseObjectEnumerator] allObjects];
    [self.navigationController setViewControllers:normalViewControllers animated:YES];
}

//处理推荐图集处的手势
#pragma mark -- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL rightView = [NSStringFromClass(otherGestureRecognizer.view.class) isEqualToString:@"UICollectionView"];
    BOOL rightGesture = [NSStringFromClass(otherGestureRecognizer.class) isEqualToString:@"UIScrollViewPanGestureRecognizer"];
    
    // 右滑和上滑会触发此webView内部手势
    BOOL isWebTouchGesture = [NSStringFromClass(otherGestureRecognizer.class) isEqualToString:@"UIWebTouchEventsGestureRecognizer"];
    
    if (rightView && rightGesture) {
        self.picturesGesture = (UIPanGestureRecognizer *)otherGestureRecognizer;
        [self.picturesGesture  addTarget:self action:@selector(handlePicturesGesture:)];
    }
    
    if([TTDeviceHelper isPadDevice] && [otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]] && otherGestureRecognizer.view == self.navigationController.view) {
        return YES;
    }
    else if (isWebTouchGesture) {
        CGPoint translation = [((UIPanGestureRecognizer *)gestureRecognizer) translationInView:gestureRecognizer.view];
        BOOL isPullUpPanGesture = translation.y < 0 && [self _isGesturePortraitWithTranslation:translation];
        return isPullUpPanGesture;
    }
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == _horiPanGesture){
        
        CGPoint velocity = [_horiPanGesture velocityInView:self.view];
        if (fabs(velocity.x) > fabs(velocity.y)){
            return NO;
        }
        
        if (![TTImagePreviewAnimateManager interativeExitEnable]){
            return YES;
        }
        
        CGRect origionViewFrame = [self ttPreviewPanBackGetOriginView].frame;
        if (CGRectGetWidth(origionViewFrame) == 0 || CGRectGetHeight(origionViewFrame) == 0){
            return YES;
        }
        
        if (_detailModel.article.articleType == ArticleTypeNativeContent && [self.realPhotoDetailController.nativeDetailView currentShowImageView].currentImageView.image != nil){
            return NO;
        }
        
        return YES;
    }
    return YES;
}

- (BOOL)_isGesturePortraitWithTranslation:(CGPoint)translation
{
    return (fabs(translation.y) > 0) && (fabs(translation.y) >= fabs(translation.x));
}

- (void)_hideGalleryIntroWithFastHide:(BOOL)fastHide
{
    NSString *jsMethod = fastHide? @"TTGallery.ui.hideFastControls()": @"TTGallery.ui.hideControls()";
    //web图集需要隐藏文字描述
    if (![self.realPhotoDetailController shouldLoadNativeGallery]) {
        [self.realPhotoDetailController.webContainer.webView stringByEvaluatingJavaScriptFromString:jsMethod completionHandler:nil];
    }
}

- (void)handlePicturesGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
        return;
    }
    
    if (![[TTPhotoDetailManager shareInstance] moveAnimateSwicth]) {
        return;
    }
    
    //picturesRecommendView就是相关图集的cell
    if (!self.picturesRecommendView) {
        self.picturesRecommendView = (UICollectionView *)gestureRecognizer.view;
    }
    
    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            
            
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self animatePhotoViewWhenGestureEnd];
        default:
            break;
    }
}

#pragma mark -- ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait) {
        return;
    }
    CGFloat contentYoffset = scrollView.contentOffset.y;
    if (self.beginDragY == 0) {
        self.beginDragY = contentYoffset;
    }
    //trick的方式，因为相关图集里面可能会出现有搜索词的情况
    CGFloat relationPhotosBeganOffSet = MAX(TTPhotoRelationPhotosBeganOffSet, scrollView.contentInset.top);
    
    if (self.beginDragY <= -relationPhotosBeganOffSet) {
        if (self.direction == kPhotoDetailMoveDirectionNone) {
            if (contentYoffset <= -relationPhotosBeganOffSet) {
                self.direction = kPhotoDetailMoveDirectionVerticalBottom;
            }
        }
        
        if (self.direction == kPhotoDetailMoveDirectionVerticalBottom &&
            self.picturesGesture.state != UIGestureRecognizerStatePossible) {
            self.picturesRecommendView.contentOffset = CGPointMake(0, -relationPhotosBeganOffSet);
        }
    }
    else {
        if (self.direction == kPhotoDetailMoveDirectionNone &&
            self.picturesGesture.state != UIGestureRecognizerStatePossible) {
            
            BOOL endBottom = scrollView.contentSize.height - contentYoffset <= scrollView.frame.size.height;
            if (endBottom) {
                self.direction = kPhotoDetailMoveDirectionVerticalTop;
            }
        }
    }
    
    if (self.direction != kPhotoDetailMoveDirectionNone &&
        self.picturesGesture.state != UIGestureRecognizerStatePossible) {
        
        CGPoint transaction = [self.picturesGesture translationInView:self.picturesGesture.view];
        CGPoint velocity = [self.picturesGesture velocityInView:self.picturesGesture.view];
        [self refreshPhotoViewFrame:transaction velocity:velocity];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.beginDragY = 0;
    self.direction = kPhotoDetailMoveDirectionNone;
}

#pragma mark -- TTPhotoDetailViewContainerDelegate
- (void)ttPhotoDetailViewBackBtnClick
{
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait){
        self.direction = kPhotoDetailMoveDirectionVerticalBottom;
        _reachDismissCondition = YES;
        self.blackLayer.hidden = YES;
        if (_detailModel.article.articleType != ArticleTypeNativeContent || [self.realPhotoDetailController.nativeDetailView currentShowImageView].currentImageView.image == nil){
            [self installBackViewIfNeed];
            [self animatePhotoViewWhenGestureEnd];
        }else{
            [self.animateManager dismissWithoutGesture];
        }
    }
    else {
        [self.realPhotoDetailController.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- TTDetailViewControllerDelegate
- (void)detailContainerViewController:(nullable SSViewControllerBase *)container reloadData:(nullable TTDetailModel *)detailModel {
    if ([self.realPhotoDetailController respondsToSelector:@selector(detailContainerViewController:reloadData:)]) {
        [self.realPhotoDetailController detailContainerViewController:container reloadData:detailModel];
    }
}

- (void)detailContainerViewController:(nullable SSViewControllerBase *)container loadContentFailed:(nullable NSError *)error{
    if ([self.realPhotoDetailController respondsToSelector:@selector(detailContainerViewController:loadContentFailed:)]) {
        [self.realPhotoDetailController detailContainerViewController:container loadContentFailed:error];
    }
}

- (void)detailContainerViewController:(SSViewControllerBase *)container reloadDataIfNeeded:(TTDetailModel *)detailModel {
    if ([self.realPhotoDetailController respondsToSelector:@selector(detailContainerViewController:reloadDataIfNeeded:)]) {
        [self.realPhotoDetailController detailContainerViewController:container reloadDataIfNeeded:detailModel];
    }
}

- (BOOL)shouldShowErrorPageInDetailContaierViewController:(SSViewControllerBase *)container {
    return YES;
}

#pragma mark -- rotate support

- (BOOL)shouldAutorotate
{
    if (![TTDeviceHelper isPadDevice] && !self.realPhotoDetailController.commentViewController.view.hidden) {
        return NO;
    }
    if (self.panRun) {
        return NO;
    }
    if (![TTDeviceHelper isPadDevice] && self.realPhotoDetailController.hasCommentVCAppear) {
        return NO;
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    _initNextViewAlpha = self.realPhotoDetailController.nativeDetailView.imageCollectionView.nextView.alpha;
    [self showTopViewAndBottomView];
    [self fixOSLessThanSevenFrameRect];
    [self fixRotateSnapView:fromInterfaceOrientation];
    if ([TTDeviceHelper isPadDevice]) {//ipad上转屏后退出的话，图片的位置变了
        self.picViewFrame = CGRectZero;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.view.bounds;
        self.realPhotoDetailController.view.frame = rect;
        self.blackLayer.frame = rect;
        
    } completion:nil];
}

#pragma mark -- prefers

- (BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}

- (void)pushAnimationCompletion
{
    if ([TTImagePreviewAnimateManager interativeExitEnable]){
        [self installBackViewIfNeed];
        [self uninstallBackViewIfNeed];
    }
}

#pragma mark -- Getter & Setter

- (UIView *)finishBackView{
    if (_finishBackView == nil){
        _finishBackView = [TTInteractExitHelper getSuitableFinishBackViewInPreViewController];
    }
    return _finishBackView;
}

- (TTImagePreviewAnimateManager *)animateManager{
    if (_animateManager == nil){
        _animateManager = [[TTImagePreviewAnimateManager alloc] init];
        _animateManager.panDelegate = self;
    }
    return _animateManager;
}

- (SSThemedView *)blackLayer
{
    if (_blackLayer == nil){
        _blackLayer = [[SSThemedView alloc] initWithFrame:self.view.frame];
        _blackLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blackLayer.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        _blackLayer.tag = 9999;
    }
    return _blackLayer;
}

#pragma mark -- TTPanBackGestureDelegate

- (UIView *)ttPreviewPanBackGetOriginView{
    return [self.realPhotoDetailController.nativeDetailView currentShowImageView].currentImageView;
}

- (UIView *)ttPreviewPanBackGetBackMaskView{
    return _targetView ?: self.finishBackView;
}

- (UIImage *)ttPreviewPanBackImageForSwitch{
    if (self.picViewStyle == TTArticlePicViewStyleLarge){
        return self.fakePicView.picView1.imageView.image;
    }
    return nil;
}

- (UIView *)ttPreviewPanBackViewForSwitch{
    return self.fakePicView;
}

- (CGRect)ttPreviewPanBackTargetViewFrame{
    return self.animateFrame;
}

- (void)ttPreviewPanBackStateChange:(TTPreviewAnimateState)currentState scale:(float)scale{
    switch (currentState) {
        case TTPreviewAnimateStateWillBegin:
            self.preStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self installBackViewIfNeed];
            self.panRun = YES;
            self.realPhotoDetailController.view.hidden = YES;
            [self hideTopViewAndBottomView];
            break;
        case TTPreviewAnimateStateChange:
            _blackLayer.alpha = MAX(0,(scale*14-13 - _animateManager.minScale)/(1 - _animateManager.minScale));
            break;
        case TTPreviewAnimateStateWillFinish:
            self.fakePicView.picView2.transform = CGAffineTransformMakeScale(2, 2);
            break;
        case TTPreviewAnimateStateDidFinish:
        {
            _reachDismissCondition = YES;
            [self installNavViewSnapshot];
            [self uninstallBackViewIfNeed];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self animationCompletion];
                [self uninstallNavViewSnapshot];
            });
            [Answers logCustomEventWithName:@"interactive_exit" customAttributes:@{@"album_pan_close" : @"1"}];
            wrapperTrackEventWithCustomKeys(@"slide_over", @"random_slide_close", [@(self.realPhotoDetailController.detailModel.article.uniqueID?:0)stringValue], nil, nil);
        }
            break;
        case TTPreviewAnimateStateDidCancel:
            [[UIApplication sharedApplication] setStatusBarHidden:self.preStatusBarHidden];
            [self uninstallBackViewIfNeed];
            self.realPhotoDetailController.view.hidden = NO;
            _reachDismissCondition = NO;
            [self animationCompletion];
            self.panRun = NO;
            break;
        default:
            break;
    }
}

- (void)installBackViewIfNeed{
    if (_hasInstallBackView){
        return;
    }
    _hasInstallBackView = YES;
    UINavigationController *topNavController;
    self.snapShotView.hidden = YES;
    topNavController = [TTUIResponderHelper topNavigationControllerFor:nil];
    [ self.navigationController.topViewController.view viewWithTag:screenshotViewTag].hidden = YES;
    
    if (_fakePicView == nil && !CGRectEqualToRect(self.picViewFrame, CGRectZero)){
        _fakePicView = [[TTArticlePicView alloc] initWithStyle:self.picViewStyle];
        _fakePicView.frame = self.picViewFrame;
        _fakePicView.alpha = 0;
        _fakePicView.hiddenMessage = YES;
        _fakePicView.backgroundColorThemeKey = kColorBackground4;
        _fakePicView.picView1.layer.borderWidth = 0;
        _fakePicView.picView2.layer.borderWidth = 0;
        _fakePicView.picView3.layer.borderWidth = 0;
        [_fakePicView updatePics:self.detailModel.orderedData];
    }
    NSArray *VCs = [[topNavController.viewControllers reverseObjectEnumerator] allObjects];
    if (VCs.count > 1){
        UIViewController *VC = [VCs objectAtIndex:1];
        if ([VC isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]){
            _popToView = VC.view;
            if (_bottomSnapShotView == nil){
                _bottomSnapShotView = [TTPhotoDetailManager tabBarSnapShotFromViewController:topNavController];
            }
            [self.navigationController.view addSubview:_popToView];
            [self.navigationController.view sendSubviewToBack: _popToView];
            [self.navigationController.view insertSubview:_bottomSnapShotView aboveSubview:_popToView];
            [self.view insertSubview:self.blackLayer atIndex:0];
            _popToView.frame = self.navigationController.view.bounds;
        }else{
            _popToView = VC.view;
            [self.navigationController.view addSubview:_popToView];
            [self.navigationController.view sendSubviewToBack: _popToView];
            [self.view insertSubview:self.blackLayer atIndex:0];
            _popToView.frame = self.navigationController.view.bounds;
        }
    }
}

- (void)installNavViewSnapshot
{
    _navViewSnapshotView = [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
    _navViewSnapshotView.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:_navViewSnapshotView];
}

- (void)uninstallNavViewSnapshot
{
    if (_navViewSnapshotView.superview){
        [_navViewSnapshotView removeFromSuperview];
    }
}

- (void)uninstallBackViewIfNeed{
    if (!_hasInstallBackView){
        return;
    }
    self.snapShotView.hidden = NO;
    [self.navigationController.topViewController.view viewWithTag:screenshotViewTag].hidden = NO;
    [_popToView removeFromSuperview];
    [_bottomSnapShotView removeFromSuperview];
    [_blackLayer removeFromSuperview];
    _hasInstallBackView = NO;
}

- (void)ttPreviewPanBackFinishAnimationCompletion{
    self.blackLayer.alpha = 0;
    self.fakePicView.picView2.transform = CGAffineTransformIdentity;
}

- (void)ttPreviewPanBackCancelAnimationCompletion{
    self.blackLayer.alpha = 1;
}

- (UIView *)ttPreviewPanBackGetFinishBackgroundView{
    return self.finishBackView;
}

- (BOOL)ttPreviewPanGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait){
        return NO;
    }
    
    return _detailModel.article.articleType == ArticleTypeNativeContent && [self.realPhotoDetailController.nativeDetailView currentShowImageView].currentImageView.image;
}

@end


static TTPhotoDetailManager  * transitionManager;

@implementation TTPhotoDetailManager

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transitionManager = [[self alloc] init];
    });
    return transitionManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.moveAnimateSwicth = YES;
    }
    
    return self;
}

- (void)setTransitionActionValid:(BOOL)valid
{
    self.moveAnimateSwicth = valid;
}

//伪装截屏
+ (UIView *)addScreenShotViewBeforePushSelf:(UIViewController *)aimVC
{
    
    UIView * view = nil;
    
    NSInteger lastIndex = 0;
    if (aimVC.navigationController.viewControllers.count > 2) {
        lastIndex = aimVC.navigationController.viewControllers.count - 2;
    }
    UIViewController *lastController = [aimVC.navigationController.viewControllers objectAtIndex:lastIndex];
    
    if (lastController) {
        
        view = [lastController.view snapshotViewAfterScreenUpdates:NO];
        
        [view addSubview:[self tabBarSnapShotFromViewController:lastController]];
    }
    else {
        
        UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
        UIGraphicsBeginImageContext(screenWindow.frame.size);
        [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        view = [[UIImageView alloc] initWithImage:viewImage];
        view.frame = screenWindow.frame;
    }
    
    if (!view) {
        
        view = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    }
    
    view.tag = screenshotViewTag;
    
    return view;
}
+ (UIView *)tabBarSnapShotFromViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]) {
        UIWindow *rootWin = [[[UIApplication sharedApplication] delegate]window];
        TTArticleTabBarController * rootTabController = (TTArticleTabBarController*)rootWin.rootViewController;
        UITabBar *tabBar = rootTabController.tabBar;
        UIView *tabBarSnapShot = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(tabBar.frame), 0, CGRectGetWidth(tabBar.frame), CGRectGetHeight(viewController.view.frame))];
        
        //iOS10 TabBar高斯模糊效果的子视图换成了UIVisualEffectview 直接截图是截不到的
        //https://developer.apple.com/reference/uikit/uivisualeffectview
        if ([TTDeviceHelper OSVersionNumber] >= 10.f) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[[TTThemeManager sharedInstance_tt].currentThemeName isEqualToString:@"night"] ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            effectView.frame = tabBar.frame;
            [tabBarSnapShot addSubview:effectView];
        }
         

        //tabBar截图
        tabBar.layer.hidden = NO;
        UIGraphicsBeginImageContextWithOptions(tabBarSnapShot.bounds.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, CGRectGetHeight(tabBarSnapShot.frame)-CGRectGetHeight(tabBar.frame));
        [tabBar.layer renderInContext:context];
        
        UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIGraphicsEndImageContext();
        UIImageView *snapShot = [[UIImageView alloc] initWithImage:image];
        snapShot.frame = tabBarSnapShot.bounds;
        [tabBarSnapShot addSubview:snapShot];
        tabBar.layer.hidden = YES;
        return tabBarSnapShot;
    }else if ([viewController isKindOfClass:[UINavigationController class]]){
        UITabBar *tabBar = viewController.tabBarController.tabBar;
        UIView *tabBarSnapShot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tabBar.frame), CGRectGetHeight(tabBar.superview.frame))];
        
        //iOS10 TabBar高斯模糊效果的子视图换成了UIVisualEffectview 直接截图是截不到的
        //https://developer.apple.com/reference/uikit/uivisualeffectview
        if ([TTDeviceHelper OSVersionNumber] >= 10.f) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[[TTThemeManager sharedInstance_tt].currentThemeName isEqualToString:@"night"] ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            effectView.frame = tabBar.frame;
            [tabBarSnapShot addSubview:effectView];
        }
        
        //tabBar截图
        tabBar.layer.hidden = NO;
        UIGraphicsBeginImageContextWithOptions(tabBarSnapShot.bounds.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, CGRectGetHeight(tabBarSnapShot.frame)-CGRectGetHeight(tabBar.frame));
        [tabBar.layer renderInContext:context];
        
        UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIGraphicsEndImageContext();
        UIImageView *snapShot = [[UIImageView alloc] initWithImage:image];
        snapShot.frame = tabBarSnapShot.bounds;
        [tabBarSnapShot addSubview:snapShot];
        tabBar.layer.hidden = YES;
        
        return tabBarSnapShot;
    }
    return nil;
}

@end
