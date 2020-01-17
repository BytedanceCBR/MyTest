//
//  TTWrongWordsReportViewController.m
//  TTUIWidget
//
//  Created by chenbb6 on 2019/10/24.
//

#import "TTWrongWordsReportViewController.h"
#import <TTThemed/SSThemed.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>

@interface TTWrongWordsReportViewController () <UITextFieldDelegate>

//具体的UI
@property (nonatomic,strong) TTAlphaThemedButton *closeBtn;
@property (nonatomic,strong) SSThemedButton *confrimBtn;
@property (nonatomic,strong) SSThemedButton *cancelBtn;
@property (nonatomic,strong) SSThemedLabel *titleLabel;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) SSThemedView *separatorLine;
@property (nonatomic,strong) SSThemedTextField *inputTextField;

@property (nonatomic,copy) NSString *tipLabelText;

@end

@implementation TTWrongWordsReportViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithTips:(NSString *)tips {
    self = [super init];
    if (self) {
        self.tipLabelText = tips;
        [self registerNotification];
        [self setUpGuideView];
        [self layoutGuideView];
    }
    return self;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.inputTextField];
}

#pragma mark -- View

- (void)setUpGuideView {
    // 黑色背景图
    self.backView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    self.backView.backgroundColor = [UIColor blackColor];
    self.backView.alpha = 0.4;
    [self.view addSubview:self.backView];

    self.wrapperView = [[SSThemedView alloc] init];
    self.wrapperView.backgroundColorThemeKey = kColorBackground4;
    self.wrapperView.clipsToBounds = YES;
    [self.view addSubview:self.wrapperView];

    self.titleLabel = [[SSThemedLabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:19]];
    self.titleLabel.textColorThemeKey = kColorText1;
    self.titleLabel.text = self.title ?: @"反馈错别字";
    [self.wrapperView addSubview:self.titleLabel];

    self.tipLabel = [[SSThemedLabel alloc] init];
    self.tipLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    self.tipLabel.textColor = [UIColor colorWithHexString:@"#505050"];
    self.tipLabel.text = @"我们非常重视您的反馈，正确的字是：";
    self.tipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.tipLabel.numberOfLines = 3;
    [self.wrapperView addSubview:self.tipLabel];

    self.inputTextField = [[SSThemedTextField alloc] init];
    self.inputTextField.placeholder = @"请输入正确的字：";
    self.inputTextField.borderColorThemeKey = kColorText3;
    self.inputTextField.layer.borderWidth = 1.0f;
    self.inputTextField.layer.borderColor = [UIColor colorWithHexString:@"E8E8E8"].CGColor;
    self.inputTextField.layer.cornerRadius = 2.0f;
    self.inputTextField.edgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    self.inputTextField.placeholderColorThemeKey = kColorText3;
    self.inputTextField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    self.inputTextField.delegate = self;
    [self.wrapperView addSubview:self.inputTextField];

    self.closeBtn = [[TTAlphaThemedButton alloc] init];
    self.closeBtn.backgroundColorThemeKey = kColorBackground4;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTUIWidgetResources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    self.closeBtn.imageBundle = bundle;
    self.closeBtn.imageName = @"report_close_icon";
    [self.closeBtn addTarget:self action:@selector(onClickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.wrapperView addSubview:self.closeBtn];

    self.separatorLine = [[SSThemedView alloc] init];
    self.separatorLine.backgroundColorThemeKey = kColorLine1;
    [self.wrapperView addSubview:self.self.separatorLine];

    self.confrimBtn = [[SSThemedButton alloc] init];
    self.confrimBtn.titleColorThemeKey = kColorText7;
    self.confrimBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
    [self.confrimBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confrimBtn addTarget:self action:@selector(onClickedConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.confrimBtn setBackgroundColor:[UIColor colorWithHexString:@"FF5E5E"]];
    [self.wrapperView addSubview:self.confrimBtn];

    self.cancelBtn = [[SSThemedButton alloc] init];
    self.cancelBtn.backgroundColorThemeKey = kColorBackground4;
    self.cancelBtn.titleColorThemeKey = kColorText2;
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(onClickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.wrapperView addSubview:self.cancelBtn];
}

- (void)layoutGuideView {
    self.backView.left = 0;
    self.backView.top = 0;
    self.backView.width = self.view.width;
    self.backView.height = self.view.height;

    self.wrapperView.width = [TTDeviceUIUtils tt_padding:270];
    self.wrapperView.layer.cornerRadius = [TTDeviceUIUtils tt_padding:6];
    self.wrapperView.centerY = self.view.height/2;
    self.wrapperView.centerX = self.view.width/2;

    self.closeBtn.width = [TTDeviceUIUtils tt_padding:24];
    self.closeBtn.height = [TTDeviceUIUtils tt_padding:24];
    self.closeBtn.right = self.wrapperView.width - [TTDeviceUIUtils tt_padding:6];
    self.closeBtn.top =  [TTDeviceUIUtils tt_padding:8];
    self.closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-12, -12, -12, -12);

    [self.titleLabel sizeToFit];
    self.titleLabel.height = [TTDeviceUIUtils tt_fontSize:18];
    self.titleLabel.centerX = self.wrapperView.width/2;
    self.titleLabel.top = [TTDeviceUIUtils tt_padding:28];

    self.tipLabel.text = self.tipLabelText;
    self.tipLabel.width = self.wrapperView.width - [TTDeviceUIUtils tt_padding:40];
    self.tipLabel.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_padding:20];
    self.tipLabel.left = [TTDeviceUIUtils tt_padding:20];
    self.tipLabel.height = 0;
    [self tt_sizeToFitForLabel:self.tipLabel];

    self.inputTextField.top = self.tipLabel.bottom + [TTDeviceUIUtils tt_padding:12];
    self.inputTextField.centerX = self.wrapperView.width/2;
    self.inputTextField.width = self.wrapperView.width - [TTDeviceUIUtils tt_padding:40];
    self.inputTextField.height = [TTDeviceUIUtils tt_padding:36];

    self.separatorLine.width = self.wrapperView.width;
    self.separatorLine.height = 0.5;
    self.separatorLine.top = self.inputTextField.bottom + [TTDeviceUIUtils tt_padding:24];
    self.separatorLine.left = 0;

    self.confrimBtn.width = self.wrapperView.width/2;
    self.confrimBtn.height = [TTDeviceUIUtils tt_padding:44];
    self.confrimBtn.right = self.wrapperView.width;
    self.confrimBtn.top = self.separatorLine.bottom;

    self.cancelBtn.width = self.wrapperView.width/2;
    self.cancelBtn.height = [TTDeviceUIUtils tt_padding:44];
    self.cancelBtn.left = 0;
    self.cancelBtn.top =  self.separatorLine.bottom;

    self.wrapperView.height = self.cancelBtn.bottom;
}

