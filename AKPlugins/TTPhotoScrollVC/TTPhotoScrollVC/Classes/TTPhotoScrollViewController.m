//
//  TTPhotoScrollViewController.m
//  Article
//
//  Created by Zhang Leonardo on 12-12-4.
//  Edited by Cao Hua from 13-10-12.
//

#import "TTPhotoScrollViewController.h"
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

#define indexPromptLabelTextSize 14.f
#define indexPromptLabelBottomPadding 5.f
#define indexPormptLabelLeftPadding 5.f
#define indexPormptLabelWidth 50.f
#define indexPormptLabelHeight 28.f

#define saveButtonTextSize 14.f
#define saveButtonBottomPadding 5.f
#define saveButtonRightPadding 5.f
#define saveButtonWidth 50.f
#define saveButtonHeight 28.f

#define topBarHeight 44.f
#define bottomBarHeight 40.f

#define moveDirectionStartOffset 20.f

//typedef void(^FinishCompletion)(void);

@interface TTPhotoScrollViewController ()<UIScrollViewDelegate, TTShowImageViewDelegate,TTPreviewPanBackDelegate,UIGestureRecognizerDelegate>
{
    BOOL alreadyFinished;// 防止多次点击回调造成多次popController
    BOOL _addedToContainer;
    BOOL _navBarHidden;
    BOOL _statusBarHidden;
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

@property(nonatomic, strong)UILabel * indexPromptLabel;
@property(nonatomic, strong)UIButton * closeButton;

// PhotosScrollViewSupportSelectMode
@property(nonatomic, strong)UIView * topBar;
@property(nonatomic, strong)UIButton * topBarLeftButton;
@property(nonatomic, strong)UIButton * topBarRightButton;

@property(nonatomic, strong)UIView * bottomBar;
@property(nonatomic, strong)UILabel * selectCountLabel;
@property(nonatomic, strong)UIButton * bottomBarRightButton;

@property(nonatomic, assign)NSUInteger selectCount;

//@property(nonatomic, copy)FinishCompletion finishCompletion;

@property(nonatomic, strong)UIButton * saveButton;

@property(nonatomic, strong)UIPanGestureRecognizer * panGestureRecognizer;

//统计extra
@property (nonatomic, strong) NSDictionary *trackerDic;
//手势识别方向
@property (nonatomic, assign) TTPhotoScrollViewMoveDirection direction;
//进入的设备方向，如果与点击退出不同，则使用渐隐动画
@property (nonatomic, assign) UIInterfaceOrientation enterOrientation;

//交互式推动退出所需的属性
@property (nonatomic, strong) TTImagePreviewAnimateManager *animateManager;
@property (nonatomic, copy) NSArray<NSValue *> *animateFrames;
@property (nonatomic, copy) NSString *locationStr;
@end

@implementation TTPhotoScrollViewController

#pragma mark - Init & Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _startWithIndex = 0;
        _currentIndex = -1;
        _photoCount = 0;
        _mode = PhotosScrollViewSupportDownloadMode;
        _autoSelectImageWhenClickDone = NO;
        
        
        self.ttHideNavigationBar = YES;
        
        _addedToContainer = NO;
        
        self.photoViewPools = [[NSMutableSet alloc] initWithCapacity:5];
        
        self.ttDisableDragBack = YES;
        
        _isRotating = NO;
        
        _whiteMaskViewEnable = YES;
    }
    return self;
}

- (instancetype)initWithTrackDictionary:(NSDictionary *)trackerDic
{
    self = [self init];
    
    if (self) {
        self.trackerDic = trackerDic;
    }
    
    return self;
}

