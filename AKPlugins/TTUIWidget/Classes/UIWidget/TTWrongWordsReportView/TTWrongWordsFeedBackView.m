//
//  TTWrongWordsFeedBackView.m
//  TTUIWidget
//
//  Created by chenbb6 on 2019/10/24.
//

#import "TTWrongWordsFeedBackView.h"
#import <TTUIWidget/TTIndicatorView.h>
#import <TTKitchen/TTKitchenManager.h>
#import <TTKitchenExtension/TTKitchenExtension.h>
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import <TTInstallService/TTInstallIDManager.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <WebKit/WebKit.h>

@interface TTWrongWordsFeedBackView()<TTWrongWordsReportViewControllerDelegate>

@property (nonatomic, strong) TTWrongWordsReportModel *model;
@property (nonatomic, assign) BOOL canShow;
@property (nonatomic, strong) NSMutableDictionary *extraDic;
@property (nonatomic, copy) NSString *displayMessage;

@end

@implementation TTWrongWordsFeedBackView

- (instancetype)initWithModel:(TTWrongWordsReportModel *)model {
    self = [super init];
    if (self) {
        [self configWithModel:model];
        self.canShow = NO;
    }
    return self;
}

#pragma mark -- Public

- (void)configWithModel:(TTWrongWordsReportModel *)model {
    self.model = model;

    NSString *repoWrongWords;
    self.extraDic = [[NSMutableDictionary alloc] init];
    if (self.model.wrongWordsSelectedArray && self.model.wrongWordsSelectedArray.count == 3) {
        [self.extraDic setObject:[self array2JsonString:self.model.wrongWordsSelectedArray] forKey:@"wrong_words"];
        repoWrongWords = [self.model.wrongWordsSelectedArray objectAtIndex:1];
        repoWrongWords = [self wrongWordsRemoveNewLine:repoWrongWords];
    }
    self.canShow = NO;
    if (!repoWrongWords) {
        return;
    } else if (repoWrongWords.length > 18) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"选择字数过多，最多选择18个字" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    } else if (![TTKitchen getBOOL:kTTKitchenArticleReportTyposEnabled]) {
        TTReportContentModel *reportModel = model.contentModel;
        [self.extraDic setValue:@"" forKey:@"extra"];
        [[TTReportManager shareInstance] startReportContentWithType:@"12" inputText:nil contentType:model.contentType reportFrom:TTReportFromByEnterFromAndCategory(self.model.enterFrom, self.model.categoryId) contentModel:reportModel extraDic:self.extraDic animated:YES];
    } else {
        // 展示反馈弹窗
        self.canShow = YES;
        self.displayMessage = [NSString stringWithFormat:@"反馈\"%@\"为错别字，正确的字是：", repoWrongWords];
    }
}

- (void)showAlert {
    if (self.isShowing || !self.canShow) {
        [self showAlertFailed];
        return;
    }
    self.isShowing = YES;

    self.originWindow = [UIApplication sharedApplication].keyWindow;

    if (!self.backWindow) {
        self.backWindow = [[UIWindow alloc] init];
        self.backWindow.frame = [UIApplication sharedApplication].keyWindow.bounds;
        self.backWindow.windowLevel = UIWindowLevelAlert;
        self.backWindow.hidden = YES;
        [self.backWindow setBackgroundColor:[UIColor clearColor]];
        self.backWindow.rootViewController = self.rootVC;
    }

    [self.backWindow makeKeyAndVisible];

    [self.rootVC configWithTips:self.displayMessage];
    self.rootVC.wrapperView.alpha = 0;
    self.rootVC.backView.alpha = 0;
    self.rootVC.wrapperView.transform = CGAffineTransformMakeScale(.00001f, .00001f);
    
    [UIView animateWithDuration:0.45
                          delay:0
         usingSpringWithDamping:0.78
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        self.rootVC.wrapperView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                        [self didShowAlert];
                     }];

    [UIView animateWithDuration:0.1 animations:^{
        self.rootVC.wrapperView.alpha = 1;
        self.rootVC.backView.alpha = 0.4;
    }];
}

+ (void)getSelectedTextOnWebView:(id)view complete:(void(^)(NSArray *text))complete {
    NSString *jsString = @"\
    function getThreeStrings (n) {\
        var one = '', two = '', three = '';\
        var sel = document.getSelection();\
        if (sel.type !== 'Range') {\
            return [one, two, three];\
        }\
        var range = sel.getRangeAt(0);\
        if (!range) {\
            return [one, two, three];\
        }\
        try {\
            one = range.startContainer.textContent.substring(0, range.startOffset).substr(-n);\
            two = range.toString();\
            three = range.endContainer.textContent.substring(range.endOffset).substring(0, n);\
        } catch (ex) {}\
        range.detach();\
        range = null;\
        return [one, two, three];\
    }\
    getThreeStrings(100);";
    // 深搜遍历子view
    WKWebView *wkWebView = [self getSubWebViewOnView:view];
    // 通过给WKWebView注入js，获取选中词及其上下文
    if ([wkWebView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
        [wkWebView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSArray *threeWrongWordsArray = result;
            if (complete && threeWrongWordsArray && [threeWrongWordsArray isKindOfClass:[NSArray class]]) {
                complete(threeWrongWordsArray);
            }
        }];
    }
}

