//
//  SSPhotoScrollViewController.m
//  Article
//
//  Created by Zhang Leonardo on 12-12-4.
//
//

#import "SSPhotoScrollViewController.h"
#import "SSShowImageView.h"
#import "UIApplication+Addition.h"

#define indexPromptLabelTextSize 15.f
#define indexPromptLabelBottomPadding 20.f
#define indexPormptLabelLeftPadding 20.f

@interface SSPhotoScrollViewController ()<UIScrollViewDelegate, SSShowImageViewDelegate>
{
    BOOL alreadyFinished;// 防止多次点击回调造成多次popController
}

@property(nonatomic, retain)UIScrollView * photoScrollView;

@property(nonatomic, assign, readwrite)NSInteger currentIndex;
@property(nonatomic, assign, readwrite)NSInteger photoCount;

@property(nonatomic, retain)NSMutableSet * photoViewPools;

@property(nonatomic, retain)UILabel * indexPromptLabel;
@property(nonatomic, retain)UIButton * closeButton;

@end

@implementation SSPhotoScrollViewController

@synthesize photoScrollView = _photoScrollView;

@synthesize currentIndex = _currentIndex;
@synthesize startWithIndex = _startWithIndex;
@synthesize photoCount = _photoCount;

@synthesize imageURLs = _imageURLs;
//@synthesize imageURLWithHeaders = _imageURLWithHeaders;
@synthesize imageInfosModels = _imageInfosModels;

@synthesize photoViewPools = _photoViewPools;

@synthesize indexPromptLabel = _indexPromptLabel;

- (void)dealloc
{
    self.closeButton = nil;
    self.photoViewPools = nil;
    self.imageURLs = nil;
//    self.imageURLWithHeaders = nil;
    self.imageInfosModels = nil;
    self.photoScrollView = nil;
    self.indexPromptLabel = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _startWithIndex = 0;
        _currentIndex = -1;
        _photoCount = 0;
        
        self.photoViewPools = [[[NSMutableSet alloc] initWithCapacity:5] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    self.photoScrollView = [[[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]] autorelease];
    _photoScrollView.delegate = self;
    
    _photoScrollView.backgroundColor = [UIColor blackColor];
    _photoScrollView.autoresizesSubviews = YES;
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.showsHorizontalScrollIndicator = YES;
    
    [self.view addSubview:_photoScrollView];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = _photoScrollView.bounds;
    _closeButton.backgroundColor = [UIColor clearColor];
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_closeButton];
    [_photoScrollView addSubview:_closeButton];
    
    self.indexPromptLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    _indexPromptLabel.backgroundColor = [UIColor clearColor];
    [_indexPromptLabel setTextColor:[UIColor whiteColor]];
    [_indexPromptLabel setFont:[UIFont systemFontOfSize:indexPromptLabelTextSize]];
    [self.view addSubview:_indexPromptLabel];
    
    [self refreshIndexPromptLabel];
}



- (void)loadView
{
    
    self.view = [[[UIView alloc] initWithFrame:[self frameForControllerView]] autorelease];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setPhotoScrollViewContentSize];
    
    if (_startWithIndex >= MAX([_imageInfosModels count], [_imageURLs count]) ) {
        _startWithIndex = (MAX([_imageInfosModels count], [_imageURLs count]) - 1);
    }
    
    if (_startWithIndex < 0) {
        _startWithIndex = 0;
    }

    
    [self setCurrentIndex:_startWithIndex];
    [self scrollToIndex:_startWithIndex];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    int originIndex = _currentIndex;
    
    [self refreshUI:[UIApplication currentUIOrientation]];
    [self scrollToIndex:originIndex];
    [self refreshIndexPromptLabel];
}

- (void)refreshUI:(UIInterfaceOrientation)interfaceOrt
{
    self.view.frame = [self frameForControllerView];
    _photoScrollView.frame = [self frameForPagingScrollView];
    [self setPhotoScrollViewContentSize];
    
    for (UIView * view in [_photoScrollView subviews]) {
        if ([view isKindOfClass:[SSShowImageView class]]) {
            SSShowImageView * v = (SSShowImageView *)view;
            v.frame = [self frameForPageAtIndex:v.tag];
            [v refreshUI];
        }
    }
    [self scrollToIndex:_currentIndex];
}


#pragma mark -- setter & getter

- (void)setImageURLs:(NSArray *)imageURLs
{
    if (_imageURLs != imageURLs) {
        [imageURLs retain];
        [_imageURLs release];
        _imageURLs = imageURLs;
    }
    
    if (_imageURLs != nil) {
        self.imageInfosModels = nil;
        _photoCount = [_imageURLs count];
    }
}

- (void)setImageInfosModels:(NSArray *)imageInfosModels
{
    if (_imageInfosModels != imageInfosModels) {
        [imageInfosModels retain];
        [_imageInfosModels release];
        _imageInfosModels = imageInfosModels;
    }
    if (_imageInfosModels != nil) {
        self.imageURLs = nil;
        _photoCount = [_imageInfosModels count];
    }
}

