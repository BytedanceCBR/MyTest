//
//  TTRNView.m
//  Article
//
//  Created by Chen Hong on 16/7/13.
//
//

#import "TTRNView.h"
#import "RCTRootView.h"
#import "RCTRootViewDelegate.h"
#import "TTRNBridge.h"
#import "TTRNBundleManager.h"
#import "RCTExceptionsManager.h"
#import "RCTAssert.h"
#import "UIColor+TTThemeExtension.h"
#import <CrashLytics/Answers.h>

@interface TTRNView () <RCTRootViewDelegate, RCTBridgeDelegate, RCTExceptionsManagerDelegate>
@property (nonatomic, strong) RCTRootView *rootView;
@property (nonatomic, strong) NSString *bundleUrl;
@property (nonatomic, copy) TTRNFatalHandler fatalHandler;
@property (nonatomic, copy) NSString *moduleName;
@end

@implementation TTRNView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelRCTRootViewTouches:) name:kTTRNViewCancelTouchesNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 设置一个空的handler避免RCTFatal抛出异常导致应用crash
            WeakSelf;
            RCTSetFatalHandler(^(NSError *error) {
                StrongSelf;
                NSLog(@"%@", error);
                NSLog(@"%@", error);
                //[[TTMonitor shareManager] trackService:@"ttrnview_fatal" status:1 extra:nil];
                NSString *name = [NSString stringWithFormat:@"%@: %@", RCTFatalExceptionName, error.localizedDescription];
                NSString *message = RCTFormatError(error.localizedDescription, error.userInfo[RCTJSStackTraceKey], 75);
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
                [dict setValue:error.localizedDescription forKey:@"errorDesc"];
                [dict setValue:[[TTRNBundleManager sharedManager] RNVersion] forKey:@"rnVersion"];
                [dict setValue:message forKey:@"message"];
                [dict setValue:name forKey:@"name"];
                [Answers logCustomEventWithName:@"ttrnview_fatal" customAttributes:dict];
                [[TTMonitor shareManager] trackService:@"ttrnview_fatal" status:0 extra:dict];
            });
        });
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (TTRNBridge *)bridgeModule {
    TTRNBridge *module = [self.rootView.bridge moduleForClass:[TTRNBridge class]];
    return module;
}

- (void)loadModule:(NSString *)moduleName initialProperties:(NSDictionary *)initialProperties {
    self.moduleName = moduleName;
    RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:nil];
    
    self.rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:moduleName initialProperties:initialProperties];
    
    //    self.rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
    //                                                moduleName:moduleName
    //                                         initialProperties:initialProperties
    //                                             launchOptions:nil];
    
    self.rootView.delegate = self;
    
    TTRNBridge *bridgeModule = [self.rootView.bridge moduleForClass:[TTRNBridge class]];
    bridgeModule.rnView = self;
    
    [self addSubview:self.rootView];
    self.rootView.backgroundColor = [UIColor clearColor];
}

#pragma mark - RCTBridgeDelegate

- (NSURL *)sourceURLForBridge:(__unused RCTBridge *)bridge {
    NSURL *jsCodeLocation = [self jsCodeLocation];
    return jsCodeLocation;
}

- (NSURL *)fallbackSourceURLForBridge:(RCTBridge *)bridge {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fallbackSourceURL)]) {
        return [self.delegate fallbackSourceURL];
    }
    return [[NSBundle mainBundle] URLForResource:@"index.ios" withExtension:@"bundle"];
}

- (NSArray *)extraModulesForBridge:(RCTBridge *)bridge {
    return @[[[RCTExceptionsManager alloc] initWithDelegate:self]];
}

#pragma mark - RCTExceptionsManagerDelegate

- (void)handleSoftJSExceptionWithMessage:(NSString *)message stack:(NSArray *)stack exceptionId:(NSNumber *)exceptionId {
    [Answers logCustomEventWithName:@"rn_soft_exception" customAttributes:@{ @"moduleName": self.moduleName ?: @"" }];
}

- (void)handleFatalJSExceptionWithMessage:(NSString *)message stack:(NSArray *)stack exceptionId:(NSNumber *)exceptionId {
    [Answers logCustomEventWithName:@"rn_fatal_exception" customAttributes:@{ @"moduleName": self.moduleName ?: @"" }];
    if (_fatalHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_fatalHandler) {
                _fatalHandler();
            }
        });
    }
}

#pragma mark -

- (void)updateProperties:(NSDictionary *)props {
    //开发环境时reload会重建TTRNBridgeModule，rnView属性需要重设
    TTRNBridge *bridgeModule = [self.rootView.bridge moduleForClass:[TTRNBridge class]];
    bridgeModule.rnView = self;

    self.rootView.appProperties = props;
}

- (void)setLoadingView:(UIView *)loadingView {
    self.rootView.loadingView = loadingView;
}

- (void)setSizeFlexibility:(TTRNViewSizeFlexibility)sizeFlexibility {
    self.rootView.sizeFlexibility = (RCTRootViewSizeFlexibility)sizeFlexibility;
}

- (void)reload {
    [self.rootView.bridge reload];
    
    //开发环境时reload会重建TTRNBridgeModule，rnView属性需要重设
    TTRNBridge *bridgeModule = [self.rootView.bridge moduleForClass:[TTRNBridge class]];
    bridgeModule.rnView = self;
}

- (void)refreshSize {
    if (self.rootView.intrinsicSize.height == 0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(rootViewDidChangeIntrinsicSize:)]) {
        [self.delegate rootViewDidChangeIntrinsicSize:self.rootView.intrinsicSize];
    }
}

- (void)removeRootViewSuviews
{
    [self.rootView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIView class]]) {
            [obj removeFromSuperview];
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.rootView.frame = self.bounds;
}

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    CGRect newFrame = rootView.frame;
    newFrame.size = rootView.intrinsicSize;
    rootView.frame = newFrame;
    
    if ([self.delegate respondsToSelector:@selector(rootViewDidChangeIntrinsicSize:)]) {
        [self.delegate rootViewDidChangeIntrinsicSize:newFrame.size];
    }
}

- (void)setFatalHandler:(TTRNFatalHandler)handler {
    _fatalHandler = handler;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    if (!userInteractionEnabled) {
        [self.rootView cancelTouches];
    }
}

- (void)cancelRCTRootViewTouches:(NSNotification *)noti {
    [self.rootView cancelTouches];
}

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (NSURL*)jsCodeLocation
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RNBundleUrl)]) {
        return [self.delegate RNBundleUrl];
    }
    
    return [[TTRNBundleManager sharedManager] localBundleURLForModuleName:self.moduleName];
}

@end