- (void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:@"self.view.frame"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
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
    
    if (_mode != PhotosScrollViewSupportSelectMode)
    {
        // closeButon
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = _photoScrollView.bounds;
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_photoScrollView addSubview:_closeButton];
        
        // indexPromptLabel
        _indexPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(indexPormptLabelLeftPadding, self.view.height - indexPormptLabelHeight - indexPromptLabelBottomPadding, indexPormptLabelWidth, indexPormptLabelHeight)];
        _indexPromptLabel.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground9];
        [_indexPromptLabel setTextColor:[UIColor tt_defaultColorForKey:kColorBackground4]];
        [_indexPromptLabel setFont:[UIFont systemFontOfSize:indexPromptLabelTextSize]];
        _indexPromptLabel.layer.cornerRadius = 6.f;
        _indexPromptLabel.textAlignment = NSTextAlignmentCenter;
        _indexPromptLabel.clipsToBounds = YES;
        _indexPromptLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:_indexPromptLabel];
        
        // saveButton
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _saveButton.frame = CGRectMake(self.view.width - saveButtonRightPadding - saveButtonWidth, self.view.height - saveButtonHeight - saveButtonBottomPadding, saveButtonWidth, saveButtonHeight);
        _saveButton.hitTestEdgeInsets = UIEdgeInsetsMake((saveButtonHeight - 44) / 2, 0, (saveButtonHeight - 44) / 2, 0);
        _saveButton.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground9];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setTitle:@"保存" forState:UIControlStateHighlighted];
        [_saveButton setTitleColor:[UIColor tt_defaultColorForKey:kColorBackground4] forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor tt_defaultColorForKey:kColorBackground4Highlighted] forState:UIControlStateHighlighted];
        [_saveButton.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        _saveButton.layer.cornerRadius = 6.f;
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.view addSubview:_saveButton];
        if (self.mode == PhotosScrollViewSupportBrowse) {
            _saveButton.hidden = YES;
            _indexPromptLabel.centerX = self.view.width/2;
            _indexPromptLabel.autoresizingMask  = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        }
    }
    
    // layout
    NSInteger maxIndex = MAX(MAX([_imageInfosModels count], [_imageURLs count]), MAX([_images count], [_assetsImages count]))-1;
    _startWithIndex = MAX(0, MIN(maxIndex, _startWithIndex));
    [self setPhotoScrollViewContentSize];
    
    [self setCurrentIndex:_startWithIndex];
    [self scrollToIndex:_startWithIndex];
    
    if (_mode == PhotosScrollViewSupportSelectMode)
    {
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, topBarHeight)];
        _topBar.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground11];
        [self.view addSubview:_topBar];
        
        self.topBarLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topBarLeftButton setImage:[UIImage themedImageNamed:@"leftbackbutton_titlebar_photo_preview"] forState:UIControlStateNormal];
        [_topBarLeftButton setImage:[UIImage themedImageNamed:@"leftbackbutton_titlebar_photo_preview_press"] forState:UIControlStateHighlighted];
        _topBarLeftButton.backgroundColor = [UIColor clearColor];
        [_topBarLeftButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_topBarLeftButton sizeToFit];
        _topBarLeftButton.origin = CGPointMake( 0, ((_topBar.height) - (_topBarLeftButton.height)) / 2);
        [_topBar addSubview:_topBarLeftButton];
        
        self.topBarRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSAssert([_isSelecteds count] == MAX(MAX([_imageInfosModels count], [_imageURLs count]), MAX([_images count], [_assetsImages count])), @"error!");
        [self setSelectedAtIndex:_startWithIndex];
        [_topBarRightButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _topBarRightButton.backgroundColor = [UIColor clearColor];
        _topBarRightButton.origin = CGPointMake((_topBar.width) - (_topBarRightButton.width) - 15, ((_topBar.height) - (_topBarRightButton.height)) / 2);
        CGFloat width = _topBarRightButton.currentImage.size.width + 15.f * 2;
        _topBarRightButton.frame = CGRectMake((_topBar.width) - width, 0, width, (_topBar.height));
        [_topBar addSubview:_topBarRightButton];
        
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - bottomBarHeight, self.view.width, bottomBarHeight)];
        _bottomBar.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground11];
        [self.view addSubview:_bottomBar];
        
        NSUInteger selectCount = 0;
        _selectCount = NSUIntegerMax;
        for (id isSelected in _isSelecteds)
        {
            if ([isSelected boolValue]) {
                ++selectCount;
            }
        }
        NSAssert(selectCount <= _selectLimit, @"_selectLimit can not be less than selectCount");
        self.selectCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _selectCountLabel.font = [UIFont systemFontOfSize:16];
        _selectCountLabel.textColor = [UIColor tt_defaultColorForKey:kColorText3];
        self.selectCount = selectCount;
        [_selectCountLabel sizeToFit];
        _selectCountLabel.backgroundColor = [UIColor clearColor];
        _selectCountLabel.origin = CGPointMake(((_bottomBar.width) - (_selectCountLabel.width)) / 2, ((_bottomBar.height) - (_selectCountLabel.height)) / 2);
        [_bottomBar addSubview:_selectCountLabel];
        
        self.bottomBarRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomBarRightButton setTitle:@"完成" forState:UIControlStateNormal];
        [_bottomBarRightButton setTitle:@"完成" forState:UIControlStateHighlighted];
        [_bottomBarRightButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText4] forState:UIControlStateNormal];
        [_bottomBarRightButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText4Highlighted] forState:UIControlStateHighlighted];
        
        _bottomBarRightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_bottomBarRightButton addTarget:self action:@selector(selectDoneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBarRightButton sizeToFit];
        _bottomBarRightButton.origin = CGPointMake((_bottomBar.width) - (_bottomBarRightButton.width) - 15, ((_bottomBar.height) - (_bottomBarRightButton.height)) / 2);
        [_bottomBar addSubview:_bottomBarRightButton];
    }
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    if ([TTImagePreviewAnimateManager interativeExitEnable]){
        self.animateManager.panDelegate = self;
        [_animateManager registeredPanBackWithGestureView:self.view];
        [self frameTransform];
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
    self.bottomBar.frame = CGRectMake(0, self.view.height - bottomBarHeight - bottomInset, self.view.width, bottomBarHeight);
    self.topBar.frame = CGRectMake(0, topInset, self.view.width, topBarHeight);
    self.saveButton.frame = CGRectMake(self.view.width - saveButtonRightPadding - saveButtonWidth, self.view.height - saveButtonHeight - saveButtonBottomPadding - bottomInset, saveButtonWidth, saveButtonHeight);
    self.indexPromptLabel.frame = CGRectMake(indexPormptLabelLeftPadding, self.view.height - indexPormptLabelHeight - indexPromptLabelBottomPadding - bottomInset, indexPormptLabelWidth, indexPormptLabelHeight);
    if (self.mode == PhotosScrollViewSupportBrowse) {
        self.indexPromptLabel.centerX = self.view.width/2;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    [self refreshIndexPromptLabel];
}


#pragma mark - Setter & Getter

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

- (void)setSelectCount:(NSUInteger)selectCount
{
    if (_selectCount != selectCount && _selectCountLabel)
    {
        _selectCountLabel.text = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)selectCount, (unsigned long)_selectLimit];
        [_selectCountLabel sizeToFit];
        _selectCountLabel.origin = CGPointMake(((_bottomBar.width) - (_selectCountLabel.width)) / 2, ((_bottomBar.height) - (_selectCountLabel.height)) / 2);
    }
    
    _selectCount = selectCount;
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

