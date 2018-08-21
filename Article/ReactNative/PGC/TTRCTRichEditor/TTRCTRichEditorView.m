//
//  TTRCTRichEditorView.m
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#import <Foundation/Foundation.h>
#import "TTRCTRichEditorView.h"

#import "TTUIResponderHelper.h"
#import <React/RCTView.h>
#import "NSString+URLEncoding.h"
#import "TTPGCResourceManager.h"
#import "TTStringHelper.h"
#import "NSStringAdditions.h"

@interface TTRCTRichEditorView () <UIWebViewDelegate>

// vars for webview
@property (nonatomic, assign) BOOL isDomLoaded;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isFocused;

// 原生滚动scrollView所需用到的变量
@property (nonatomic, strong, readwrite) NSNumber * caretYOffset;
@property (nonatomic, strong, readwrite) NSNumber * lineHeight;
// 节流所需的时间记录
@property (nonatomic, strong) NSDate * lastTimeToGetContent;
@property (nonatomic, strong) NSDate * lastTimeSelectionChange;

@end

@implementation TTRCTRichEditorView

#pragma mark - static vars
static NSString * TTRCTRichEditorViewCallbackParamsGroupSeperator = @"~";
static NSString * TTRCTRichEditorViewCallbackParamsPairSeperator = @"=";

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        [self initEditorWebView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _editorWebView.frame = self.bounds;
}

#pragma mark - dealloc
//- (void)willMoveToWindow:(UIWindow *)newWindow {
//    if (newWindow == nil) {
//        [self stopObservingKeyboardNotifications];
//        [[self eventController] offByNS:[self eventNamespace]];
//    }
//}

- (void)dealloc {
    [self stopObservingKeyboardNotifications];
    [[self eventController] offByNamespace:[self eventNamespace]];
}

#pragma mark - webview init
- (void)initEditorWebView {
    // init vars
    self.isDomLoaded = NO;
    self.isFocused = NO;
    self.isEditing = NO;

    // create webview
    UIWebView * editorWebView = [[UIWebView alloc] init];

    editorWebView.delegate = self;
    editorWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    editorWebView.scalesPageToFit = YES;
    editorWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    editorWebView.backgroundColor = [UIColor clearColor];
    editorWebView.scrollView.showsHorizontalScrollIndicator = NO;
    editorWebView.scrollView.showsVerticalScrollIndicator = NO;
    editorWebView.opaque = NO;
    editorWebView.scrollView.bounces = NO;
    editorWebView.keyboardDisplayRequiresUserAction = NO;

    self.editorWebView = editorWebView;
    [self addSubview:editorWebView];

    // load html
    TTPGCResourceManager * resourceManager = [[TTPGCResourceManager alloc] init];
    [resourceManager loadWebContent:editorWebView folder:kPGCEditorFolder
                           fileName:kPGCEditorHtmlFile
                        fallbackUrl:[self htmlOnlineUrl]
                         onDownload:nil
     ];

    // set scrollview after html is loaded
    editorWebView.scrollView.bounces = NO;
    editorWebView.scrollView.showsHorizontalScrollIndicator = NO;
    editorWebView.scrollView.showsVerticalScrollIndicator = NO;

    // events
    [self registerEventListeners];
    [self startObservingKeyboardNotifications];
}

- (NSString *)htmlOnlineUrl {
    return @"http://s0.pstatp.com/site/react-native/pgc_rn_editor_html/pgc-editor.html";
}

#pragma mark - Keyboard notifications
- (void)startObservingKeyboardNotifications {
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardDidShow:)
    //                                                 name:UIKeyboardDidShowNotification
    //                                               object:nil];
}

- (void)stopObservingKeyboardNotifications {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                 ·                                   name:UIKeyboardDidShowNotification
    //                                                  object:nil];
}

#pragma mark - keyboard handle
//- (void)keyboardDidShow:(NSNotification *)notification {
//}

#pragma mark - events handle
- (TTPGCEventController *)eventController {
    return [TTPGCEventController sharedInstance];
}

- (NSString *)eventNamespace {
    return @"TTRCTRichEditor";
}

