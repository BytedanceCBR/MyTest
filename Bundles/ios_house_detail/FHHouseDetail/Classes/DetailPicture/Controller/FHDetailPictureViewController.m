//
//  FHDetailPictureViewController.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/15.
//

#import "FHDetailPictureViewController.h"
#import "TTShowImageView.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UIImage+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "TTTracker.h"
#import "TTImagePreviewAnimateManager.h"
#import "ALAssetsLibrary+TTImagePicker.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHFloorPanPicShowViewController.h"

#define kFHDPTopBarHeight 44.f
#define kFHDPBottomBarHeight 40.f

#define kFHDPMoveDirectionStartOffset 20.f

@interface FHDetailPictureViewController ()<UIScrollViewDelegate, TTShowImageViewDelegate,TTPreviewPanBackDelegate,UIGestureRecognizerDelegate>
{
    BOOL alreadyFinished;// 防止多次点击回调造成多次popController
    BOOL _addedToContainer;
    BOOL _navBarHidden;
    BOOL _statusBarHidden;
    UIStatusBarStyle _lastStatusBarStyle;
    BOOL _isRotating;
    BOOL _reachDismissCondition; //是否满足关闭图片控件条件
    BOOL _reachDragCondition; //是否满足过一次触发手势条件
}
@property(nonatomic, copy)TTPhotoScrollViewDismissBlock dismissBlock;
@property(nonatomic, strong)UIScrollView * photoScrollView;
@property(nonatomic, strong)UIView *containerView;

@property(nonatomic, assign, readwrite)NSInteger currentIndex;
@property(nonatomic, assign, readwrite)NSInteger photoCount;

@property(nonatomic, strong)NSMutableSet * photoViewPools;

@property(nonatomic, strong)UIView * topBar;

@property(nonatomic, strong)UIView * bottomBar;

@property(nonatomic, strong)UIPanGestureRecognizer * panGestureRecognizer;
@property(nonatomic, strong)UILongPressGestureRecognizer *longPressGestureRecognizer;

//手势识别方向
@property (nonatomic, assign) TTPhotoScrollViewMoveDirection direction;
//进入的设备方向，如果与点击退出不同，则使用渐隐动画
@property (nonatomic, assign) UIInterfaceOrientation enterOrientation;

//交互式推动退出所需的属性
@property (nonatomic, strong) TTImagePreviewAnimateManager *animateManager;
@property (nonatomic, copy) NSArray<NSValue *> *animateFrames;
@property (nonatomic, copy) NSString *locationStr;
@end

@implementation FHDetailPictureViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _startWithIndex = 0;
        _currentIndex = -1;
        _photoCount = 0;
        _longPressToSave = YES;
        
        self.ttHideNavigationBar = YES;

        _addedToContainer = NO;
        
        self.photoViewPools = [[NSMutableSet alloc] initWithCapacity:5];
        
        self.ttDisableDragBack = YES;
        
        _isRotating = NO;
        
        _whiteMaskViewEnable = YES;

        _statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        _lastStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [self setCurrentStatusStyle];
    }
    return self;
}

- (void)dealloc
{
    [self resetStatusStyle];
    @try {
        [self removeObserver:self forKeyPath:@"self.view.frame"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)setCurrentStatusStyle {
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)resetStatusStyle {
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:_lastStatusBarStyle];
}

#pragma mark - View Life Cycle
- (void)loadView
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.view = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addObserver:self forKeyPath:@"self.view.frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCurrentStatusStyle];
    
    // 修复iOS7下，photoScrollView 子视图初始化位置不正确的问题
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // self.view
    self.view.backgroundColor = [UIColor clearColor];
    _containerView = [[UIView alloc] initWithFrame:self.view.frame];
    _containerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_containerView];
    
    // photoScrollView
    _photoScrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
    _photoScrollView.delegate = self;
    
    _photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.showsHorizontalScrollIndicator = YES;
    
    [self.view addSubview:_photoScrollView];
    
    _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.width, kFHDPTopBarHeight)];
    _topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topBar];
    
    // layout
    NSInteger maxIndex = MAX(MAX([_imageInfosModels count], [_imageURLs count]), MAX([_images count], [_assetsImages count]))-1;
    _startWithIndex = MAX(0, MIN(maxIndex, _startWithIndex));
    [self setPhotoScrollViewContentSize];
    
    [self setCurrentIndex:_startWithIndex];
    [self scrollToIndex:_startWithIndex];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    self.longPressGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_longPressGestureRecognizer];
    
    if ([TTImagePreviewAnimateManager interativeExitEnable]){
        self.animateManager.panDelegate = self;
        [_animateManager registeredPanBackWithGestureView:self.view];
        [self frameTransform];
    }
}

