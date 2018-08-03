//
//  SSAppRecommendView.m
//  Essay
//
//  Created by Dianwei on 12-9-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSAppRecommendView.h"
#import "SSResourceManager.h"
#import "SSAppRecommendManager.h"
#import "RecommendAppCellView.h"
#import "SSRecommendWebView.h"
#import "UIView+Badge.h"
#import "SSADUMUFPHandleView.h"
#import "UIScreen+Addition.h"
#import "UIApplication+Addition.h"
#import "UIColorAdditions.h"

#define kPortraitWidthPadding   47
#define kLandscapeWidthPadding  40
#define kPortraitIconNumberPerRow   1
#define kLandscapeIconNumberPerRow  1

#define TrackAppRecommend @"app_bar"


@interface SSAppRecommendView()<SSAppRecommendManagerDelegate, UIScrollViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate> {
    id _recommendButtonTarget;
    SEL _recommendButtonSelector;
}
@property(nonatomic, retain)UIImageView *upperImageView;
@property(nonatomic, retain)UIImageView *lowerImageView;
@property(nonatomic, retain)UIScrollView *appScrollView;
@property(nonatomic, retain)NSMutableArray *iconViews;
@property(nonatomic, retain)NSMutableArray *appInfos;
@property(nonatomic, retain)UIImageView *backgroundView;
@property(nonatomic, retain)SSAppRecommendManager *manager;
@property(nonatomic, retain)SSRecommendWebView *webView;
//@property(nonatomic, retain)UIButton *recommendButton;
//@property(nonatomic, retain)SSADUMUFPHandleView * ufpHandleView;

@end

@implementation SSAppRecommendView
@synthesize upperImageView, lowerImageView, appScrollView;
@synthesize iconViews, manager;
@synthesize appInfos;
@synthesize webView;
@synthesize backgroundView;//, recommendButton;
//@synthesize ufpHandleView = _ufpHandleView;

- (void)dealloc
{
    self.upperImageView = nil;
    self.lowerImageView = nil;
    self.appScrollView = nil;
    self.iconViews = nil;
    self.manager = nil;
    self.appInfos = nil;
    self.webView = nil;
    self.backgroundView = nil;
//    self.recommendButton = nil;
//    self.ufpHandleView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.clipsToBounds = YES;
        self.upperImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.lowerImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:upperImageView];
        [self addSubview:lowerImageView];
        self.appScrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
        appScrollView.delegate = self;
        appScrollView.clipsToBounds = YES;
        appScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:appScrollView];
        
        [self sendSubviewToBack:appScrollView];
        
        self.backgroundView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        setAutoresizingMaskFlexibleWidthAndHeight(backgroundView);
        if (UIInterfaceOrientationIsPortrait([UIApplication currentUIOrientation])) {
            [backgroundView setImage:[UIImage resourceImageNamed:@"cover_bg_portrait.png"]];
        }
        else {
            [backgroundView setImage:[UIImage resourceImageNamed:@"cover_bg_landscape.png"]];
        }

        [self addSubview:backgroundView];
        [self sendSubviewToBack:backgroundView];
        
        self.iconViews = [[[NSMutableArray alloc] init] autorelease];
        self.appInfos = [[[NSMutableArray alloc] init] autorelease];
        [self startGetAppInfo];
        
        upperImageView.hidden = YES;
        lowerImageView.hidden = YES;
        
        [upperImageView setImage:[UIImage resourceImageNamed:@"cover_up_landscape.png"]];
        [lowerImageView setImage:[UIImage resourceImageNamed:@"cover_down_landscape.png"]];
        
        [upperImageView sizeToFit];
        [lowerImageView sizeToFit];
        
        CGRect upperRect = upperImageView.frame;
        upperRect.origin.x = self.frame.size.width - upperRect.size.width - kPortraitWidthPadding;
        upperRect.origin.y = 0;
        upperImageView.frame = upperRect;
        
        CGRect lowerRect = lowerImageView.frame;
        lowerRect.origin.y = self.frame.size.height - lowerImageView.frame.size.height;
        lowerRect.origin.x = self.frame.size.width - lowerImageView.frame.size.width - kPortraitWidthPadding;
        lowerImageView.frame = lowerRect;
        
//        if (SSLogicBoolNODefault(@"ELHasAdsInApp")) {
//            self.ufpHandleView = [[[SSADUMUFPHandleView alloc] initWithCurrentViewController:[SSCommon topViewControllerFor:self] uniqueKey:kSSADAlwaysShowAreaKey handleBgImg:[UIImage resourceImageNamed:@"apprecom.png"]] autorelease];
//            _ufpHandleView.delegate = self;
//            [self setUFPHandleViewFrame];
//            [self addSubview:_ufpHandleView];
//        }
    }
    
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    upperImageView.hidden = scrollView.contentOffset.y <  12;
    lowerImageView.hidden = scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.size.height;
}

