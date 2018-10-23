//
//  TTRCTRichEditorView.h
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#ifndef TTRCTRichEditorView_h
#define TTRCTRichEditorView_h

#import "TTPGCEventController.h"

@protocol TTRCTRichEditorViewDelegate <NSObject>

@optional
- (void) on:(NSString*)eventName data:(id)data;

@end

@interface TTRCTRichEditorView : UIView<UIWebViewDelegate>

#pragma mark - webview related
@property (nonatomic, strong) UIWebView * editorWebView;
@property (nonatomic, weak) id<TTRCTRichEditorViewDelegate> delegate;

// dictionary turning callback scheme to event name
@property (nonatomic, strong) NSMutableDictionary * callbackSchemeToEventName;

@property (nonatomic, readonly, assign) BOOL isDomLoaded;
@property (nonatomic, readonly, assign) BOOL isEditing;
@property (nonatomic, readonly, assign) BOOL isFocused;

#pragma mark - functions
- (BOOL)evaluateJavascript:(NSString *)js;
- (BOOL)evaluateJavascript:(NSString *)js
               ignoreRange:(BOOL)ignoreRange;
- (BOOL)hideKeyboard;
- (BOOL)showKeyboard;

@end

#endif /* TTRCTRichEditorView_h */