- (void)closeBtnClick
{
    [self finished];
}

- (void)stayCallBack:(NSInteger)stayTime
{
    if (self.albumImageStayBlock) {
        self.albumImageStayBlock(self.currentIndex,stayTime);
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        [self refreshUI];
    }
    CGFloat topInset = 0;
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    self.bottomBar.frame = CGRectMake(0, self.view.height - kFHDPBottomBarHeight - bottomInset, self.view.width, kFHDPBottomBarHeight);
    self.topBar.frame = CGRectMake(0, topInset, self.view.width, kFHDPTopBarHeight);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCurrentStatusStyle];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
   
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    _photoScrollView.delegate = nil;
    _isRotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    _photoScrollView.delegate = self;
    _isRotating = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.view.frame"]) {
        [self refreshUI];
    }
}

- (void)refreshUI
{
    self.containerView.frame = self.view.frame;
    _photoScrollView.frame = [self frameForPagingScrollView];
    [self setPhotoScrollViewContentSize];
    
    for (UIView * view in [_photoScrollView subviews]) {
        if ([view isKindOfClass:[TTShowImageView class]]) {
            TTShowImageView * v = (TTShowImageView *)view;
            v.frame = [self frameForPageAtIndex:v.tag];
            [v resetZoom];
            [v refreshUI];
        }
    }
    
    [self scrollToIndex:_currentIndex];
}


#pragma mark - Setter & Getter

- (void)setMediaHeaderModel:(FHDetailMediaHeaderModel *)mediaHeaderModel {
    if (_mediaHeaderModel != mediaHeaderModel) {
        _mediaHeaderModel = mediaHeaderModel;
        
    }
}

- (void)setImageURLs:(NSArray *)imageURLs
{
    if (_imageURLs != imageURLs) {
        _imageURLs = imageURLs;
        
        if (_imageURLs) {
            self.imageInfosModels = nil;
            self.images = nil;
            self.assetsImages = nil;
            self.multipleTypeImages = nil;
            _photoCount = [_imageURLs count];
        }
    }
}

- (void)setImageInfosModels:(NSArray *)imageInfosModels
{
    if (_imageInfosModels != imageInfosModels) {
        _imageInfosModels = imageInfosModels;
        
        if (_imageInfosModels) {
            self.imageURLs = nil;
            self.images = nil;
            self.assetsImages = nil;
            self.multipleTypeImages = nil;
            _photoCount = [_imageInfosModels count];
        }
    }
}

- (void)setImages:(NSArray *)images
{
    if (_images != images)
    {
        _images = images;
        
        if (_images)
        {
            self.imageURLs = nil;
            self.imageInfosModels = nil;
            self.assetsImages = nil;
            self.multipleTypeImages = nil;
            _photoCount = [_images count];
        }
    }
}

- (void)setAssetsImages:(NSArray *)assetsImages
{
    if (_assetsImages != assetsImages)
    {
        _assetsImages = assetsImages;
        
        if (_assetsImages)
        {
            self.imageURLs = nil;
            self.imageInfosModels = nil;
            self.images = nil;
            self.multipleTypeImages = nil;
            _photoCount = [assetsImages count];
        }
    }
}

- (void)setMultipleTypeImages:(NSArray *)multipleTypeImages
{
    if (_multipleTypeImages != multipleTypeImages)
    {
        _multipleTypeImages = multipleTypeImages;
        
        if (_multipleTypeImages)
        {
            self.imageURLs = nil;
            self.imageInfosModels = nil;
            self.images = nil;
            self.assetsImages = nil;
            _photoCount = [_multipleTypeImages count];
        }
    }
}

- (TTImagePreviewAnimateManager *)animateManager{
    if (_animateManager == nil){
        _animateManager = [[TTImagePreviewAnimateManager alloc] init];
        _animateManager.whiteMaskViewEnable = _whiteMaskViewEnable;
    }
    return _animateManager;
}