- (void)startGetAppInfo
{
    if(!manager)
    {
        self.manager = [[[SSAppRecommendManager alloc] init] autorelease];
        manager.delegate = self;
    }
    
    [manager startGetAppInfo];
}

- (void)appRecommendManager:(SSAppRecommendManager*)tManager getInfoRequestFinishedWithResult:(NSDictionary*)result finished:(BOOL)finished
{
    if(![result objectForKey:@"error"])
    {
        [appInfos removeAllObjects];
        NSArray *serverResult = [result objectForKey:@"result"];
        for(NSDictionary *dict in serverResult)
        {
            [appInfos addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
        }
        

        NSMutableArray *installedApps = [NSMutableArray arrayWithCapacity:10];
        for(NSMutableDictionary *info in appInfos)
        {
            BOOL installed = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[info objectForKey:@"open_url"]]];
            [info setObject:[NSNumber numberWithBool:installed] forKey:@"installed"];
            if(installed)
            {
                [installedApps addObject:[info objectForKey:@"app_name"]];
            }
        }
        
        if([installedApps count] > 0 && finished)
        {
            [manager startGetStatusForApps:installedApps];
        }
        
        [self refreshUI];
    }
}

- (void)appRecommendManager:(SSAppRecommendManager *)manager getStatusCountRequestFinishedWithResult:(NSDictionary *)result
{
    if(![result objectForKey:@"error"])
    {
        NSDictionary *countResult = [result objectForKey:@"result"];
        for(NSMutableDictionary *info in appInfos)
        {
            [info setValue:[countResult objectForKey:[info objectForKey:@"app_name"]] forKey:@"count"];
        }
        
        [self refreshIcons];
    }
}

- (void)refreshIcons
{
    for(UIView *view in iconViews)
    {
        [view removeFromSuperview];
    }
    
    [iconViews removeAllObjects];
    [appInfos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *info = (NSDictionary*)obj;
        RecommendAppCellView *cell = [[RecommendAppCellView alloc] initWithFrame:CGRectMake(0, 0, 130, 155)];
        [cell addTarget:self action:@selector(iconClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.tag = idx;
        cell.badge.displayWhenZero = NO;
        [cell reloadData:info];
        [iconViews addObject:cell];
        [appScrollView addSubview:cell];
        cell.badge.badgeValue = [[info objectForKey:@"count"] intValue];
        CGRect badgeRect = cell.badge.frame;
        badgeRect.origin.x -= 35;
        badgeRect.origin.y += 6;
        cell.badge.frame = badgeRect;
        [cell release];

    }];
    
    float heightPadding = 0;
    float widthPadding = 0;
    int cellNumber = 0;
    
    if(UIInterfaceOrientationIsPortrait([UIApplication currentUIOrientation]) || SSLogicBool(@"ssAppRecommendViewOnlySupportPortaritOrientation", NO))
    {
        heightPadding = 4;
        widthPadding = 0;
        cellNumber = kPortraitIconNumberPerRow;
    }
    else if(UIInterfaceOrientationIsLandscape([UIApplication currentUIOrientation]))
    {
        heightPadding = 4;
        widthPadding = 6;
        cellNumber = kLandscapeIconNumberPerRow;
    }
    
    __block float offsetX = 45 + 16.f;
    __block float offsetY = 0;
    
    [iconViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView*)obj;
        CGRect rect = view.frame;
        rect.origin.x = offsetX;
        rect.origin.y = offsetY;
        view.frame = rect;
        offsetX = CGRectGetMaxX(view.frame) + widthPadding;
        
        if((idx + 1) % cellNumber == 0)
        {
            offsetX = 45 + 16.f;
            offsetY = CGRectGetMaxY(view.frame) + heightPadding;
        }
    }];
    
    UIView *lastIcon = (UIView*)[iconViews lastObject];
    appScrollView.contentSize = CGSizeMake(appScrollView.frame.size.width, CGRectGetMaxY(lastIcon.frame));
}

- (void)layoutSubviews
{
    [self trySSLayoutSubviews];
}

- (void)ssLayoutSubviews
{
    webView.frame = [self frameForWebView];
    
    [self refreshUI];
    
    if (UIInterfaceOrientationIsPortrait([UIApplication currentUIOrientation])) {
        [backgroundView setImage:[UIImage resourceImageNamed:@"cover_bg_portrait.png"]];
    }
    else {
        [backgroundView setImage:[UIImage resourceImageNamed:@"cover_bg_landscape.png"]];
    }
}

- (void)refreshUI
{
    float scrollWidth = self.frame.size.width;
    // SSLogicBool(@"ssAppRecommendViewOnlySupportPortaritOrientation", NO)  图片类需求，需要任何方向都只显示1列
    backgroundView.frame = self.bounds;
//    [self setUFPHandleViewFrame];
    
    appScrollView.frame = CGRectMake(0, 22, scrollWidth, self.frame.size.height - 145);
    appScrollView.center = CGPointMake(self.frame.size.width/2, appScrollView.center.y);
    upperImageView.center = CGPointMake(appScrollView.center.x, upperImageView.center.y);
    lowerImageView.center = CGPointMake(appScrollView.center.x, lowerImageView.center.y);
    
    [self refreshIcons];
    [self scrollViewDidScroll:appScrollView];
}