#pragma mark - Handling URL callbacks
// 处理callback url
- (BOOL)handleWebViewCallbackURL:(NSURL *)url {
    BOOL handled = NO;
    NSString *scheme = [url scheme];
    if (scheme) {
        handled = [[self eventController] emit:[self eventNamespace] eventName:scheme data:url canCancel:NO];
    }
    return handled;
}

// 注册callback处理
- (void)registerEventListeners {
    // use subscription to listen events
    // so that you can add or remove listener dynamically

    SEL noHandle = @selector(noHandleCallback:url:);

    [self on:@"callback-dom-loaded" fn:@selector(onDomReady:url:)];
    [self on:@"callback-focus-in" fn:@selector(onFocusIn:url:)];
    [self on:@"callback-focus-out" fn:@selector(onFocusOut:url:)];
    [self on:@"callback-input" fn:@selector(onInput:url:)];
    [self on:@"callback-selection-changed" fn:@selector(onSelectionChange:url:)];
    //    [self on:@"callback-selection-style" fn:@selector(onSelectionStyle:url:)];
    [self on:@"callback-click-viewport" fn:noHandle];
    [self on:@"callback-response-string" fn:@selector(onGetHtmlResponse:url:)];
}

// 调用delegate
- (void)callDelegateCallback:(NSString *)eventName data:(id)data {
    if ([_delegate respondsToSelector:@selector(on:data:)]) {
        [_delegate on:eventName data:data];
    }
}

// 添加callback处理快捷函数
- (void)on:(NSString *)eventName fn:(SEL)fn {
    [[self eventController] on:[self eventNamespace] eventName:eventName caller:self selector:fn];
}

// 获取callback scheme 和 event name的对应关系
- (NSMutableDictionary *)getCallbackSchemeToEventName {
    if (!_callbackSchemeToEventName) {
        _callbackSchemeToEventName = [[NSMutableDictionary alloc] init];
        [_callbackSchemeToEventName setValue:@"onClickViewport" forKey:@"callback-click-viewport"];
        [_callbackSchemeToEventName setValue:@"onDomReady" forKey:@"callback-dom-loaded"];
        [_callbackSchemeToEventName setValue:@"onFocusIn" forKey:@"callback-focus-in"];
        [_callbackSchemeToEventName setValue:@"onFocusOut" forKey:@"callback-focus-out"];
        [_callbackSchemeToEventName setValue:@"onGetHtmlResponse" forKey:@"callback-response-string"];
    }
    return _callbackSchemeToEventName;
}

// 获取event name
- (NSString *)getEventNameByCallbackScheme:(NSString *)callbackScheme {
    return [[self getCallbackSchemeToEventName] valueForKey:callbackScheme];
}

- (void)onDomReady:(NSString *)callbackScheme url:(NSURL *)url {
    self.isDomLoaded = YES;
    [self callDelegateCallback:[self getEventNameByCallbackScheme:callbackScheme] data:nil];
}

- (void)onFocusIn:(NSString *)callbackScheme url:(NSURL *)url {
    _isEditing = YES;
    _isFocused = YES;
    [self callDelegateCallback:[self getEventNameByCallbackScheme:callbackScheme] data:nil];
}

- (void)onFocusOut:(NSString *)callbackScheme url:(NSURL *)url {
    _isEditing = NO;
    _isFocused = NO;
    [self callDelegateCallback:[self getEventNameByCallbackScheme:callbackScheme] data:nil];
}

- (void)onInput:(NSString *)callbackScheme url:(NSURL *)url {
    //    [self scrollToCaretFromCallbackURL:url];
    //    [self callDelegateCallback:[self getEventNameByCallbackScheme:callbackScheme] data:nil];
}

- (void) onSelectionChange:(NSString *)callbackScheme url:(NSURL *)url {
    if ([self throttlingShouldCall:self.lastTimeSelectionChange time:0.3]) {
        [self callDelegateCallback:[self getEventNameByCallbackScheme:callbackScheme] data:nil];
        [self scrollToCaretFromCallbackURL:url];
        [self getWebViewContent];
        self.lastTimeSelectionChange = [[NSDate alloc] init];
    }
}

