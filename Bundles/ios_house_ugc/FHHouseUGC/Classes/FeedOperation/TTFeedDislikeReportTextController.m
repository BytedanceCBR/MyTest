//
//  TTActionSheetTextController.m
//  Article
//
//  Created by zhaoqin on 8/30/16.
//
//

#import "TTFeedDislikeReportTextController.h"
#import "TTActionSheetConst.h"
#import "TTActionSheetAnimated.h"
#import "TTActionSheetTitleView.h"
#import "TTActionSheetManager.h"

#import "TTKeyboardListener.h"
#import "SSThemed.h"
#import "TTUIResponderHelper.h"
#import "TTDeviceHelper.h"
#import "UITextView+TTAdditions.h"
#import "UIViewAdditions.h"
#import "TTDeviceUIUtils.h"
#import "UIImageAdditions.h"
#import "UIButton+TTAdditions.h"
#import "extobjc.h"

#import "TTGroupModel.h"
#import "TTReportManager.h"
#import "TTReportContentModel.h"

#import "UIImage+TTThemeExtension.h"
#import "FHFeedOperationView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@interface TTFeedDislikeReportTextController ()<UITextViewDelegate>

@property (nonatomic, strong) TTKeyboardListener *keyboardListener;

@property (nonatomic, strong) SSThemedButton *backButton;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedButton *finishedButton;
@property (nonatomic, strong) SSThemedView *topSeparator;
@property (nonatomic, strong) SSThemedTextView *inputTextView;
@property (nonatomic, strong) SSThemedLabel *inputCounterLabel;

@end
 
@implementation TTFeedDislikeReportTextController

static UIWindow *alertWindow;

