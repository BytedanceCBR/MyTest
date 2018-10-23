//
//  EssayHDRecommendView.m
//  Essay
//
//  Created by 于天航 on 12-9-21.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "PadWebView.h"
#import "UIColorAdditions.h"
#import "SSTitleBarView.h"
//#import "UMTableViewCell.h"
#import "UIApplication+Addition.h"
#import "SSButton.h"

@interface PadWebView()<UIWebViewDelegate>{
    UIView *_mLoadingWaitView;
    UILabel *_mLoadingStatusLabel;
    UIImageView *_mNoNetworkImageView;
    UIActivityIndicatorView *_mLoadingActivityIndicator;
}

@property(nonatomic, retain)UIImageView * shadowView;
@property (nonatomic, retain, readwrite) UIButton *hdBackButton;
@property(nonatomic, retain)UIWebView *webView;

@end

@implementation PadWebView
@synthesize webView;

- (void)dealloc
{
    self.shadowView = nil;
    self.titleBar = nil;
    self.closeTarget = nil;
    self.closeSelector = nil;
    self.hdBackButton = nil;
    self.webView = nil;
    
    [_mLoadingStatusLabel release];
    _mLoadingStatusLabel = nil;
    [_mLoadingActivityIndicator release];
    _mLoadingActivityIndicator = nil;
    [_mNoNetworkImageView release];
    _mNoNetworkImageView = nil;
    [_mLoadingWaitView removeFromSuperview];
    [_mLoadingWaitView release];
    _mLoadingWaitView = nil;
    
    [super dealloc];
}

#pragma mark -- protect

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        CGRect vFrame = self.bounds;
        CGRect tmpFrame = vFrame;
        tmpFrame.size.height = EssayTitleBarHeight;
        
        self.backgroundColor = [UIColor colorWithHexString:SSUIString(@"uiCommentAndInputViewBGColor", @"ffffff")];
        
        UIImage *bgImage = [UIImage resourceImageNamed:@"titlebarbg.png"];
        
        self.titleBar = [[[SSTitleBarView alloc] initWithFrame:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)] autorelease];
        self.titleBar.portraitBackgroundView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
        [self addSubview:self.titleBar];
        
        UIButton *hdBackButton = [SSButton buttonWithSSButtonType:SSButtonTypeNormal];
        self.hdBackButton = hdBackButton;
        [hdBackButton setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"uiUniversalAppTitleButtonTitleColor")]
                           forState:UIControlStateNormal];
        
        [hdBackButton setTitle:ssLocalizedStringWithDefaultValue(@"HDCloseButtonTitle", @"关闭", nil) forState:UIControlStateNormal];
        [hdBackButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [hdBackButton sizeToFit];
        [_titleBar setRightView:hdBackButton];
        
        UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel setFont:[UIFont systemFontOfSize:(SSUIFloatNoDefault(@"uiUniversalAppTitleTextFontSize"))]];
        titleLabel.textColor = [UIColor colorWithHexString:SSUIString(@"SSTitleBarViewTitleLabelColor", @"#ffffff")];
        [titleLabel setShadowColor:[UIColor colorWithHexString:SSUIString(@"uiUniversalAppTitleShadowColor", @"#00000066")]];
        [titleLabel setShadowOffset:CGSizeMake(0.f, SSUIFloat(@"uiUniversalAppTitleShadowOffset", 0.f))];
        titleLabel.text = @"精彩应用推荐";
        [titleLabel sizeToFit];
        [_titleBar setCenterView:titleLabel];
        
        tmpFrame.origin.y = CGRectGetMaxY(_titleBar.frame);
        tmpFrame.size.height = vFrame.size.height - _titleBar.frame.size.height;
                
        self.webView = [[[UIWebView alloc] initWithFrame:tmpFrame] autorelease];
        webView.delegate = self;
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        [self addSubview:webView];
        
        //如果设置了tableview的dataLoadDelegate，请在viewController销毁时将tableview的dataLoadDelegate置空，这样可以避免一些可能的delegate问题，虽然我有在tableview的dealloc方法中将其置空
        
        _mLoadingWaitView = [[UIView alloc] initWithFrame:self.bounds];
        _mLoadingWaitView.backgroundColor = [UIColor lightGrayColor];
        _mLoadingWaitView.autoresizesSubviews = YES;
        _mLoadingWaitView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _mLoadingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width-300)/2, 210, 300, 21)];
        _mLoadingStatusLabel.backgroundColor = [UIColor clearColor];
        _mLoadingStatusLabel.textColor = [UIColor whiteColor];
        _mLoadingStatusLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
        _mLoadingStatusLabel.text = @"正在加载数据，请稍等...";
        _mLoadingStatusLabel.textAlignment = UITextAlignmentCenter;
        _mLoadingStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_mLoadingWaitView addSubview:_mLoadingStatusLabel];
        
        _mLoadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _mLoadingActivityIndicator.backgroundColor = [UIColor clearColor];
        _mLoadingActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _mLoadingActivityIndicator.frame = CGRectMake((self.bounds.size.width-30)/2, 170, 30, 30);
        [_mLoadingWaitView addSubview:_mLoadingActivityIndicator];
        
        [_mLoadingActivityIndicator startAnimating];
        
        [self insertSubview:_mLoadingWaitView aboveSubview:webView];
        
        self.shadowView = [[[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"listweb_bg_shadow_left.png"]] autorelease];
        _shadowView.frame = CGRectMake(-_shadowView.frame.size.width, 0, _shadowView.frame.size.width, _shadowView.frame.size.height);
        [self addSubview:_shadowView];
        [self refreshUI];
    }
    
    return self;
}