//- (void) onSelectionStyle:(NSString *)callbackScheme url:(NSURL *)url {
//    // TODO: style parse
//    NSArray * styles = [[url resourceSpecifier] componentsSeparatedByString:TTRCTRichEditorViewCallbackParamsGroupSeperator];
//}

- (void) noHandleCallback:(NSString *)callbackScheme url:(NSURL *)url {
    [self callDelegateCallback:[self getEventNameByCallbackScheme:callbackScheme] data:nil];
}

- (void)onGetHtmlResponse:(NSString *)callbackScheme url:(NSURL *)url {
    NSMutableDictionary * params = [self parseParamsFromGetHtmlResponseURL:url fieldLength:3];
    [params setValue:[params valueForKey:@"function"] forKey:@"functionId"];
    [params setValue:[params valueForKey:@"contents"] forKey:@"content"];
    [params removeObjectForKey:@"contents"];
    [params removeObjectForKey:@"function"];

    [self callDelegateCallback:[self getEventNameByCallbackScheme:callbackScheme] data:params];
}

- (void)getWebViewContent {
    if (![self throttlingShouldCall:self.lastTimeToGetContent time:1]) {
        return;
    }

    NSString * result = [self.editorWebView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.$editor.text().trim().length"];
    [self callDelegateCallback:@"onEditorTextChange" data:[NSNumber numberWithInteger:![result isEqualToString:@"0"]]];
    self.lastTimeToGetContent = [[NSDate alloc] init];
}

#pragma mark - functions
- (BOOL)evaluateJavascript:(NSString *)js
               ignoreRange:(BOOL)ignoreRange {
    if (!self.isDomLoaded) {
        return NO;
    }
    if (!_isFocused && !ignoreRange) {
        js = [NSString stringWithFormat:@"ZSSEditor.restoreRange();%@", js];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.editorWebView stringByEvaluatingJavaScriptFromString:js];
    });
    return YES;
}

- (BOOL)evaluateJavascript:(NSString *)js  {
    return [self evaluateJavascript:js ignoreRange:NO];
}

- (BOOL)hideKeyboard {
    if (!self.isDomLoaded) {
        return NO;
    }
    _isFocused = NO;
    [self evaluateJavascript:@"ZSSEditor.backupRange();" ignoreRange:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.editorWebView endEditing:YES];
    });
    return YES;
}

- (BOOL)showKeyboard {
    if (!self.isDomLoaded) {
        return NO;
    }
    _isEditing = YES;
    _isFocused = YES;
    [self evaluateJavascript:@"ZSSEditor.restoreRange();" ignoreRange:YES];
    return YES;
}

#pragma mark - Scrolling support
- (void)scrollToCaretAnimated:(BOOL)animated
                 caretYOffset:(NSNumber *)caretYOffsetNumber
                   lineHeight:(NSNumber *)lineHeightNumber {
    BOOL notEnoughInfoToScroll = caretYOffsetNumber == nil || lineHeightNumber == nil;

    if (notEnoughInfoToScroll) {
        return;
    }

    CGRect viewport = [self viewport];
    CGFloat caretYOffset = [caretYOffsetNumber floatValue];
    CGFloat lineHeight = [lineHeightNumber floatValue];

    //    if (lineHeight > 25 || lineHeight < 14) {
    //        lineHeight = 20;
    //    }

    //如果光标的在上面被挡住了
    if (caretYOffset < viewport.origin.y) {
        CGFloat necessaryHeight = viewport.size.height;
        CGFloat aimOffset = caretYOffset - lineHeight;
        CGRect targetRect = CGRectMake(0.0f, aimOffset, CGRectGetWidth(viewport), necessaryHeight);
        [_editorWebView.scrollView scrollRectToVisible:targetRect animated:animated];
    }

    //如果光标的在下面被挡住了
    if (caretYOffset > viewport.origin.y + CGRectGetHeight(viewport) - lineHeight) {
        // CGFloat y = _editorWebView.scrollView.contentOffset.y;
        CGFloat x = _editorWebView.scrollView.contentOffset.x;
        [_editorWebView.scrollView setContentOffset:CGPointMake(x, caretYOffset - viewport.size.height + lineHeight) animated:animated];
    }
}