+ (void)triggerTextReportProcessCompleted:(void (^)(NSString *))completed {
    if (alertWindow) return;
    alertWindow = ({
        UIWindow *w = [UIWindow new];
        w.windowLevel = UIWindowLevelAlert;
        w.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        w.alpha = 0.0;
        w;
    });
    
    UINavigationController *nav = [UINavigationController new];
    nav.navigationBarHidden = YES;
    alertWindow.rootViewController = nav;
    [alertWindow makeKeyAndVisible];
    
    TTFeedDislikeReportTextController *vc = [TTFeedDislikeReportTextController new];
    vc.inputFinished = completed;
    [nav pushViewController:vc animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *maskingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMaskingTapped:)];
    [alertWindow addGestureRecognizer:maskingTap];
    
    _keyboardListener = [TTKeyboardListener sharedInstance];
    [self setupUI];
    [self layoutUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)onMaskingTapped:(UITapGestureRecognizer *)gstr {
    [self dismissWithMessage:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.inputTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.f];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutUI];
    [self refreshConerMasking];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)setupUI {
    [self.view setBackgroundColor:[UIColor colorWithDayColorName:@"ffffff" nightColorName:@"252525"]];
    
    _backButton = ({
        SSThemedButton *v = [SSThemedButton buttonWithType:UIButtonTypeSystem];
        [v setTitle:@"返回" forState:UIControlStateNormal];
        [v setImage:[UIImage themedImageNamed:@"feed_dislike_close" inBundle:FHFeedOperationView.resourceBundle] forState:UIControlStateNormal];
        v.tintColorThemeKey = kColorText1;
        [v addTarget:self action:@selector(onBackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        v;
    });
    [self.view addSubview:_backButton];
    
    _titleLabel = ({
        SSThemedLabel *v = [SSThemedLabel new];
        v.font = [UIFont boldSystemFontOfSize:17.0];
        v.text = @"我要吐槽";
        v.textColorThemeKey = kColorText1;
        v;
    });
    [self.view addSubview:_titleLabel];
    
    _finishedButton = ({
        SSThemedButton *v = [SSThemedButton buttonWithType:UIButtonTypeSystem];
        v.enabled = NO;
        [v setTitle:@"发布" forState:UIControlStateNormal];
        v.disabledTitleColorThemeKey = kColorText9;
        v.titleColorThemeKey = kColorBlueTextColor;
        [v setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        v.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [v addTarget:self action:@selector(onFinishButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        v;
    });
    [self.view addSubview:_finishedButton];
    
    _topSeparator = ({
        SSThemedView *v = [SSThemedView new];
        v.backgroundColorThemeKey = kColorLine1;
        v;
    });
    [self.view addSubview:_topSeparator];
    
    _inputTextView = ({
        SSThemedTextView *v = [[SSThemedTextView alloc] init];
        v.delegate = self;
        [v setBackgroundColor:[UIColor tt_themedColorForKey:kColorBackground4]];
        v.textAlignment = NSTextAlignmentLeft;
        v.textContainerInset = UIEdgeInsetsZero;
        v.textContainerInset = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0);
        // 由于控件 bug 导致只能这么处理
        v.placeHolderEdgeInsets = UIEdgeInsetsMake(15.0 - 8.0, 15.0, 15.0 - 8.0, 15.0);
        v.placeHolderColor = [UIColor tt_themedColorForKey:kColorText9];
        v.placeHolderFont = [UIFont systemFontOfSize:16.0];
        v.textColor = [UIColor tt_themedColorForKey:kColorText1];
        [v setFont:[UIFont systemFontOfSize:16.0]];
        v;
    });
    [self.view addSubview:_inputTextView];
    
    _inputCounterLabel = ({
        SSThemedLabel *v = [SSThemedLabel new];
        v.font = [UIFont systemFontOfSize:12.0];
        v.textAlignment = NSTextAlignmentRight;
        v.textColorThemeKey = kColorText9;
        v.text = @"0";
        v;
    });
    [self.view addSubview:_inputCounterLabel];
}

- (void)layoutUI {
    CGFloat padding = 15.0;
    CGFloat topOffset = 0.0;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.top = 13.0;
    self.titleLabel.centerX = self.view.centerX;
    topOffset = self.titleLabel.bottom;
    
    self.backButton.size = CGSizeMake(20.0, 20.0);
    self.backButton.left = padding;
    self.backButton.centerY = self.titleLabel.centerY;
    
    [self.finishedButton sizeToFit];
    self.finishedButton.right = self.view.width - padding;
    self.finishedButton.centerY = self.titleLabel.centerY;
    
    self.topSeparator.height = [TTDeviceHelper ssOnePixel];
    self.topSeparator.width = self.view.width;
    self.topSeparator.top = topOffset + 13.0;
    self.topSeparator.left = 0.0;
    topOffset = self.topSeparator.bottom;
    
    self.inputTextView.size = CGSizeMake(self.view.width, 110.0);
    self.inputTextView.top = topOffset;
    topOffset = self.inputTextView.bottom;
    
    // 由于控件 bug 导致只能这么处理
    self.inputTextView.placeHolder = @"请具体说明问题，我们将尽快处理";
    
    [self.inputCounterLabel sizeToFit];
    self.inputCounterLabel.width *= 4;
    self.inputCounterLabel.right = self.view.width - padding;
    self.inputCounterLabel.bottom = self.view.height - 15.0;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.navigationController.view.frame = CGRectMake(0, screenSize.height - topOffset, screenSize.width, topOffset);
}

/// 用于设置顶部圆角
- (void)refreshConerMasking {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6.0, 6.0)];
    CAShapeLayer *shap = [[CAShapeLayer alloc] init];
    [shap setPath:path.CGPath];
    self.view.layer.mask = shap;
}

- (void)dismissWithMessage:(NSString *)message {
    if (self.inputFinished)  self.inputFinished(message);
    [alertWindow endEditing:YES];
}

- (void)onBackButtonTapped:(UIButton *)sender {
    [self dismissWithMessage:nil];
}

- (void)onFinishButtonTapped:(UIButton *)sender {
    [self dismissWithMessage:self.inputTextView.text];
}

#pragma mark - TTKeyboardListener

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardH = CGRectGetHeight([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    CGRect toFrame = self.navigationController.view.frame;
    toFrame.origin.y = screenHeight - toFrame.size.height - keyboardH;
    [UIView animateWithDuration:TTActionSheetAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.navigationController.view.frame = toFrame;
        alertWindow.alpha = 1.0;
    } completion:nil];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    CGFloat keyboardH = CGRectGetHeight([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    CGRect toFrame = self.navigationController.view.frame;
    toFrame.origin.y += keyboardH;
    [UIView animateWithDuration:TTActionSheetAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.navigationController.view.frame = toFrame;
        alertWindow.alpha = 0.0;
    } completion:^(BOOL finished) {
        alertWindow = nil;
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.inputCounterLabel.text = [NSString stringWithFormat:@"%d", textView.text ? textView.text.length : 0];
    [self.inputTextView showOrHidePlaceHolderTextView];
    self.finishedButton.titleLabel.font = isEmptyString(textView.text) ? [UIFont systemFontOfSize:16.0] : [UIFont boldSystemFontOfSize:16.0];
    self.finishedButton.enabled = !isEmptyString(textView.text);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    return YES;
}


@end
