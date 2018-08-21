//
//  FullScreenImageView.m
//  Essay
//
//  Created by Zhang Leonardo on 12-3-11.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "FullScreenImageView.h"
#import "SSSimpleCache.h"
#import "MBProgressHUD.h"
#import "FreedomShowImageView.h"
#import "SSLazyImageView.h"


#define MIN_ZOOM_SCALE 1.0f
@interface FullScreenImageView()<UIScrollViewDelegate, FreedomShowImageViewDelegate, MBProgressHUDDelegate>
{
    UIButton * saveButton;
    MBProgressHUD * progressView;
    MBProgressHUD * savePrompt;
}

@property(nonatomic, retain)SSLazyImageView * middleImageView;
@property(nonatomic, retain)FreedomShowImageView * freedomShowImageView;

@end

@implementation FullScreenImageView
@synthesize middleImageView = _middleImageView;
@synthesize largeURL = _largeURL;
@synthesize middleURL = _middleURL;
@synthesize fullScreenImageViewDelegate;
@synthesize largeImageSize = _largeImageSize;
@synthesize largeURLAndHeaders = _largeURLAndHeaders;
@synthesize middleURLAndHeaders = _middleURLAndHeaders;
@synthesize freedomShowImageView = _freedomShowImageView;

- (void)dealloc
{
    self.middleImageView = nil;
    self.freedomShowImageView = nil;
    [savePrompt release];
    [progressView release];
    [saveButton release];
    self.largeURL = nil;
    self.middleURL = nil;
    self.largeURLAndHeaders = nil;
    self.middleURLAndHeaders = nil;
    [super dealloc];
}

- (id)initWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    self = [super init];
    if (self) {
        self.interfaceOrientation = orientation;
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        
        float largeSide = MAX(screenSize().width, screenSize().height);
        float shortSide = MIN(screenSize().width, screenSize().height);
        
        float width;
        float height;
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            width = shortSide;
            height = largeSide;
        }
        else {
            width = largeSide;
            height = shortSide;
        }
        
        self.frame = CGRectMake(0, 0, width, height);
        
        self.middleImageView = [[[SSLazyImageView alloc] initWithFrame:CGRectMake(0, 0, _largeImageSize.width, _largeImageSize.height)] autorelease];
        _middleImageView.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
        [self addSubview:_middleImageView];
        
        
        self.freedomShowImageView = [[[FreedomShowImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)] autorelease];
        _freedomShowImageView.freedomViewDelegate = self;
        [self addSubview:_freedomShowImageView];
        
        saveButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [saveButton setImage:[UIImage resourceImageNamed:@"downToPic.png"] forState:UIControlStateNormal];
        [saveButton setImage:[UIImage resourceImageNamed:@"downToPic_press.png"] forState:UIControlStateHighlighted];
        
        [saveButton sizeToFit];
        saveButton.frame = CGRectMake(width - saveButton.frame.size.width - 20, height - saveButton.frame.size.height - 20, saveButton.frame.size.width, saveButton.frame.size.height);
        
        [saveButton addTarget:self action:@selector(saveImgClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
        
        progressView = [[MBProgressHUD alloc] initWithView:self];
        progressView.mode = MBProgressHUDModeDeterminate;
        progressView.delegate = self;
        progressView.labelText = @"Loading";
        [self addSubview:progressView];
        
        savePrompt = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:savePrompt];
        
        [self setHidden:YES];
    }
    return self;
}