- (void)scrollToCaretAnimatedIfNecessary:(BOOL)animated
                            caretYOffset:(NSNumber *)caretYOffsetNumber
                              lineHeight:(NSNumber *)lineHeightNumber {
    //    if (_caretYOffset != nil && _lineHeight != nil &&
    //        [_caretYOffset isEqualToNumber:caretYOffsetNumber] && [_lineHeight isEqualToNumber:lineHeightNumber]) {
    //        return;
    //    }
    self.caretYOffset = caretYOffsetNumber;
    self.lineHeight = lineHeightNumber;
    [self scrollToCaretAnimated:animated caretYOffset:caretYOffsetNumber lineHeight:lineHeightNumber];
}

#pragma mark - Viewport rect
- (CGRect)viewport {
    UIScrollView* scrollView = _editorWebView.scrollView;

    CGRect viewport;

    viewport.origin = scrollView.contentOffset;
    viewport.size = scrollView.bounds.size;

    viewport.size.height -= (scrollView.contentInset.top + scrollView.contentInset.bottom);
    viewport.size.width -= (scrollView.contentInset.left + scrollView.contentInset.right);

    return viewport;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];

    BOOL shouldLoad = NO;

    if (navigationType != UIWebViewNavigationTypeLinkClicked) {
        BOOL handled = [self handleWebViewCallbackURL:url];
        shouldLoad = !handled;
    }

    return shouldLoad;
}

#pragma mark - callback parsing
- (NSMutableDictionary *)parseParamsFromCallbackURL:(NSURL *) url {
    NSArray * paramsGroup = [[url resourceSpecifier] componentsSeparatedByString:TTRCTRichEditorViewCallbackParamsGroupSeperator];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];

    for (NSString * group in paramsGroup) {
        NSArray * pair = [group componentsSeparatedByString:TTRCTRichEditorViewCallbackParamsPairSeperator];
        [params setValue:pair[1] forKey:pair[0]];
    }
    return params;
}

- (NSMutableDictionary *)parseParamsFromGetHtmlResponseURL:(NSURL *) url
                                               fieldLength:(NSUInteger)fieldLength {
    NSString * urlString = [[url resourceSpecifier] URLDecodedString];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];

    for (NSUInteger i = 0; i < fieldLength; i ++) {
        NSString * group;

        if (i != fieldLength - 1) {
            NSRange range = [urlString rangeOfString:TTRCTRichEditorViewCallbackParamsGroupSeperator];
            if (range.length <= 0) {
                break;
            }
            group = [urlString substringToIndex:range.location];
            urlString = [urlString substringFromIndex:range.location + range.length];
            NSArray * pair = [group componentsSeparatedByString:TTRCTRichEditorViewCallbackParamsPairSeperator];
            [params setValue:pair[1] forKey:pair[0]];
        } else {
            NSRange range = [urlString rangeOfString:TTRCTRichEditorViewCallbackParamsPairSeperator];
            [params setValue:[urlString substringFromIndex:range.length + range.location] forKey:[urlString substringToIndex:range.location]];
        }
    }

    return params;
}

- (void)scrollToCaretFromCallbackURL:(NSURL *)url {
    NSMutableDictionary * params = [self parseParamsFromCallbackURL:url];
    [self scrollToCaretAnimatedIfNecessary:NO
                              caretYOffset:@([[params objectForKey:@"yOffset"] floatValue])
                                lineHeight:@([[params objectForKey:@"height"] floatValue])];
}

- (BOOL)throttlingShouldCall:(NSDate *)lastCall time:(NSTimeInterval)time {
    NSDate * now = [NSDate date] ;
    if (lastCall && [[lastCall dateByAddingTimeInterval:time] compare:now] == NSOrderedDescending) {
        return NO;
    }
    return YES;
}

@end