#pragma mark -- private

- (CGRect)frameForControllerView
{
    CGSize sSize = screenSize();
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    float statusBarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);
    
    CGRect viewFrame = CGRectZero;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication currentUIOrientation])) {
        
//        viewFrame.origin.y = statusBarHeight;
        
        viewFrame.size.height = MAX(sSize.width, sSize.height) - statusBarHeight;
        
        viewFrame.size.width = MIN(sSize.width, sSize.height);
    }
    else {
        
        viewFrame.size.height = MIN(sSize.width, sSize.height) - statusBarHeight;
        viewFrame.size.width = MAX(sSize.width, sSize.height);
    }
    return viewFrame;
}

- (void)refreshIndexPromptLabel
{
    if (_currentIndex < 0 || _photoCount < 0) {
        _indexPromptLabel.hidden = YES;
        return;
    }
    else {
        _indexPromptLabel.hidden = NO;
    }
    
    NSString * text = [NSString stringWithFormat:@"%i/%i", _currentIndex + 1, _photoCount];
    [_indexPromptLabel setText:text];
    [_indexPromptLabel sizeToFit];
    CGRect frame = _indexPromptLabel.frame;
    frame.origin.x = indexPormptLabelLeftPadding;
    frame.origin.y = self.view.frame.size.height - frame.size.height - indexPromptLabelBottomPadding;
    _indexPromptLabel.frame = frame;
}

- (CGRect)frameForPagingScrollView
{
    CGRect frame = self.view.bounds;
    return frame;
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
    if (_currentIndex == newIndex) {
        return;
    }
    _currentIndex = newIndex;
    
    [self refreshIndexPromptLabel];
    
    [self loadPhoto:_currentIndex];
    [self loadPhoto:_currentIndex + 1];
    [self loadPhoto:_currentIndex - 1];
    [self unloadPhoto:_currentIndex + 2];
    [self unloadPhoto:_currentIndex - 2];
    

}



- (void)scrollToIndex:(NSInteger)index
{
    CGRect frame = _photoScrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    [_photoScrollView scrollRectToVisible:frame animated:NO];
}

- (void)loadPhoto:(NSInteger)index
{
    if (index < 0 || index >= _photoCount || [self isPhotoViewExistInScrollViewForIndex:index]) {
        return;
    }
    SSShowImageView * showImageView = [[_photoViewPools anyObject] retain];
    if (showImageView == nil) {
        showImageView = [[SSShowImageView alloc] initWithFrame:[self frameForPageAtIndex:index]];
        showImageView.delegate = self;
    }
    else {
        [_photoViewPools removeObject:showImageView];
    }
    showImageView.frame = [self frameForPageAtIndex:index];
    
    showImageView.tag = index;
    [showImageView resetZoom];
    
    if ([_imageInfosModels count] > index) {
        [showImageView setImageInfosModel:[_imageInfosModels objectAtIndex:index]];
    }
    else if ([_imageURLs count] > index) {
        [showImageView setLargeImageURLString:[_imageURLs objectAtIndex:index]];
    }
    
    [showImageView refreshUI];
    
    [_photoScrollView addSubview:showImageView];
    
    [showImageView release];
}

- (BOOL)isPhotoViewExistInScrollViewForIndex:(NSInteger)index
{
    BOOL exist = NO;
    for (UIView * subView in [_photoScrollView subviews]) {
        if ([subView isKindOfClass:[SSShowImageView class]] && subView.tag == index) {
            exist = YES;
        }
    }
    return exist;
}

- (void)unloadPhoto:(NSInteger)index
{
    if (index < 0 || index >= _photoCount) {
        return;
    }
    
    for (UIView * subView in [_photoScrollView subviews]) {
        if ([subView isKindOfClass:[SSShowImageView class]] && subView.tag == index) {
            [subView removeFromSuperview];
            [_photoViewPools addObject:subView];
        }
    }
}

- (void)closeButtonClicked
{
    [self finished];
}

- (void)finished
{
    if (alreadyFinished) {
        return;
    }
    [self.navigationController popViewControllerAnimated:NO];
    alreadyFinished = YES;
}


#pragma mark -- public


#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    
//    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    float fractionalPage = (scrollView.contentOffset.x + pageWidth / 2) / pageWidth;
    
    NSInteger page = floor(fractionalPage);
    if (page != _currentIndex) {
        [self setCurrentIndex:page];
    }
}

#pragma mark -- SSShowImageViewDelegate

- (void)showImageViewOnceTap:(SSShowImageView *)imageView
{
    [self finished];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    BOOL result = NO;
    if([SSCommon isPadDevice])
    {
        result = YES;
    }
    else
    {
        result = interfaceOrientation == UIInterfaceOrientationPortrait;
    }
    
    return result;
}

@end
