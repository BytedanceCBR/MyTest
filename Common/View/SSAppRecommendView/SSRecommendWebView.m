//
//  SSRecommendWebView.m
//  Essay
//
//  Created by Dianwei on 12-9-6.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSRecommendWebView.h"
#import "SSTitleBarView.h"
#import "UIColorAdditions.h"
#import "UIApplication+Addition.h"
#import "UIScreen+Addition.h"
#import "SSButton.h"

@interface SSRecommendWebView()<UIWebViewDelegate>
@property(nonatomic, retain)UIWebView *webView;
@property(nonatomic, retain)UIButton *doneButton;
@property(nonatomic, assign)CGRect portraitFrame;
@property(nonatomic, assign)CGRect landscapeFrame;
@property(nonatomic, retain)SSTitleBarView *navigationView;
@property(nonatomic, retain)UIImageView *bgView;
@property(nonatomic, retain)UIImageView *leftBgView;
@property(nonatomic, retain)UIImageView *titleShadowView;

@end

@implementation SSRecommendWebView
@synthesize webView, doneButton, portraitFrame, landscapeFrame;
@synthesize navigationView, bgView, leftBgView, titleShadowView;
- (void)dealloc
{
    self.webView = nil;
    self.doneButton = nil;
    self.navigationView = nil;
    self.bgView = nil;
    self.leftBgView = nil;
    self.titleShadowView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.portraitFrame = CGRectMake(0, 20, frame.size.height + 20, frame.size.width);
        self.landscapeFrame = frame;
        
        UIImage * portraitBGImage;
        UIImage * landscapeBGImage;
        if (SSLogicBool(@"ssAppRecommendViewRecommendWebViewFullScreenShow", NO)) {
            portraitBGImage = [UIImage resourceImageNamed:@"titlebarbg_web_portrait.png"];
            portraitBGImage = [portraitBGImage stretchableImageWithLeftCapWidth:portraitBGImage.size.width/2 topCapHeight:portraitBGImage.size.height/2];
            landscapeBGImage = [UIImage resourceImageNamed:@"titlebarbg_web_landscape.png"];
            landscapeBGImage = [landscapeBGImage stretchableImageWithLeftCapWidth:landscapeBGImage.size.width/2 topCapHeight:landscapeBGImage.size.height/2];
        }
        else {
            portraitBGImage = [UIImage resourceImageNamed:@"titlebarbg_web.png"];
            landscapeBGImage = [UIImage resourceImageNamed:@"titlebarbg_web.png"];
        }
        
        self.navigationView = [[[SSTitleBarView alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self), 44.f)] autorelease];
        UIImageView *portraitBgView = [[UIImageView alloc] initWithImage:portraitBGImage];
        UIImageView *landscapeBgView = [[UIImageView alloc] initWithImage:landscapeBGImage];
        UIImageView *portraitBottomView = [[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"titlebarbg_web_shadow_portrait.png"]];
        UIImageView *landscapeBottomView = [[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"titlebarbg_web_landscape_shadow.png"]];
        
//        [portraitBgView sizeToFit];
//        [landscapeBgView sizeToFit];
        
        portraitBgView.frame = navigationView.bounds;
        landscapeBgView.frame = navigationView.bounds;
        [portraitBottomView sizeToFit];
        [landscapeBottomView sizeToFit];
        
        navigationView.portraitBackgroundView = portraitBgView;
        navigationView.landscapeBackgroundView = landscapeBgView;
        navigationView.portraitBottomView = portraitBottomView;
        navigationView.landscapeBottomView = landscapeBottomView;
        
        [portraitBgView release];
        [landscapeBgView release];
        [portraitBottomView release];
        [landscapeBottomView release];
        
        UILabel *labelView = [[UILabel alloc] init];
        labelView.backgroundColor = [UIColor clearColor];
        NSString *textColor = SSUIString(@"uiAppWebViewTextColor", @"000000");
        labelView.textColor = [UIColor colorWithHexString:textColor];
        labelView.text = SSLogicString(@"appRecommendWebTitle", @"toutiao.com");
        [labelView sizeToFit];
        
        navigationView.centerView = labelView;
        [labelView release];
        
        [self addSubview:navigationView];
        
        
        self.leftBgView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [leftBgView setImage:[[UIImage resourceImageNamed:@"listweb_bg_shadow_left.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.5]];
        [self addSubview:leftBgView];
        
        self.bgView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:bgView];
        
        
        self.doneButton = [SSButton buttonWithSSButtonType:SSButtonTypeNormal];
        [doneButton setTitle:ssLocalizedStringWithDefaultValue(@"HDCloseButtonTitle", @"关闭", nil) forState:UIControlStateNormal];
        [doneButton sizeToFit];
               
        [doneButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        navigationView.rightView = doneButton;
        
        self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(navigationView.frame), self.frame.size.width - 10, self.frame.size.height - CGRectGetMaxY(doneButton.frame))] autorelease];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleBottomMargin;
        webView.scalesPageToFit = YES;
        webView.delegate = self;
        [self addSubview:webView];
        
        [self bringSubviewToFront:leftBgView];
        [self bringSubviewToFront:navigationView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeModeChanged:) name:SSResourceManagerThemeModeChangedNotification object:nil];
        [self sendSubviewToBack:leftBgView];
    }
    return self;
}