- (void)setWhiteMaskViewEnable:(BOOL)whiteMaskViewEnable{
    _whiteMaskViewEnable = whiteMaskViewEnable;
    _animateManager.whiteMaskViewEnable = whiteMaskViewEnable;
}

- (BOOL)newGestureEnable
{
    if (![TTImagePreviewAnimateManager interativeExitEnable]){
        return NO;
    }
    CGRect origionViewFrame = [self ttPreviewPanBackGetOriginView].frame;
    if (CGRectGetHeight(origionViewFrame) == 0 || CGRectGetWidth(origionViewFrame) == 0){
        return NO;
    }
    
    return [self showImageViewAtIndex:_currentIndex].currentImageView.image != nil;
}

#pragma mark - Public

static BOOL kFHStaticPhotoBrowserAtTop = NO;
+ (BOOL)photoBrowserAtTop
{
    return kFHStaticPhotoBrowserAtTop;
}

#pragma mark - Private

- (void)frameTransform{
    UIView *targetView = [self ttPreviewPanBackGetBackMaskView];
    if (nil == targetView){
        return;
    }
    NSMutableArray *mutArray = [NSMutableArray array];
    for (NSValue *frameValue in self.placeholderSourceViewFrames){
        if ([frameValue isKindOfClass:[NSNull class]]){
            [mutArray addObject:[NSValue valueWithCGRect:CGRectZero]];
            continue;
        }
        CGRect frame = frameValue.CGRectValue;
        if (CGRectEqualToRect(frame, CGRectZero)){
            [mutArray addObject:frameValue];
            continue;
        }
        CGRect animateFrame = [targetView convertRect:frame fromView:nil];
        [mutArray addObject:[NSValue valueWithCGRect:animateFrame]];
    }
    _animateFrames = [mutArray copy];
}

- (void)setPlaceholderSourceViewFrames:(NSArray *)placeholderSourceViewFrames {
    _placeholderSourceViewFrames = placeholderSourceViewFrames;
    if ([TTImagePreviewAnimateManager interativeExitEnable]){
        [self frameTransform];
    }
}

- (CGRect)frameForPagingScrollView
{
    return self.view.bounds;
}

- (void)setPhotoScrollViewContentSize
{
    NSInteger pageCount = _photoCount;
    if (pageCount == 0) {
        pageCount = 1;
    }
    
    CGSize size = CGSizeMake(_photoScrollView.frame.size.width * pageCount, _photoScrollView.frame.size.height);
    [_photoScrollView setContentSize:size];
}

- (CGRect)frameForPageAtIndex:(NSInteger)index
{
    CGRect pageFrame = _photoScrollView.bounds;
    pageFrame.origin.x = (index * pageFrame.size.width);
    return pageFrame;
}

- (void)setCurrentIndex:(NSInteger)newIndex
{
    if (_currentIndex == newIndex || newIndex < 0) {
        return;
    }
    
    _currentIndex = newIndex;
    
    [self unloadPhoto:_currentIndex + 2];
    [self unloadPhoto:_currentIndex - 2];
    
    [self loadPhoto:_currentIndex visible:YES];
    [[self showImageViewAtIndex:_currentIndex] restartGifIfNeeded];
    [self loadPhoto:_currentIndex + 1 visible:NO];
    [self loadPhoto:_currentIndex - 1 visible:NO];
}

- (void)scrollToIndex:(NSInteger)index
{
    [_photoScrollView setContentOffset:CGPointMake((CGRectGetWidth(_photoScrollView.frame) * index), 0)
                              animated:NO];
}