static BOOL staticPhotoBrowserAtTop = NO;
+ (BOOL)photoBrowserAtTop
{
    return staticPhotoBrowserAtTop;
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

- (void)refreshIndexPromptLabel
{
    if (_indexPromptLabel.hidden)
    {
        return;
    }
    
    if (_currentIndex < 0 || _photoCount < 0) {
        _indexPromptLabel.hidden = YES;
        return;
    }
    else {
        _indexPromptLabel.hidden = NO;
    }
    
    NSString * text = [NSString stringWithFormat:@"%li/%li", (long)_currentIndex + 1, (long)_photoCount];
    [_indexPromptLabel setText:text];
    /*
     [_indexPromptLabel sizeToFit];
     CGRect frame = _indexPromptLabel.frame;
     frame.origin.x = indexPormptLabelLeftPadding;
     frame.origin.y = self.view.frame.size.height - frame.size.height - indexPromptLabelBottomPadding;
     _indexPromptLabel.frame = frame;*/
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
    
    [self refreshIndexPromptLabel];
    [self setSelectedAtIndex:_currentIndex];
    
    [self unloadPhoto:_currentIndex + 2];
    [self unloadPhoto:_currentIndex - 2];
    
    [self loadPhoto:_currentIndex visible:YES];
    [[self showImageViewAtIndex:_currentIndex] restartGifIfNeeded];
    [self loadPhoto:_currentIndex + 1 visible:NO];
    [self loadPhoto:_currentIndex - 1 visible:NO];
}

- (void)setSelectedAtIndex:(NSInteger)index
{
    if ([[_isSelecteds objectAtIndex:index] boolValue])
    {
        //        [_topBarRightButton setImage:[UIImage themedImageNamed:@"hookicon_photo_preview_press"] forState:UIControlStateNormal];
        //        [_topBarRightButton setImage:[UIImage themedImageNamed:@"hookicon_photo_preview_press"] forState:UIControlStateHighlighted];
        [_topBarRightButton setImage:[UIImage themedImageNamed:@"hookicon_photo_press"] forState:UIControlStateNormal];
        [_topBarRightButton setImage:[UIImage themedImageNamed:@"hookicon_photo_press"] forState:UIControlStateHighlighted];
    }
    else
    {
        //        [_topBarRightButton setImage:[UIImage themedImageNamed:@"hookicon_photo_preview"] forState:UIControlStateNormal];
        //        [_topBarRightButton setImage:[UIImage themedImageNamed:@"hookicon_photo_preview"] forState:UIControlStateHighlighted];
        [_topBarRightButton setImage:[UIImage themedImageNamed:@"hookicon_photo"] forState:UIControlStateNormal];
        [_topBarRightButton setImage:[UIImage themedImageNamed:@"hookicon_photo"] forState:UIControlStateHighlighted];
    }
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
    //[showImageView refreshUI];
    
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

- (void)closeButtonClicked
{
    [self finished];
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
    staticPhotoBrowserAtTop = NO;
    alreadyFinished = YES;
}

- (void)selectButtonClicked:(id)sender
{
    BOOL isSelected = [[_isSelecteds objectAtIndex:_currentIndex] boolValue];
    
    if (_selectCount >= _selectLimit && !isSelected)
    {
        return;
    }
    
    isSelected = !isSelected;
    [_isSelecteds replaceObjectAtIndex:_currentIndex withObject:@(isSelected)];
    
    [self setSelectedAtIndex:_currentIndex];
    
    self.selectCount = _selectCount + (isSelected ? 1 : -1);
}

- (void)selectDoneButtonClicked:(id)sender
{
    if (_autoSelectImageWhenClickDone && _selectCount == 0) {
        BOOL isSelected = [[_isSelecteds objectAtIndex:_currentIndex] boolValue];
        if (_selectCount < _selectLimit && !isSelected) {
            [self selectButtonClicked:nil];
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(TTPhotoScrollViewControllerDidFinishSelect:)])
    {
        [_delegate TTPhotoScrollViewControllerDidFinishSelect:self];
    }
}

#pragma mark - UIScrollViewDelegate
//When you flick quickly and continuously, scrollViewDidEndDecelerating method will not receive any message,which means not be called, while scrollViewDidEndDragging:willDecelerate still receive the message. because the dragging is so quick that the previous decelerating be ignored.
//From: http://stackoverflow.com/questions/12002853/how-to-determine-if-uiscrollview-flicks-to-next-page-when-paging

/*
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
 {
 if (_mode == PhotosScrollViewSupportSelectMode) {
 ssTrackEvent(self.umengEventName, @"flip");
 }
 
 CGFloat pageWidth = scrollView.frame.size.width;
 
 float fractionalPage = (scrollView.contentOffset.x + pageWidth / 2) / pageWidth;
 
 NSInteger page = floor(fractionalPage);
 if (page != _currentIndex) {
 [self setCurrentIndex:page];
 }
 }
 */

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_mode == PhotosScrollViewSupportSelectMode) {
        [TTTracker ttTrackEventWithCustomKeys:self.umengEventName label:@"flip" value:nil source:nil extraDic:self.trackerDic];
    }
    //统计
    else if (_mode == PhotosScrollViewSupportDownloadMode) {
        if (self.trackerDic) {
            [TTTracker ttTrackEventWithCustomKeys:self.umengEventName label:@"pic_slipe" value:nil source:nil extraDic:self.trackerDic];
        }
    }
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

#pragma mark - Pan close gesture
//整体的动画
- (void)refreshPhotoViewFrame:(CGPoint)translation velocity:(CGPoint)velocity
{
    if (self.direction == TTPhotoScrollViewMoveDirectionNone) {
        //刚开始识别方向
        if (translation.y > moveDirectionStartOffset) {
            self.direction = TTPhotoScrollViewMoveDirectionVerticalBottom;
        }
        if (translation.y < -moveDirectionStartOffset) {
            self.direction = TTPhotoScrollViewMoveDirectionVerticalTop;
        }
    } else {
        //重新识别方向
        TTPhotoScrollViewMoveDirection currentDirection = TTPhotoScrollViewMoveDirectionNone;
        if (translation.y > moveDirectionStartOffset) {
            currentDirection = TTPhotoScrollViewMoveDirectionVerticalBottom;
        } else if (translation.y < -moveDirectionStartOffset) {
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
            y = translation.y + moveDirectionStartOffset;
        } else if (self.direction == TTPhotoScrollViewMoveDirectionVerticalBottom){
            y = translation.y - moveDirectionStartOffset;
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
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
    self.containerView.alpha = (1 - yFraction * 2 / 3);
    [UIView animateWithDuration:0.15 animations:^{
        if (_mode != PhotosScrollViewSupportSelectMode) {
            self.saveButton.alpha = 0;
            self.indexPromptLabel.alpha = 0;
        } else {
            self.topBar.alpha = 0;
            self.bottomBar.alpha = 0;
        }
    }];
}

//移除顶部和底部的动画
- (void)removeAnimatedViewToContainerView
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:NO];
    self.photoScrollView.frame = [self frameForPagingScrollView];
    self.containerView.alpha = 1;
    [UIView animateWithDuration:0.15 animations:^{
        if (_mode != PhotosScrollViewSupportSelectMode) {
            self.saveButton.alpha = 1;
            self.indexPromptLabel.alpha = 1;
        } else {
            self.topBar.alpha = 1;
            self.bottomBar.alpha = 1;
        }
    }];
}

#pragma mark - Present View

- (void)presentPhotoScrollView
{
    [self presentPhotoScrollViewWithDismissBlock:nil];
}

- (void)presentPhotoScrollViewWithDismissBlock:(TTPhotoScrollViewDismissBlock)block
{
    staticPhotoBrowserAtTop = YES;
    //统计
    if (_mode == PhotosScrollViewSupportDownloadMode) {
        if (self.trackerDic) {
            [TTTracker ttTrackEventWithCustomKeys:self.umengEventName label:@"pic_click" value:nil source:nil extraDic:self.trackerDic];
        }
    }
    
    _statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
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
                
                [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                        withAnimation:NO];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
        };
        
    } else {
        
        UIView *containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [rootViewController.view addSubview:containerView];
        [rootViewController.view addSubview:self.view];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:NO];
        
        [UIView animateWithDuration:.3f animations:^{
            self.view.alpha = 1; //本地加载图片，淡入动画
            containerView.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [containerView removeFromSuperview];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
}

- (void)dismissSelf
{
    //统计
    if (_mode == PhotosScrollViewSupportDownloadMode) {
        if (self.trackerDic) {
            [TTTracker ttTrackEventWithCustomKeys:self.umengEventName label:@"pic_back" value:nil source:nil extraDic:self.trackerDic];
        }
    }
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
    //下拉关闭
    if (_reachDismissCondition) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [UIView animateWithDuration:.25f animations:^{
            self.view.layer.opacity = 0.0f;
        } completion:^(BOOL finished) {
            staticPhotoBrowserAtTop = NO;
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
                    staticPhotoBrowserAtTop = NO;
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
            staticPhotoBrowserAtTop = NO;
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
                staticPhotoBrowserAtTop = NO;
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
            self.saveButton.alpha = 0;
            self.indexPromptLabel.alpha = 0;
            self.topBar.alpha = 0;
            self.bottomBar.alpha = 0;
            imageView.hidden = YES;
            break;
        case TTPreviewAnimateStateChange:
            self.containerView.alpha = MAX(0,(scale*14-13 - _animateManager.minScale)/(1 - _animateManager.minScale));
            break;
        case TTPreviewAnimateStateDidFinish:
            _reachDismissCondition = YES;
            self.containerView.alpha = 0;
            [self finished];
            [TTTracker ttTrackEventWithCustomKeys:@"slide_over" label:@"random_slide_close" value:nil source:nil extraDic:nil];
            break;
        case TTPreviewAnimateStateWillCancel:
            [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                    withAnimation:NO];
            break;
        case TTPreviewAnimateStateDidCancel:
            self.containerView.alpha = 1;
            self.saveButton.alpha = 1;
            self.indexPromptLabel.alpha = 1;
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

@end

