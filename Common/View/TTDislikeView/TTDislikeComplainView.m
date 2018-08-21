//
//  TTDislikeComplainView.m
//  Article
//
//  Created by zhaoqin on 05/03/2017.
//
//

#import "TTDislikeComplainView.h"
#import "TTActionSheetTitleView.h"
#import "SSThemed.h"
#import "TTActionSheetAnimated.h"



@interface TTDislikeComplainView ()<UITextViewDelegate>
@property (nonatomic, strong) TTActionSheetTitleView *titleView;
@property (nonatomic, strong) SSThemedTextView *inputTextView;
@property (nonatomic, strong) SSThemedButton *finishedButton;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) NSMutableDictionary *extraDict;
@end

@implementation TTDislikeComplainView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleView];
        [self addSubview:self.inputTextView];
        [self addSubview:self.finishedButton];
        [self setBackgroundColor:[UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"]];
                
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;
    self.titleView.width = screenWidth;
    self.inputTextView.frame = CGRectMake(padding + [TTDeviceUIUtils tt_padding:14.f], TTActionSheetNavigationBarHeight, width - (2 * [TTDeviceUIUtils tt_padding:14.f]), 62.f);
    self.finishedButton.right = self.inputTextView.right;

}

- (void)willAppear {
    [self.inputTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.f];
}

#pragma mark - TTDislikeComplainView
- (void)insertExtraDict:(NSMutableDictionary * _Nullable)extraDict {
    self.extraDict = extraDict;
    self.inputTextView.text = [self.extraDict tt_stringValueForKey:@"criticism"];
    if (self.inputTextView.text.length > 0) {
        self.finishedButton.enabled = YES;
    }
    else {
        self.finishedButton.enabled = NO;
    }
}

#pragma mark - TTKeyboardListener

- (void)keyboardWillShow:(NSNotification *)notification {
    self.keyboardHeight = CGRectGetHeight([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    if (self.showKeyboardComeplete) {
        self.showKeyboardComeplete(self.keyboardHeight);
    }
}

- (void)keyboardDidHide {
    if (self.dismissKeyboardComeplete) {
        self.dismissKeyboardComeplete();
    }
}

#pragma mark - get method
- (TTActionSheetTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[TTActionSheetTitleView alloc] init];
        _titleView.title = @"我要吐槽";
        WeakSelf;
        [_titleView.backButton addTarget:self withActionBlock:^{
            StrongSelf;
            if (self.dismissComplete) {
                [self.inputTextView endEditing:YES];
                self.dismissComplete();
            }
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _titleView;
}

- (SSThemedTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[SSThemedTextView alloc] init];
        _inputTextView.frame = CGRectMake([TTDeviceUIUtils tt_padding:14.f], TTActionSheetNavigationBarHeight, self.width - (2 * [TTDeviceUIUtils tt_padding:14.f]), 62.f);
        _inputTextView.delegate = self;
        _inputTextView.textContainerInset = UIEdgeInsetsMake(8.f, 8.f, 0, 6.f);
        _inputTextView.textAlignment = NSTextAlignmentLeft;
        _inputTextView.placeHolderEdgeInsets = UIEdgeInsetsMake(0, 8.f, 0, 0);
        _inputTextView.placeHolder = @"请具体说明问题，我们将尽快处理";
        _inputTextView.placeHolderColor = [UIColor tt_themedColorForKey:kColorText3];
        _inputTextView.placeHolderFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]];
        _inputTextView.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _inputTextView.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
        _inputTextView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _inputTextView.layer.cornerRadius = 4.f;
        [_inputTextView setBackgroundColor:[UIColor tt_themedColorForKey:kColorBackground4]];
        [_inputTextView setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]]];
        
    }
    return _inputTextView;
}

- (SSThemedButton *)finishedButton {
    if (!_finishedButton) {
        _finishedButton = [[SSThemedButton alloc] init];
        _finishedButton.frame = CGRectMake(0, self.inputTextView.bottom + 8, [TTDeviceUIUtils tt_newPadding:57.f], [TTDeviceUIUtils tt_newPadding:28.f]);
        _finishedButton.right = self.inputTextView.right;
        [_finishedButton setTitle:@"发表" forState:UIControlStateNormal];
        _finishedButton.clipsToBounds = YES;
        _finishedButton.layer.cornerRadius = 6;
        [_finishedButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_finishedButton setEnabled:YES];
        [_finishedButton setBackgroundImage:[UIImage imageWithUIColor:[UIColor colorWithDayColorName:@"2a90d7" nightColorName:@"67778b"]] forState:UIControlStateNormal];
        WeakSelf;
        [_finishedButton addTarget:self withActionBlock:^{
            StrongSelf;
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            if (self.sendComplainComplete) {
                self.sendComplainComplete();
            }
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _finishedButton;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self.extraDict setValue:textView.text forKey:@"criticism"];
    if (self.inputTextView.text.length > 0) {
        self.finishedButton.enabled = YES;
    }
    else {
        self.finishedButton.enabled = NO;
    }
    if (self.hasComplainMessage) {
        self.hasComplainMessage(self.finishedButton.enabled);
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    //Has Focus
    return YES;
}


@end