- (void)setUpShowImageView:(TTShowImageView *)showImageView atIndex:(NSUInteger)index
{
    showImageView.tag = index;
    showImageView.gifRepeatIfHave = YES;
    [showImageView resetZoom];
    
    if ([_placeholders count] > index && [[_placeholders objectAtIndex:index] isKindOfClass:[UIImage class]]) {
        showImageView.placeholderImage = [_placeholders objectAtIndex:index];
    } else {
        showImageView.placeholderImage = nil;
    }
    
    if ([_placeholderSourceViewFrames count] > index && [_placeholderSourceViewFrames objectAtIndex:index] != [NSNull null]) {
        showImageView.placeholderSourceViewFrame = [[_placeholderSourceViewFrames objectAtIndex:index] CGRectValue];
    } else {
        showImageView.placeholderSourceViewFrame = CGRectZero;
    }
    
    if ([_imageInfosModels count] > index) {
        [showImageView setImageInfosModel:[_imageInfosModels objectAtIndex:index]];
    }
    else if ([_imageURLs count] > index) {
        [showImageView setLargeImageURLString:[_imageURLs objectAtIndex:index]];
    }
    else if ([_images count] > index) {
        [showImageView setImage:[_images objectAtIndex:index]];
    }
    else if ([_assetsImages count] > index) {
        id assetImage = [_assetsImages objectAtIndex:index];
        if ([assetImage isKindOfClass:[ALAsset class]]) {
            [showImageView setAsset:assetImage];
        } else if ([assetImage isKindOfClass:[UIImage class]]) {
            [showImageView setImage:assetImage];
        }
    }
    else if ([_multipleTypeImages count] > index) {
        
        id multipleTypeImage = [_multipleTypeImages objectAtIndex:index];
        
        if ([multipleTypeImage isKindOfClass:[ALAsset class]]) {
            [showImageView setAsset:multipleTypeImage];
        } else if ([multipleTypeImage isKindOfClass:[UIImage class]]) {
            [showImageView setImage:multipleTypeImage];
        }
        else if ([multipleTypeImage isKindOfClass:[NSURL class]]) {
            
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:multipleTypeImage resultBlock:^(ALAsset *asset) {
                [showImageView setImage:[ALAssetsLibrary tt_getBigImageFromAsset:asset]];
            } failureBlock:^(NSError *error) {
                [showImageView setLargeImageURLString:multipleTypeImage];
            }];
        }
        else if ([multipleTypeImage isKindOfClass:[NSString class]]) {
            [showImageView setLargeImageURLString:multipleTypeImage];
        }
        else if ([multipleTypeImage isKindOfClass:[TTImageInfosModel class]]) {
            [showImageView setImageInfosModel:multipleTypeImage];
        }
    }
}

- (void)loadPhoto:(NSInteger)index visible:(BOOL)visible
{
    if (index < 0 || index >= _photoCount) {
        return;
    }
    
    if ([self isPhotoViewExistInScrollViewForIndex:index]) {
        [[self showImageViewAtIndex:index] setVisible:visible];
        return;
    }
    
    TTShowImageView * showImageView = [_photoViewPools anyObject];
    
    if (showImageView == nil) {
        showImageView = [[TTShowImageView alloc] initWithFrame:[self frameForPageAtIndex:index]];
        showImageView.backgroundColor = [UIColor clearColor];
        showImageView.delegate = self;
    }
    else {
        [_photoViewPools removeObject:showImageView];
    }
    showImageView.frame = [self frameForPageAtIndex:index];
    
    showImageView.loadingCompletedAnimationBlock = nil;
    [self setUpShowImageView:showImageView atIndex:index];
    showImageView.visible = visible;
    
    [_photoScrollView addSubview:showImageView];
}

- (BOOL)isPhotoViewExistInScrollViewForIndex:(NSInteger)index
{
    BOOL exist = NO;
    for (UIView * subView in [_photoScrollView subviews]) {
        if ([subView isKindOfClass:[TTShowImageView class]] && subView.tag == index) {
            exist = YES;
        }
    }
    return exist;
}

- (TTShowImageView *)showImageViewAtIndex:(NSInteger)index
{
    if (index < 0 || index >= _photoCount) {
        return nil;
    }
    
    for (UIView * subView in [_photoScrollView subviews]) {
        if ([subView isKindOfClass:[TTShowImageView class]] && subView.tag == index) {
            return (TTShowImageView *)subView;
        }
    }
    
    return nil;
}

- (void)unloadPhoto:(NSInteger)index
{
    if (index < 0 || index >= _photoCount) {
        return;
    }
    
    for (UIView * subView in [_photoScrollView subviews]) {
        if ([subView isKindOfClass:[TTShowImageView class]] && subView.tag == index) {
            [_photoViewPools addObject:subView];
            [subView removeFromSuperview];
        }
    }
}

- (void)finished
{
    if (_dismissBlock) {
        _dismissBlock();
    }
    if (_addedToContainer) {
        [self dismissSelf];
        _addedToContainer = NO;
    } else {
        [self dismissAnimated:NO];
    }
}

