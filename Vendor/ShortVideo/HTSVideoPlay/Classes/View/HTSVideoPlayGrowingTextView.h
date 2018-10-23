//
//  HTSVideoPlayGrowingTextView.h
//  Pods
//
//  Created by pc on 2017/4/21.
//
//  copyed from HPGrowingTextView
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
// UITextAlignment is deprecated in iOS 6.0+, use NSTextAlignment instead.
// Reference: https://developer.apple.com/library/ios/documentation/uikit/reference/NSString_UIKit_Additions/Reference/Reference.html
#define NSTextAlignment UITextAlignment
#endif

@class HTSVideoPlayGrowingTextView;
@class HTSVideoPlayTextViewInternal;

@protocol HTSVideoPlayGrowingTextViewDelegate <NSObject>

@optional
- (BOOL)growingTextViewShouldBeginEditing:(HTSVideoPlayGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(HTSVideoPlayGrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(HTSVideoPlayGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(HTSVideoPlayGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(HTSVideoPlayGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(HTSVideoPlayGrowingTextView *)growingTextView;

- (void)growingTextView:(HTSVideoPlayGrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(HTSVideoPlayGrowingTextView *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(HTSVideoPlayGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(HTSVideoPlayGrowingTextView *)growingTextView;
@end

@interface HTSVideoPlayGrowingTextView : SSThemedView <UITextViewDelegate> {
    HTSVideoPlayTextViewInternal *internalTextView;
    
    int minHeight;
    int maxHeight;
    
    //class properties
    int maxNumberOfLines;
    int minNumberOfLines;
    
    BOOL animateHeightChange;
    NSTimeInterval animationDuration;
    
    //uitextview properties
    NSObject <HTSVideoPlayGrowingTextViewDelegate> *__weak delegate;
    NSTextAlignment textAlignment;
    NSRange selectedRange;
    BOOL editable;
    UIDataDetectorTypes dataDetectorTypes;
    UIReturnKeyType returnKeyType;
    UIKeyboardType keyboardType;
    
    UIEdgeInsets contentInset;
}

//real class properties
@property int maxNumberOfLines;
@property int minNumberOfLines;
@property (nonatomic) int maxHeight;
@property (nonatomic) int minHeight;
@property BOOL animateHeightChange;
@property NSTimeInterval animationDuration;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UITextView *internalTextView;


//uitextview properties
@property(weak) NSObject<HTSVideoPlayGrowingTextViewDelegate> *delegate;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) UIFont *font;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic) NSTextAlignment textAlignment;    // default is NSTextAlignmentLeft
@property(nonatomic) NSRange selectedRange;            // only ranges of length 0 are supported
@property(nonatomic,getter=isEditable) BOOL editable;
@property(nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) UIKeyboardType keyboardType;
@property (assign) UIEdgeInsets contentInset;
@property (nonatomic) BOOL isScrollable;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer;
#endif

//uitextview methods
//need others? use .internalTextView
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;

// call to force a height change (e.g. after you change max/min lines)
- (void)refreshHeight;


@end