- (void)startLoadURL:(NSURL*)url
{
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    [webView loadRequest:request];
}

- (void)themeChanged:(NSNotification *)notification
{
    UIImage *portraitBackgroundImage = [UIImage resourceImageNamed:@"titlebarbg.png"];
    portraitBackgroundImage = [portraitBackgroundImage stretchableImageWithLeftCapWidth:portraitBackgroundImage.size.width/2
                                                                           topCapHeight:1.f];
    UIImageView *portraitBackgroundView = [[[UIImageView alloc] initWithImage:portraitBackgroundImage] autorelease];
    portraitBackgroundView.frame = self.bounds;
    _titleBar.portraitBackgroundView = portraitBackgroundView;
    
    UIImage *portraitBottomImage = [UIImage resourceImageNamed:@"titlebarbg_shadow.png"];
    portraitBottomImage = [portraitBottomImage stretchableImageWithLeftCapWidth:portraitBottomImage.size.width/2
                                                                   topCapHeight:1.f];
    UIImageView *portraitBottomView = [[[UIImageView alloc] initWithImage:portraitBottomImage] autorelease];
    portraitBottomView.frame = CGRectMake(0, 0, self.bounds.size.width, 10.f);
    _titleBar.portraitBottomView = portraitBottomView;
    
    _titleBar.titleLabel.textColor = [UIColor colorWithHexString:SSUIString(@"SSTitleBarViewTitleLabelColor", @"#ffffff")];
    [_titleBar.titleLabel setShadowColor:[UIColor colorWithHexString:SSUIString(@"uiUniversalAppTitleShadowColor", @"#00000066")]];
    [_titleBar.titleLabel setShadowOffset:CGSizeMake(0.f, SSUIFloat(@"uiUniversalAppTitleShadowOffset", 0.f))];
}

- (void)willAppear
{
    [super willAppear];
}

- (void)didAppear
{
    [super didAppear];
}

- (void)refreshUI
{
//    [super refreshUI];
    webView.frame = CGRectMake(0, _titleBar.frame.size.height, SSWidth(self), SSHeight(self) - _titleBar.frame.size.height);
    _shadowView.frame = CGRectMake(-_shadowView.frame.size.width, 0, _shadowView.frame.size.width, SSHeight(self));
}

#pragma mark - Actions

- (void)back:(id)sender
{
    if (_closeTarget && _closeSelector) {
        if ([_closeTarget respondsToSelector:_closeSelector]) {
            
            NSMethodSignature *signature = [_closeTarget methodSignatureForSelector:_closeSelector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:_closeTarget];
            [invocation setSelector:_closeSelector];
            [invocation invoke];
        }
    }
}

- (void)layoutSubviews
{
    [self trySSLayoutSubviews];
}

- (void)ssLayoutSubviews
{
    [self refreshUI];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeLoadingMaskView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadDataFailed];
}


#pragma mark - UMTableViewDataLoadDelegate methods

- (void)removeLoadingMaskView {
    
    if ([_mLoadingWaitView superview])
    {
        [_mLoadingWaitView removeFromSuperview];
    }
}

- (void)loadDataFailed {
    
    _mLoadingActivityIndicator.hidden = YES;
    
    if (!_mNoNetworkImageView)
    {
        UIImage *image = [UIImage imageNamed:@"um_no_network.png"];
        CGSize imageSize = image.size;
        _mNoNetworkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_mLoadingWaitView.bounds.size.width - imageSize.width) / 2, 80, imageSize.width, imageSize.height)];
        _mNoNetworkImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _mNoNetworkImageView.image = image;
    }
    
    if (![_mNoNetworkImageView superview])
    {
        [_mLoadingWaitView addSubview:_mNoNetworkImageView];
    }
    
    _mLoadingStatusLabel.text = @"抱歉，网络连接不畅，请稍后再试！";
}

@end