- (void)backButtonClicked
{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated
{
    if (alreadyFinished) {
        return;
    }
    
    if(self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:animated];
    }
    else
    {
        [self dismissViewControllerAnimated:animated completion:NULL];
    }
    kFHStaticPhotoBrowserAtTop = NO;
    alreadyFinished = YES;
}

#pragma mark - UIScrollViewDelegate
//When you flick quickly and continuously, scrollViewDidEndDecelerating method will not receive any message,which means not be called, while scrollViewDidEndDragging:willDecelerate still receive the message. because the dragging is so quick that the previous decelerating be ignored.
//From: http://stackoverflow.com/questions/12002853/how-to-determine-if-uiscrollview-flicks-to-next-page-when-paging

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    
    float fractionalPage = (scrollView.contentOffset.x + pageWidth / 2) / pageWidth;
    
    NSInteger page = floor(fractionalPage);
    if (page != _currentIndex) {
        if (self.indexUpdatedBlock) {
            self.indexUpdatedBlock(_currentIndex, page);
        }
        [self setCurrentIndex:page];
    }
}

#pragma mark - TTShowImageViewDelegate

- (void)showImageViewOnceTap:(TTShowImageView *)imageView
{
    [self finished];
}

#pragma mark -- rotate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    BOOL result = NO;
    if([TTDeviceHelper isPadDevice])
    {
        result = YES;
    }
    else
    {
        result = interfaceOrientation == UIInterfaceOrientationPortrait;
    }
    
    return result;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (![TTDeviceHelper isPadDevice]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)saveButtonClicked:(id)sender
{
    TTShowImageView * currentImageView = [self showImageViewAtIndex:_currentIndex];
    [currentImageView saveImage];
    if(self.saveImageBlock){
        self.saveImageBlock(self.currentIndex);
    }
}


- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    if (_dragToCloseDisabled || self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        return;
    }
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    CGPoint velocity = [recognizer velocityInView:recognizer.view.superview];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            [self refreshPhotoViewFrame:translation velocity:velocity];
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

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (!_longPressToSave || self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self saveButtonClicked:nil];
            break;
        default:
            break;
    }
}

#pragma mark - Pan close gesture
//整体的动画
- (void)refreshPhotoViewFrame:(CGPoint)translation velocity:(CGPoint)velocity
{
    if (self.direction == TTPhotoScrollViewMoveDirectionNone) {
        //刚开始识别方向
        if (translation.y > kFHDPMoveDirectionStartOffset) {
            self.direction = TTPhotoScrollViewMoveDirectionVerticalBottom;
        }
        if (translation.y < -kFHDPMoveDirectionStartOffset) {
            self.direction = TTPhotoScrollViewMoveDirectionVerticalTop;
        }
    } else {
        //重新识别方向
        TTPhotoScrollViewMoveDirection currentDirection = TTPhotoScrollViewMoveDirectionNone;
        if (translation.y > kFHDPMoveDirectionStartOffset) {
            currentDirection = TTPhotoScrollViewMoveDirectionVerticalBottom;
        } else if (translation.y < -kFHDPMoveDirectionStartOffset) {
            currentDirection = TTPhotoScrollViewMoveDirectionVerticalTop;
        } else {
            currentDirection = TTPhotoScrollViewMoveDirectionNone;
        }
        
        if (currentDirection == TTPhotoScrollViewMoveDirectionNone) {
            self.direction = currentDirection;
            return; //忽略其他手势
        }
        
        BOOL verticle = (self.direction == TTPhotoScrollViewMoveDirectionVerticalBottom || self.direction == TTPhotoScrollViewMoveDirectionVerticalTop);
        CGFloat y = 0;
        if (self.direction == TTPhotoScrollViewMoveDirectionVerticalTop) {
            y = translation.y + kFHDPMoveDirectionStartOffset;
        } else if (self.direction == TTPhotoScrollViewMoveDirectionVerticalBottom){
            y = translation.y - kFHDPMoveDirectionStartOffset;
        }
        
        CGFloat yFraction = fabs(translation.y / CGRectGetHeight(self.photoScrollView.frame));
        yFraction = fminf(fmaxf(yFraction, 0.0), 1.0);
        
        //距离判断+速度判断
        if (verticle) {
            if (yFraction > 0.2) {
                _reachDismissCondition = YES;
            } else {
                _reachDismissCondition  = NO;
            }
            
            if (velocity.y > 1500) {
                _reachDismissCondition = YES;
            }
        }
        
        CGRect frame = CGRectMake(0, y, CGRectGetWidth(self.photoScrollView.frame), CGRectGetHeight(self.photoScrollView.frame));
        self.photoScrollView.frame = frame;
        
        //下拉动画
        if (verticle) {
            _reachDragCondition = YES;
            [self addAnimatedViewToContainerView:yFraction];
        }
        
    }
    
}