- (void)configWithTips:(NSString *)tips {
    self.tipLabelText = tips;
    [self layoutGuideView];
    [self.inputTextField becomeFirstResponder];
}

#pragma mark - Actions

- (void)onClickedCancelButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(wrongWordsReportViewControllerDidClickedCancelButton:)]) {
        [self.delegate wrongWordsReportViewControllerDidClickedCancelButton:self];
    }
}

- (void)onClickedConfirmButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(wrongWordsReportViewControllerDidClickedConfirmButton:)]) {
        [self.delegate wrongWordsReportViewControllerDidClickedConfirmButton:self];
    }
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    __block CGRect rect = self.wrapperView.frame;

    if (CGRectGetMaxY(rect) > screenHeight - keyboardSize.height) {

        CGFloat y = (screenHeight - keyboardSize.height - rect.size.height) / 2;
        if (y < 0) {
            y = 0;
        }
        rect.origin.y = y;

        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.wrapperView.frame = rect;
                         }
                         completion:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
        [self layoutGuideView];
                             }
                             completion:nil];
}

- (void)textFieldDidChange:(NSNotification *)notification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wrongWordsReportViewControllerTextFieldDidChange:)]) {
        [self.delegate wrongWordsReportViewControllerTextFieldDidChange:self.inputTextField.text];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger textLen = [textField text].length;
    NSUInteger insertLen = string.length - range.length;
    NSUInteger nextTextLen = textLen + insertLen;
    if (nextTextLen >= 18) {
        return NO;
    }
    return YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputTextField resignFirstResponder];
}

#pragma mark - Private

- (void)tt_sizeToFitForLabel:(UILabel *)label {
    CGRect frame = label.frame;
    [label sizeToFit];
    frame.size.height = label.frame.size.height;
    [label setFrame: frame];
}

@end