+ (void)getSelectedTextOnNativeViewText:(NSString *)text currentSelectedRange:(NSRange)range complete:(void (^)(NSArray *))complete {
    //仿照着构造出来一个[one, two, three]
    NSUInteger prefixLoc;
    NSUInteger prefixLen;
    if (range.location > 100) {
        prefixLoc = range.location - 100;
        prefixLen = 100;
    } else {
        prefixLoc = 0;
        prefixLen = range.location;
    }

    NSRange prefixRange = NSMakeRange(prefixLoc, prefixLen);
    
    NSUInteger suffixLen = NSMaxRange(range) + 100 > text.length ? (text.length - NSMaxRange(range)) : 100;
    NSRange suffixRange = NSMakeRange(NSMaxRange(range), suffixLen);
    
    NSString *prefixStr = [text substringWithRange:prefixRange];
    NSString *currentStr = [text substringWithRange:range];
    NSString *suffixStr = [text substringWithRange:suffixRange];
    NSArray *result = @[prefixStr, currentStr, suffixStr];
    
    if (complete && result && [result isKindOfClass:[NSArray class]]) {
        complete(result);
    }
}

#pragma mark - Private

- (void)dismissFinished:(void(^)(TTWrongWordsFeedBackView *view))block {
    [self.originWindow makeKeyAndVisible];

    [UIView animateWithDuration:0.1 animations:^{
        self.rootVC.wrapperView.alpha = 0;
        self.rootVC.backView.alpha = 0;
    } completion:^(BOOL finished) {
        self.rootVC.wrapperView.hidden = YES;
        self.rootVC.backView.hidden = YES;
        [self.rootVC.wrapperView.layer removeAllAnimations];
    }];

    [UIView animateWithDuration:0.45
                          delay:0
         usingSpringWithDamping:0.78
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        self.rootVC.wrapperView.transform = CGAffineTransformMakeScale(.00001f, .00001f);
                     }
                     completion:^(BOOL finished) {
                        [self.rootVC.view removeFromSuperview];
                        self.rootVC = nil;
                        self.backWindow.hidden = YES;
                        self.backWindow = nil;
                        self.backWindow.windowLevel = UIWindowLevelNormal;
                        self.isShowing = NO;

                        if (block) {
                            block(self);
                        }
                     }];
}

- (void)logWrongWordsClickWithButton:(NSString *)button {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.model.contentModel.groupID forKey:@"group_id"];
    [params setValue:self.model.contentModel.itemID forKey:@"item_id"];
    [params setValue:self.model.enterFrom forKey:@"enter_from"];
    [params setValue:self.model.categoryId forKey:@"category_name"];
    [params setValue:button forKey:@"button"];
    [BDTrackerProtocol eventV3:@"wrong_words_click" params:params];
}

- (NSString *)array2JsonString:(NSArray *) array {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (void)didShowAlert {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wrongWordsFeedBackViewDidShowAlert:)]) {
        [self.delegate wrongWordsFeedBackViewDidShowAlert:self];
    }
}

- (void)showAlertFailed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wrongWordsFeedBackViewShowAlertFailed:)]) {
        [self.delegate wrongWordsFeedBackViewShowAlertFailed:self];
    }
}

/// 反馈弹窗显示上，清除'\t','\r','\n'等字符
/// @param wrongWords 原错别字
- (NSString *)wrongWordsRemoveNewLine:(NSString *)wrongWords {
    NSString *newWrongWords = [wrongWords copy];
    newWrongWords = [newWrongWords stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    newWrongWords = [newWrongWords stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    newWrongWords = [newWrongWords stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return newWrongWords;
}

/// 深搜遍历subview获取webview
+ (WKWebView *)getSubWebViewOnView:(UIView *)view {
    NSArray *subViews = [view subviews];
    for (id subView in subViews) {
        if ([subView isKindOfClass:[WKWebView class]]) {
            return subView;
        }
        return [self getSubWebViewOnView:subView];
    }
    return nil;
}


#pragma mark - TTWrongWordsReportViewControllerDelegate

- (void)wrongWordsReportViewControllerDidClickedConfirmButton:(TTWrongWordsReportViewController *)controller {
    [self dismissFinished:^(TTWrongWordsFeedBackView *view) {
        if (view.delegate && [view.delegate respondsToSelector:@selector(wrongWordsFeedBackViewDidClickedConfirmButton:)]) {
            [view.delegate wrongWordsFeedBackViewDidClickedConfirmButton:view];
        }
    }];
    [self logWrongWordsClickWithButton:@"confirm"];
    [self.extraDic setValue:self.model.extra forKey:@"extra"];
    if (!isEmptyString(self.model.repoRightWords)) {
        NSArray *correctWords = [NSArray arrayWithObjects:@"",self.model.repoRightWords,@"",nil];
        [self.extraDic setValue:[self array2JsonString:correctWords] forKey:@"correct_words"];
    }
    [self.extraDic setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    [[TTReportManager shareInstance] startReportContentWithType:@"12" inputText:nil contentType:self.model.contentType reportFrom:TTReportFromByEnterFromAndCategory(self.model.enterFrom, self.model.categoryId) contentModel:self.model.contentModel extraDic:self.extraDic animated:YES];
}

- (void)wrongWordsReportViewControllerDidClickedCancelButton:(TTWrongWordsReportViewController *)controller {
    [self dismissFinished:^(TTWrongWordsFeedBackView *view) {
        if (view.delegate && [view.delegate respondsToSelector:@selector(wrongWordsFeedBackViewDidClickedCancelButton:)]) {
            [view.delegate wrongWordsFeedBackViewDidClickedCancelButton:view];
        }
    }];
    [self logWrongWordsClickWithButton:@"cancel"];
}

- (void)wrongWordsReportViewControllerTextFieldDidChange:(NSString *)text {
    self.model.repoRightWords = text;
}

#pragma mark - Getter

- (TTWrongWordsReportViewController *)rootVC {
    if (!_rootVC) {
        _rootVC = [[TTWrongWordsReportViewController alloc] initWithTips:self.displayMessage];
        _rootVC.delegate = self;
    }
    return _rootVC;
}

@end