//释放的动画
- (void)animatePhotoViewWhenGestureEnd
{
    TTShowImageView *imageView = [self showImageViewAtIndex:_currentIndex];
    if (!_reachDragCondition) {
        imageView.hidden = NO;
        return; //未曾满足过一次识别手势，不触发动画
    } else {
        _reachDragCondition = NO;
    }
    
    CGRect endRect = [self frameForPagingScrollView];
    CGFloat opacity = 1;
    
    if (_reachDismissCondition) {
        if (self.direction == TTPhotoScrollViewMoveDirectionVerticalBottom)
        {
            endRect.origin.y += CGRectGetHeight(self.photoScrollView.frame);
        } else if (self.direction == TTPhotoScrollViewMoveDirectionVerticalTop) {
            endRect.origin.y -= CGRectGetHeight(self.photoScrollView.frame);
        }
        opacity = 0;
    }else{
        imageView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.photoScrollView.frame = endRect;
        [self addAnimatedViewToContainerView: 1 - opacity];
    } completion:^(BOOL finished) {
        self.direction = TTPhotoScrollViewMoveDirectionNone;
        if (_reachDismissCondition) {
            [self finished];
        } else {
            [self removeAnimatedViewToContainerView];
        }
    }];
}

//添加顶部和底部的动画
- (void)addAnimatedViewToContainerView:(CGFloat)yFraction
{
    [self resetStatusStyle];
    self.containerView.alpha = (1 - yFraction * 2 / 3);
    [UIView animateWithDuration:0.15 animations:^{
//        self.indexPromptLabel.alpha = 0;
    }];
}

//移除顶部和底部的动画
- (void)removeAnimatedViewToContainerView
{
    self.photoScrollView.frame = [self frameForPagingScrollView];
    self.containerView.alpha = 1;
    [UIView animateWithDuration:0.15 animations:^{
//        self.indexPromptLabel.alpha = 1;
        [self setCurrentStatusStyle];
    }];
}

#pragma mark - Present View

- (void)presentPhotoScrollView
{
    [self presentPhotoScrollViewWithDismissBlock:nil];
}