- (void)showImageAnimation
{
    if ([[SSSimpleCache sharedCache] quickCheckIsCacheExist:_largeURL] || [[SSSimpleCache sharedCache] quickCheckIsArrayCacheExist:_largeURLAndHeaders]) {
        [_freedomShowImageView setHidden:NO];
    }
    if ([_largeURLAndHeaders count] > 0) {
        [_freedomShowImageView setLazyImageURLAndHeaders:_largeURLAndHeaders andImageCGSize:_largeImageSize];
    }
    else {
        [_freedomShowImageView setLazyImageUrl:_largeURL andImageCGSize:_largeImageSize];
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (([_largeURL length] == 0 && [_largeURLAndHeaders count] == 0)/*|| CGSizeEqualToSize(_largeImageSize, CGSizeZero)*/) {
        SSLog(@" must set largeUrl or largeImgHeight or largeImgWidth");
        return;
    }
    
    [_freedomShowImageView setHidden:YES];

    if (hidden == NO) {
        [progressView hide:YES];
        [_freedomShowImageView resetViewParameter];
        self.backgroundColor = [UIColor blackColor];        
        self.alpha = 1.f;
        [self showImageAnimation];
    }
}

- (void)singleButtonClicked
{
    [_freedomShowImageView cancelImageDownload];
    if (fullScreenImageViewDelegate != nil) {
        if ([fullScreenImageViewDelegate respondsToSelector:@selector(fullScreenImageClickedOnce)]) {
            [fullScreenImageViewDelegate fullScreenImageClickedOnce];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self singleButtonClicked];
}

#pragma mark freedomView delegate
- (void)freedomViewOnceClicked
{
    [self singleButtonClicked];
}

- (void)freedomImageDownloadProgress:(float)progress
{
    progressView.progress = progress;
    if (progress >= 1) {
        [progressView hide:YES];
        [_freedomShowImageView setHidden:NO];
    }
    else if (progress > 0 && progress < 1) {

        [progressView show:NO];
    }
}


- (void)saveImgClick
{
    NSData * data = nil;
    if (data == nil && [_largeURLAndHeaders count] > 0) {
        for (int i = 0 ; i < [_largeURLAndHeaders count]; i ++) {
            data = [[SSSimpleCache sharedCache] dataForUrl:[[_largeURLAndHeaders objectAtIndex:i] objectForKey:@"url"]];
            if (data != nil) {
                break;
            }
        }
    }
    
    if (data == nil && [_largeURL length] > 0) {
        data = [[SSSimpleCache sharedCache] dataForUrl:_largeURL];
    }
    
    if (data == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"图片正在下载，请稍后再试"
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
        
        return;
    }
    else {
        savePrompt.labelText = @"图片存储中";
        [savePrompt show:NO];
        [savePrompt hide:NO afterDelay:2.f];
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
        
    }
    trackEvent([SSCommon appName], @"image", @"download");
}

#pragma mark -- setter & getter

- (void)setMiddleURL:(NSString *)middleURL
{
    if (middleURL != _middleURL) {
        [middleURL retain];
        [_middleURL release];
        _middleURL = middleURL;
    }
    
    if (middleURL != nil) {
        [_middleImageView setNetImageUrl:_middleURL];
    }
}

- (void)setMiddleURLAndHeaders:(NSArray *)middleURLAndHeaders
{
    if (middleURLAndHeaders != _middleURLAndHeaders) {
        [middleURLAndHeaders retain];
        [_middleURLAndHeaders release];
        _middleURLAndHeaders = middleURLAndHeaders;
    }
    
    if (_middleURLAndHeaders != nil) {
        [_middleImageView setNetImageURLAndHeaders:_middleURLAndHeaders];
    }
}

- (void)setLargeImageSize:(CGSize)largeImageSize
{
    _largeImageSize = largeImageSize;
    if (!CGSizeEqualToSize(largeImageSize, CGSizeZero)) {
        _middleImageView.frame = CGRectMake(0, 0, largeImageSize.width, largeImageSize.height);
        _middleImageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [_freedomShowImageView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self refreshUI];
    [_freedomShowImageView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)refreshUI
{
    float largeSide = MAX(screenSize().width, screenSize().height);
    float shortSide = MIN(screenSize().width, screenSize().height);
    
    float width;
    float height;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        width = shortSide;
        height = largeSide;
    }
    else {
        width = largeSide;
        height = shortSide;
    }
    
    self.frame = CGRectMake(0, 0, width, height);
    self.middleImageView.frame = CGRectMake(0, 0, _largeImageSize.width, _largeImageSize.height);
    _middleImageView.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
    
    self.freedomShowImageView.frame = CGRectMake(0, 0, width, height);
    
    saveButton.frame = CGRectMake(width - saveButton.frame.size.width - 20, height - saveButton.frame.size.height - 20, saveButton.frame.size.width, saveButton.frame.size.height);

}

@end
