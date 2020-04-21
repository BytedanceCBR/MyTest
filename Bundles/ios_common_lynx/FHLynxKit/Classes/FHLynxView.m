//
//  FHLynxView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxView.h"
#import <Lynx/LynxView.h>
#import <mach/mach_time.h>
#import "FHLynxCoreBridge.h"
#import "LynxEnv.h"

@interface FHLynxView()
@property (nonatomic, assign) CGRect lynxViewFrame;
@property (nonatomic, copy) NSString *channel;

@end

@implementation FHLynxView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lynxViewFrame = frame;
    }
    return self;
}

#pragma mark - load methods
- (void)loadLynxBaseParams:(FHLynxViewBaseParams *)params
{
    id templateData = nil;
    if (params.initialProperties) {
        if ([params.initialProperties isKindOfClass:[NSString class]]) {
            templateData = [[LynxTemplateData alloc] initWithJson:params.initialProperties];
        } else if ([params.initialProperties isKindOfClass:[NSDictionary class]]) {
            templateData = [[LynxTemplateData alloc] initWithDictionary:params.initialProperties];
        }
        LynxTemplateData *initialData = [[LynxTemplateData alloc] initWithDictionary:templateData];
        [self.lynxView loadTemplate:self.data withURL:params.sourceUrl initData:initialData];
    } else {
        [self.lynxView loadTemplate:self.data withURL:params.sourceUrl];
    }
}

- (void)loadLynxWithParams:(FHLynxViewBaseParams *)params {
    if (!params) return;
    self.params = params;
    
    if (params.channel) {
        self.channel = params.channel;
    }
    
    if (self.data) {
        // Hybrid Monitor
        [self loadLynxBaseParams:params];
    } else if (params.sourceUrl) {
        // Add params to url for reload url from remote without cache
        BOOL hasParams = [params.sourceUrl rangeOfString:@"?"].location != NSNotFound;
        NSString* seperator = hasParams ? @"&" : @"?";
        NSString* url = [params.sourceUrl stringByAppendingFormat:@"%@t=%llu", seperator, mach_absolute_time()];
        [_lynxView loadTemplateFromURL:url];
    } else {
        NSAssert(false, @"url or data should set for TemplateView");
    }
    
    [self insertSubview:self.lynxView atIndex:0];
}

#pragma mark - reload Lynx
- (void)reloadWithBaseParams:(FHLynxViewBaseParams *)params data:(NSData *)data
{
    _params = params;
    [self.lynxView setHidden:NO];
    if (data) {
        _data = data;
        [self loadLynxBaseParams:params];
    }
}

- (void)reload
{
    [self reloadWithBaseParams:self.params data:self.data];
}

- (void)updateData:(NSDictionary *)dict
{
    if (!dict) return;
    NSError *error = nil;
    [_lynxView updateDataWithString:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding]];
}

#pragma mark - Bridge Handler
- (void)registerHandler:(FHLynxViewBridgeHandler)handler forMethod:(NSString *)method
{
//    [self.lynxView.bridge registerHandler:^(LynxView * _Nonnull lynxView, NSString * _Nonnull name, NSDictionary * _Nullable params, void (^ _Nonnull callback)(BDLynxBridgeStatusCode, NSDictionary * _Nullable)) {
//        handler(lynxView, name, params, callback);
//    } forMethod:method];
}

#pragma mark - BDLynxClientLifeCycleDelegate
- (void)viewDidChangeIntrinsicContentSize:(CGSize)size
{
    if ([self.lynxDelegate respondsToSelector:@selector(viewDidChangeIntrinsicContentSize:)]) {
        [self.lynxDelegate viewDidChangeIntrinsicContentSize:size];
    }
}

#pragma mark - Accessors
- (LynxView *)lynxView
{
    if (!_lynxView) {
        _lynxView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
            builder.isUIRunningMode = YES;
            builder.config = [[LynxConfig alloc] initWithProvider:[[LynxEnv sharedInstance] config].templateProvider];
            [builder.config registerModule:[FHLynxCoreBridge class]];
        }];
        switch (self.widthMode) {
            case FHLynxViewSizeModeUndefined:
                _lynxView.layoutWidthMode = LynxViewSizeModeUndefined;
                _lynxView.preferredMaxLayoutWidth = self.lynxViewFrame.size.width;
                break;
            case FHLynxViewSizeModeExact:
                _lynxView.layoutWidthMode = LynxViewSizeModeExact;
                _lynxView.preferredLayoutWidth = self.lynxViewFrame.size.width;
                break;
            case FHLynxViewSizeModeMax:
                _lynxView.layoutWidthMode = FHLynxViewSizeModeMax;
                _lynxView.preferredMaxLayoutWidth = self.lynxViewFrame.size.width;
                break;
            default:
                _lynxView.layoutWidthMode = LynxViewSizeModeUndefined;
                _lynxView.preferredMaxLayoutWidth = self.lynxViewFrame.size.width;
                break;
        }
        switch (self.heightMode) {
            case FHLynxViewSizeModeUndefined:
                _lynxView.layoutHeightMode = LynxViewSizeModeUndefined;
                _lynxView.preferredMaxLayoutHeight = self.lynxViewFrame.size.height;
                break;
            case FHLynxViewSizeModeExact:
                _lynxView.layoutHeightMode = LynxViewSizeModeExact;
                _lynxView.preferredLayoutHeight = self.lynxViewFrame.size.height;
                break;
            case FHLynxViewSizeModeMax:
                _lynxView.layoutHeightMode = FHLynxViewSizeModeMax;
                _lynxView.preferredMaxLayoutHeight = self.lynxViewFrame.size.width;
                break;
            default:
                _lynxView.layoutHeightMode = LynxViewSizeModeUndefined;
                _lynxView.preferredMaxLayoutHeight = self.lynxViewFrame.size.height;
                break;
        }
        [_lynxView invalidateIntrinsicContentSize];
        _lynxView.frame = CGRectMake(0, 0, _lynxView.intrinsicContentSize.width, _lynxView.intrinsicContentSize.height);
    }
    return _lynxView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
