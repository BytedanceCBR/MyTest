//
//  TTSeachBarView.m
//  Article
//
//  Created by SunJiangting on 14-9-10.
//
//

#import "TTSeachBarView.h"
#import "TTTracker.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"

#define kSearchBarLeftPad 15

const CGFloat kCancelButtonPadding = 7;

@implementation TTSeachBarView


- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    if (frame.size.width < TTSeachBarViewDefaultSize.width) {
        frame.size.width = TTSeachBarViewDefaultSize.width;
    }
    if (frame.size.height < TTSeachBarViewDefaultSize.height) {
        frame.size.height = TTSeachBarViewDefaultSize.height;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.contentView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.contentView];
        
        self.cancelButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(self.width, 0, 50, self.frame.size.height)];
        self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.];
        self.cancelButton.titleColorThemeKey = kColorText6;
        self.cancelButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(searchBarCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
        
        CGRect contentFrame = self.contentView.bounds;
        self.inputBackgroundView = [[SSThemedButton alloc] initWithFrame:CGRectMake(kSearchBarLeftPad, 8, contentFrame.size.width - kSearchBarLeftPad*2, contentFrame.size.height - 16)];
        self.inputBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.inputBackgroundView.layer.cornerRadius = 4;
        self.inputBackgroundView.layer.masksToBounds = YES;
        self.inputBackgroundView.backgroundColorThemeKey = kColorBackground4;
        //self.inputBackgroundView.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        self.inputBackgroundView.borderColorThemeKey = kColorLine1;
        self.inputBackgroundView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.inputAccessoryView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self.contentView addSubview:self.inputBackgroundView];
        
        self.searchImageView = [[SSThemedImageView alloc] init];
        self.searchImageView.imageName = @"search_small";
        [self.searchImageView sizeToFit];
        self.searchImageView.left = 8;
        self.searchImageView.top = (self.inputBackgroundView.height - self.searchImageView.height) / 2;
        self.searchImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.searchImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.inputBackgroundView addSubview:self.searchImageView];

        
        self.closeButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        self.closeButton.frame = CGRectMake((self.inputBackgroundView.width) - 22, 7, 14, 14);
        self.closeButton.backgroundImageName = @"clear_icon";
        self.closeButton.highlightedBackgroundImageName = @"clear_icon";
        self.closeButton.hidden = YES;
        [self.inputBackgroundView addSubview:self.closeButton];
        [self.closeButton addTarget:self action:@selector(clearSearchText:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 调整输入框大小->输入框被遮挡
        self.searchField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(32, 4, self.closeButton.left - 15 - self.searchImageView.right, (self.inputBackgroundView.height) - 8)];
        self.searchField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        self.searchField.clearButtonMode = UITextFieldViewModeNever;
        self.searchField.backgroundColor = [UIColor clearColor];
        self.searchField.delegate = self;
        self.searchField.textColorThemeKey = kColorText1;
        self.searchField.font = [UIFont systemFontOfSize:14.];
        self.searchField.placeholderColorThemeKey = kColorText14;
        self.searchField.returnKeyType = UIReturnKeySearch;
        [self.inputBackgroundView addSubview:self.searchField];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeText:) name:UITextFieldTextDidChangeNotification object:self.searchField];
        
        self.showsCancelButton = NO;
        
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
        self.bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:self.bottomLineView];
        
    }
    return self;
}

- (void) clearSearchText:(id) sender {
    self.text = nil;
    [self.searchField becomeFirstResponder];
    /////// 友盟统计
    ttTrackEvent(@"search_tab", @"clear_input");
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:nil];
    }
}

- (void) setShowsCancelButton:(BOOL)showsCancelButton {
    _showsCancelButton = showsCancelButton;
    self.cancelButton.hidden = !showsCancelButton;
}

- (void) setEditing:(BOOL) editing {
    [self setEditing:editing animated:NO];
}

- (void) setEditing:(BOOL) editing animated:(BOOL) animated {
    if (editing) {
        [self becomeFirstResponder];
    } else {
        [self resignFirstResponder];
    }
    if (editing == _editing) {
        return;
    }
    CGRect initialContentFrame = self.contentView.frame, targetContentFrame = self.contentView.frame;
    initialContentFrame.size.width = self.width - _editing * (self.cancelButton.width) * self.showsCancelButton;
    targetContentFrame.size.width = self.width - editing * (self.cancelButton.width) * self.showsCancelButton;
    
    CGRect initialCancelFrame = self.cancelButton.frame, targetCancelFrame = self.cancelButton.frame;
    initialCancelFrame.origin.x = self.width - _editing * ((self.cancelButton.width) + kCancelButtonPadding) * self.showsCancelButton;
    targetCancelFrame.origin.x = self.width - editing * ((self.cancelButton.width) + kCancelButtonPadding) * self.showsCancelButton;
    
    void(^animations)(void) = ^{
        self.contentView.frame = targetContentFrame;
        self.cancelButton.frame = targetCancelFrame;
    };
    if (animated) {
        self.contentView.frame = initialContentFrame;
        self.cancelButton.frame = initialCancelFrame;
        [UIView animateWithDuration:0.25 animations:animations];
    } else {
        animations();
    }
    _editing = editing;
}

- (void) setText:(NSString *)text {
    self.searchField.text = text;
    [self displayTextRightView];
}

- (void) displayTextRightView {
    self.closeButton.hidden = self.searchField.text.length == 0;
}

- (NSString *) text {
    return self.searchField.text;
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return [self.searchField canBecomeFirstResponder];
}// default is NO
- (BOOL)becomeFirstResponder {
    return [self.searchField becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return [self.searchField canResignFirstResponder];
}// default is YES

- (BOOL)resignFirstResponder {
    [self.searchField resignFirstResponder];
    return [super resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return self.searchField.isFirstResponder;
}

- (void) searchBarCancelButtonClicked:(id) sender {
    [self resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

- (void) textFieldDidChangeText:(NSNotification *) notification {
    [self displayTextRightView];
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:self.searchField.text];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL shouldBeginEditing = YES;
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        shouldBeginEditing = [self.delegate searchBarShouldBeginEditing:self];
    }
    return shouldBeginEditing;
}// return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setEditing:YES animated:NO];
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}// became first responder
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL shouldEndEditing = YES;
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        shouldEndEditing = [self.delegate searchBarShouldEndEditing:self];
    }
    return shouldEndEditing;
}// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [self.delegate searchBarTextDidEndEditing:self];
    }
}// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChange = YES;
    if ([self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        shouldChange = [self.delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
    }
    return shouldChange;
}// return NO to not change text

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return NO;
}// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.delegate searchBarSearchButtonClicked:self];
    }
    return YES;
}// called when 'return' key pressed. return NO to ignore.

@end

CGSize const TTSeachBarViewDefaultSize = {320, 44};