- (void)presentPhotoScrollViewWithDismissBlock:(TTPhotoScrollViewDismissBlock)block
{
    kFHStaticPhotoBrowserAtTop = YES;
    
    [self setCurrentStatusStyle];
    
    _enterOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.dismissBlock = block;
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    [rootViewController addChildViewController:self];
    
    self.view.alpha = 0;
    _addedToContainer = YES;
    
    TTShowImageView * startShowImageView = [self showImageViewAtIndex:_startWithIndex];
    if (!startShowImageView.isDownloading && self.placeholderSourceViewFrames.count > _startWithIndex && [self.placeholderSourceViewFrames objectAtIndex:_startWithIndex] != [NSNull null]) {
        
        __weak TTShowImageView * weakShowImageView = startShowImageView;
        __weak TTPhotoScrollViewController * weakSelf = self;
        
        startShowImageView.loadingCompletedAnimationBlock = ^() {
            
            UIImageView * largeImageView = [weakShowImageView displayImageView];
            CGRect endFrame = largeImageView.frame;
            
            // [largeImageView.superview convertRect:endFrame toView:nil];
            // 全屏展示，无需转换 (由于navigation bar的存在，转换后的y可能差一个navigation bar的高度)
            CGRect transEndFrame = endFrame;
            
            CGRect beginFrame = [[_placeholderSourceViewFrames objectAtIndex:_startWithIndex] CGRectValue];
            largeImageView.frame = beginFrame;
            
            UIView *containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
            containerView.backgroundColor = [UIColor clearColor];
            
            UIView *originalSupperView = largeImageView.superview;
            [containerView addSubview:largeImageView];
            [rootViewController.view addSubview:self.view]; //图片放大动画情况下，先加入view再加入遮罩
            [rootViewController.view addSubview:containerView];
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            [UIView animateWithDuration:.3f animations:^{
                containerView.backgroundColor = [UIColor blackColor];
                largeImageView.frame = transEndFrame;
            } completion:^(BOOL finished) {
                largeImageView.frame = endFrame;
                [originalSupperView addSubview:largeImageView];
                [containerView removeFromSuperview];
                
                weakSelf.view.alpha = 1;
                weakShowImageView.loadingCompletedAnimationBlock = nil;
                [weakShowImageView showGifIfNeeded];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
        };
        
    } else {
        UIView *containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [rootViewController.view addSubview:containerView];
        [rootViewController.view addSubview:self.view];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [UIView animateWithDuration:.3f animations:^{
            self.view.alpha = 1; //本地加载图片，淡入动画
            containerView.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [containerView removeFromSuperview];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
}

- (void)dismissSelf
{
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
    //下拉关闭
    if (_reachDismissCondition) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [UIView animateWithDuration:.25f animations:^{
            self.view.layer.opacity = 0.0f;
        } completion:^(BOOL finished) {
            kFHStaticPhotoBrowserAtTop = NO;
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    } else {
        if (self.placeholderSourceViewFrames.count > _currentIndex && [self.placeholderSourceViewFrames objectAtIndex:_currentIndex] != [NSNull null]) {
            // 如果显示图片前后的设备方向不同，直接渐隐动画
            UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            if ((UIInterfaceOrientationIsPortrait(_enterOrientation) && UIInterfaceOrientationIsLandscape(currentOrientation))
                || (UIInterfaceOrientationIsLandscape(_enterOrientation) && UIInterfaceOrientationIsPortrait(currentOrientation))) {
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                
                [UIView animateWithDuration:.35f animations:^{
                    self.view.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    kFHStaticPhotoBrowserAtTop = NO;
                    [self.view removeFromSuperview];
                    [self removeFromParentViewController];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }];
                return;
            }
            
            TTShowImageView * showImageView = [self showImageViewAtIndex:_currentIndex];
            UIImageView * largeImageView = [showImageView displayImageView];
            CGRect endFrame = [[_placeholderSourceViewFrames objectAtIndex:_currentIndex] CGRectValue];
            largeImageView.hidden = NO;
            CGRect beginFrame = largeImageView.frame;
            
            //largeImageView可能被放大了，因此需要转换
            CGRect transBeginFrame = [largeImageView.superview convertRect:beginFrame toView:nil];
            
            //[showImageView hideGifIfNeeded];
            largeImageView.frame = transBeginFrame;
            
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (rootViewController.presentedViewController) {
                rootViewController = rootViewController.presentedViewController;
            }
            UIView * containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
            containerView.backgroundColor = [UIColor blackColor];
            [rootViewController.view addSubview:containerView];
            
            //如果有提供dismissInsets来控制放大图片动画的边距
            if (!UIEdgeInsetsEqualToEdgeInsets(self.dismissMaskInsets, UIEdgeInsetsZero)) {
                CGRect adjustedRect = UIEdgeInsetsInsetRect(containerView.frame, self.dismissMaskInsets);
                BOOL isContains = CGRectContainsRect(adjustedRect, endFrame);
                // 当减去insets后不包含原图的frame时，添加遮罩
                if (!isContains) {
                    UIView *maskView = [[UIView alloc] initWithFrame:containerView.frame];
                    CGRect maskRect = containerView.frame;
                    CGFloat width = containerView.frame.size.width;
                    CGFloat height = containerView.frame.size.height;
                    if (CGRectGetMinX(endFrame) < self.dismissMaskInsets.left) {
                        maskRect = UIEdgeInsetsInsetRect(maskRect, UIEdgeInsetsMake(0, self.dismissMaskInsets.left, 0, 0));
                    }
                    if (width - CGRectGetMaxX(endFrame) < self.dismissMaskInsets.right) {
                        maskRect = UIEdgeInsetsInsetRect(maskRect, UIEdgeInsetsMake(0, 0, 0, self.dismissMaskInsets.right));
                    }
                    if (CGRectGetMinY(endFrame) < self.dismissMaskInsets.top) {
                        maskRect = UIEdgeInsetsInsetRect(maskRect, UIEdgeInsetsMake(self.dismissMaskInsets.top, 0, 0, 0));
                    }
                    if (height - CGRectGetMaxY(endFrame) < self.dismissMaskInsets.bottom) {
                        maskRect = UIEdgeInsetsInsetRect(maskRect, UIEdgeInsetsMake(0, 0, self.dismissMaskInsets.bottom, 0));
                    }
                    
                    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
                    maskLayer.path = path;
                    CGPathRelease(path);
                    maskView.layer.mask = maskLayer;
                    maskView.backgroundColor = [UIColor clearColor];
                    
                    [containerView addSubview:maskView];
                    [maskView addSubview:largeImageView];
                } else {
                    [containerView addSubview:largeImageView];
                }
            } else {
                [containerView addSubview:largeImageView];
            }
            kFHStaticPhotoBrowserAtTop = NO;
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            [UIView animateWithDuration:.35f animations:^{
                containerView.backgroundColor = [UIColor clearColor];
                largeImageView.frame = endFrame;
            } completion:^(BOOL finished) {
                [containerView removeFromSuperview];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
            
        } else {
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            [UIView animateWithDuration:.35f animations:^{
                self.view.alpha = 0.0f;
            } completion:^(BOOL finished) {
                kFHStaticPhotoBrowserAtTop = NO;
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
        }
    }
}

#pragma TTPreviewPanBackDelegate

- (void)ttPreviewPanBackStateChange:(TTPreviewAnimateState)currentState scale:(float)scale{
    TTShowImageView *imageView = [self showImageViewAtIndex:_currentIndex];
    switch (currentState) {
        case TTPreviewAnimateStateWillBegin:
            [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                                    withAnimation:NO];
//            self.indexPromptLabel.alpha = 0;
            self.topBar.alpha = 0;
            self.bottomBar.alpha = 0;
            imageView.hidden = YES;
            break;
        case TTPreviewAnimateStateChange:
            self.containerView.alpha = MAX(0,(scale*14-13 - _animateManager.minScale)/(1 - _animateManager.minScale));
            if (self.containerView.alpha < 0.5) {
                [self resetStatusStyle];
            } else {
                [self setCurrentStatusStyle];
            }
            break;
        case TTPreviewAnimateStateDidFinish:
            _reachDismissCondition = YES;
            self.containerView.alpha = 0;
            [self resetStatusStyle];
            [self finished];
            [TTTracker ttTrackEventWithCustomKeys:@"slide_over" label:@"random_slide_close" value:nil source:nil extraDic:nil];
            break;
        case TTPreviewAnimateStateWillCancel:
            break;
        case TTPreviewAnimateStateDidCancel:
            [self setCurrentStatusStyle];
            self.containerView.alpha = 1;
//            self.indexPromptLabel.alpha = 1;
            self.topBar.alpha = 1;
            self.bottomBar.alpha = 1;
            imageView.hidden = NO;
        default:
            break;
    }
}

- (UIView *)ttPreviewPanBackGetOriginView{
    
    return [self showImageViewAtIndex:_currentIndex].currentImageView;
}

- (UIView *)ttPreviewPanBackGetBackMaskView{
    return _targetView ? _targetView : self.finishBackView;
};

- (CGRect)ttPreviewPanBackTargetViewFrame{
    if (_currentIndex >= self.animateFrames.count){
        return CGRectZero;
    }
    NSValue *frameValue = [self.animateFrames objectAtIndex:_currentIndex];
    
    return frameValue.CGRectValue;
}

- (UIView *)ttPreviewPanBackGetFinishBackgroundView{
    if (self.finishBackView == nil){
        self.finishBackView = [UIApplication sharedApplication].delegate.window;
        if (self.finishBackView == nil){
            self.finishBackView = [UIApplication sharedApplication].keyWindow;
        }
    }
    return self.finishBackView;
}

- (void)ttPreviewPanBackFinishAnimationCompletion{
    self.containerView.alpha = 0;
}

- (void)ttPreviewPanBackCancelAnimationCompletion{
    self.containerView.alpha = 1;
}

- (BOOL)ttPreviewPanGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return [self newGestureEnable];
}

#pragma UIGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.panGestureRecognizer){
        return ![self newGestureEnable];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