//- (void)setUFPHandleViewFrame
//{
//    [_ufpHandleView sizeToFit];
//    CGRect ufpFrame = _ufpHandleView.frame;
//    ufpFrame.origin.y = self.frame.size.height -  45 - ufpFrame.size.height;
//    _ufpHandleView.frame = ufpFrame;
//    _ufpHandleView.center = CGPointMake(self.frame.size.width/2, _ufpHandleView.center.y);
////    NSLog(@"_ufp %@", NSStringFromCGRect(_ufpHandleView.frame));
//}

- (void)setRecommendButtonTarget:(id)target selector:(SEL)selector
{
    _recommendButtonTarget = target;
    _recommendButtonSelector = selector;
}

- (void)recommendButtonClicked:(id)sender
{
    if (_recommendButtonTarget && _recommendButtonSelector) {
        if ([_recommendButtonTarget respondsToSelector:_recommendButtonSelector]) {
            
            NSMethodSignature *signature = [_recommendButtonTarget methodSignatureForSelector:_recommendButtonSelector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:_recommendButtonTarget];
            [invocation setSelector:_recommendButtonSelector];
            [invocation invoke];
        }
    }
}

- (void)iconClicked:(UIButton*)sender
{
    if(sender.tag < [appInfos count])
    {
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[appInfos objectAtIndex:sender.tag]];
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[data objectForKey:@"open_url"]]])
        {
            trackEvent([SSCommon appName], TrackAppRecommend, @"click_joke_essay_installed");
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[data objectForKey:@"open_url"]]];
        }
        else 
        {
            trackEvent([SSCommon appName], TrackAppRecommend, @"click_joke_essay_uninstalled");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您尚未安装 %@,是否去App Store免费下载?", [data objectForKey:@"display_name"]]
                                                               delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"网页体验", @"下载", nil];
            alertView.tag = sender.tag;
            [alertView show];
            [alertView release];
        }
        
        [data setObject:[NSNumber numberWithInt:0] forKey:@"count"];
        [appInfos replaceObjectAtIndex:sender.tag withObject:data];
        
        UIButton *button = (UIButton*)sender;
        button.badge.badgeValue = 0;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex && alertView.tag < [appInfos count])
    {
        NSDictionary *data = [appInfos objectAtIndex:alertView.tag];
        switch (buttonIndex) {
            case 1:
            {
                trackEvent([SSCommon appName], TrackAppRecommend, @"alert_web_preview");
                
                if(!webView)
                {
                    self.webView = [[[SSRecommendWebView alloc] initWithFrame:[self frameForWebView]] autorelease];
                }
                
                [webView show];
                NSString *urlString = [[appInfos objectAtIndex:alertView.tag] objectForKey:@"web_url"];
                [webView startLoadWithURL:[NSURL URLWithString:urlString]];
            }
                break;
            case 2:
            {
                trackEvent([SSCommon appName], TrackAppRecommend, @"alert_install");
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[data objectForKey:@"download_url"]]];
            }
                break;
            default:
                trackEvent([SSCommon appName], TrackAppRecommend, @"alert_cancel");
                break;
        }
    }
}

- (void)closeWebView
{
    [webView close];
}

//#pragma mark -- UMUFPHandleViewDelegate
//
//- (void)handleViewWillAppear:(UMUFPHandleView *)handleView
//{
//    if (handleView == _ufpHandleView) {
//        [self setUFPHandleViewFrame];
//    }
//}

#pragma mark -- calculate frame

- (CGRect)frameForWebView
{
    float offsetY = [[UIApplication sharedApplication] isStatusBarHidden] ? 0 : MIN([[UIApplication sharedApplication] statusBarFrame].size.height, [[UIApplication sharedApplication] statusBarFrame].size.width);
    
    float shortSide = MIN(screenSize().width, screenSize().height);
    float largeSide = MAX(screenSize().width, screenSize().height);
    
    CGRect laFrame;
    if (SSLogicBool(@"ssAppRecommendViewRecommendWebViewFullScreenShow", NO)) {
        laFrame = CGRectMake(0, offsetY, largeSide, shortSide - offsetY);
    }
    else {
        laFrame = CGRectMake(largeSide - shortSide, offsetY, shortSide, largeSide);
    }
    CGRect poFrame = CGRectMake(0, offsetY, shortSide, largeSide);
    
    CGRect webViewFrame = CGRectZero;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication currentUIOrientation])) {
        webViewFrame = poFrame;
    }
    else {
        webViewFrame = laFrame;
    }
    
    return webViewFrame;
}
@end