- (void)themeModeChanged:(NSNotification*)notification
{
    [(UIImageView*)navigationView.portraitBackgroundView setImage:[UIImage resourceImageNamed:@"titlebarbg_web_portrait.png"]];
    [(UIImageView*)navigationView.landscapeBackgroundView setImage:[UIImage resourceImageNamed:@"titlebarbg_web_landscape.png"]];
    [(UIImageView*)navigationView.portraitBottomView setImage:[UIImage resourceImageNamed:@"titlebarbg_web_shadow_portrait.png"]];
    [(UIImageView*)navigationView.landscapeBottomView setImage:[UIImage resourceImageNamed:@"titlebarbg_web_landscape_shadow.png"]];
    [leftBgView setImage:[[UIImage resourceImageNamed:@"listweb_bg_shadow_left.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.5]];
    NSString *textColor = SSUIStringNoDefault(@"uiAppWebViewTextColor");
    [(UILabel*)navigationView.centerView setTextColor:[UIColor colorWithHexString:textColor]];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)tWebView
{
//    NSString *js = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=%f\">", webView.frame.size.width];
//    NSString *js = @"<meta name=\"viewport\" width=\"320\" content=\"initial-scale=0.1\"";
//    [webView loadHTMLString:js baseURL:nil];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
}

- (void)show
{
    if(![self superview])
    {
        [self refreshUI];
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGRect tmpRect = self.frame;
        CGRect rect = self.frame;
        rect.origin.x = keyWindow.frame.size.width;
        self.frame = rect;
        [keyWindow.rootViewController.view addSubview:self];
        [keyWindow.rootViewController.view bringSubviewToFront:self];
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.frame = tmpRect;
                         }];
        
        
       
    }
}

- (void)refreshUI
{
    if(UIInterfaceOrientationIsPortrait([UIApplication currentUIOrientation]))
    {
        self.frame = portraitFrame;
        [bgView setImage:[[UIImage resourceImageNamed:@"web_bg_landscape.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.5]];
        webView.frame = CGRectMake(0, CGRectGetMaxY(navigationView.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(doneButton.frame));
    }
    else if(UIInterfaceOrientationIsLandscape([UIApplication currentUIOrientation]))
    {
        self.frame = landscapeFrame;
        [bgView setImage:[[UIImage resourceImageNamed:@"web_bg_portrait.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0.5]];
        webView.frame = CGRectMake(10, CGRectGetMaxY(navigationView.frame), self.frame.size.width - 10, self.frame.size.height - CGRectGetMaxY(doneButton.frame));
    }
    
    leftBgView.frame = CGRectMake(0, 0, 10, self.frame.size.height);
    bgView.frame = CGRectMake(CGRectGetMaxX(leftBgView.frame), 0, self.frame.size.width - CGRectGetMaxX(leftBgView.frame), self.frame.size.height);
    
   
}

- (void)close
{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect rect = self.frame;
        rect.origin.x = [[UIApplication sharedApplication] keyWindow].frame.size.width;
        self.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];

}

- (void)startLoadWithURL:(NSURL*)url
{
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)layoutSubviews
{
    [self trySSLayoutSubviews];
}

- (void)ssLayoutSubviews
{
    [self refreshUI];
}

@end
