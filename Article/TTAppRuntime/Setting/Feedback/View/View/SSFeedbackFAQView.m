//
//  SSFeedbackFAQView.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-9.
//
//

#import "SSFeedbackFAQView.h"
#import "CommonURLSetting.h"
#import "SSWebViewContainer.h"
 

#import "TTDeviceHelper.h"
#import "TTStringHelper.h"

@interface SSFeedbackFAQView()

//@property(nonatomic, retain)UIWebView * webView;
@property(nonatomic, retain)SSWebViewContainer * webContainer;

@end

@implementation SSFeedbackFAQView

- (void)dealloc
{
    self.webContainer = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"efeff4"];
        
        self.webContainer = [[SSWebViewContainer alloc] initWithFrame:self.bounds];
        _webContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webContainer.ssWebView.opaque = NO;
        _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"efeff4"];
        [self addSubview:_webContainer];
        
        NSString * appIDStr = isEmptyString([TTSandBoxHelper ssAppID]) ? @"" : [NSString stringWithFormat:@"&aid=%@", [TTSandBoxHelper ssAppID]];
        
        NSString * urlStr = [NSString stringWithFormat:@"%@?app_name=%@&device_platform=%@%@", [CommonURLSetting feedbackFAQURLString], [TTSandBoxHelper appName], ![TTDeviceHelper isPadDevice] ? @"iphone" : @"ipad", appIDStr];
        
        if(!isEmptyString([TTSandBoxHelper ssAppID]))
        {
            urlStr = [NSString stringWithFormat:@"%@&aid=%@", urlStr, [TTSandBoxHelper ssAppID]];
        }
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[TTStringHelper URLWithURLString:urlStr]];
        [_webContainer.ssWebView loadRequest:request];
        self.modeChangeActionType = ModeChangeActionTypeMask;
        [self reloadThemeUI];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.webContainer.frame = self.bounds;
}
@end
