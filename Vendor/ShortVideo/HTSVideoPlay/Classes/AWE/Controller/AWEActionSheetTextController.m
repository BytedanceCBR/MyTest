//
//  TTActionSheetTextController.m
//  Article
//
//  Created by zhaoqin on 8/30/16.
//
//

#import "TTDeviceHelper.h"
#import "AWEActionSheetTextController.h"
#import "TTKeyboardListener.h"
#import "SSThemed.h"
#import "TTUIResponderHelper.h"
#import "AWEActionSheetConst.h"
#import "AWEActionSheetAnimated.h"
#import "AWEActionSheetTitleView.h"
#import "AWEVideoCommentDataManager.h"
#import "UIViewAdditions.h"
#import "UITextView+TTAdditions.h"
#import "TTDeviceHelper.h"
#import "UIButton+TTAdditions.h"
#import "UIColor+Theme.h"

@interface AWEActionSheetTextController ()<UITextViewDelegate>
@property (nonatomic, strong) TTKeyboardListener *keyboardListener;
@property (nonatomic, strong) SSThemedTextView *inputTextView;
@property (nonatomic, strong) SSThemedButton *finishedButton;
@property (nonatomic, assign) BOOL popLock;
@property (nonatomic, strong) AWEActionSheetTitleView *titleView;
@end
 
@implementation AWEActionSheetTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithDayColorName:@"ffffff" nightColorName:@"252525"]];
    
    self.titleView = [[AWEActionSheetTitleView alloc] init];
    if([@"video_report" isEqualToString:self.type]){
        self.titleView.title = @"我要吐槽";
    }else{
        self.titleView.title = @"我有话要说";
    }
    [self.view addSubview:self.titleView];
    
    _keyboardListener = [TTKeyboardListener sharedInstance];
    _inputTextView = [[SSThemedTextView alloc] init];
    _finishedButton = [[SSThemedButton alloc] init];
    [self.view addSubview:_inputTextView];
    [self.view addSubview:_finishedButton];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;
    
    self.inputTextView.frame = CGRectMake(14 + padding, AWEActionSheetNavigationBarHeight, width - (2 * 14), 62.f);
    self.inputTextView.delegate = self;
    self.inputTextView.textContainerInset = UIEdgeInsetsMake(8.f, 8.f, 0, 6.f);
    self.inputTextView.textAlignment = NSTextAlignmentLeft;
    self.inputTextView.placeHolderEdgeInsets = UIEdgeInsetsMake(0, 8.f, 0, 0);
    self.inputTextView.placeHolder = @"请具体说明问题，我们将尽快处理";
    self.inputTextView.placeHolderColor = [UIColor tt_themedColorForKey:@"grey3"];
    self.inputTextView.placeHolderFont = [UIFont systemFontOfSize:16];
    self.inputTextView.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.inputTextView.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.inputTextView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.inputTextView.layer.cornerRadius = 4.f;
    [self.inputTextView setBackgroundColor:[UIColor tt_themedColorForKey:@"grey7"]];
    [self.inputTextView setFont:[UIFont systemFontOfSize:16]];
    
    self.finishedButton.frame = CGRectMake(0, self.inputTextView.bottom + 8, 57, 28);
    self.finishedButton.right = self.inputTextView.right;
    [self.finishedButton setTitle:@"发表" forState:UIControlStateNormal];
    self.finishedButton.clipsToBounds = YES;
    self.finishedButton.layer.cornerRadius = 6;
    [self.finishedButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.finishedButton setEnabled:YES];
    
    [self.finishedButton setBackgroundImage:[AWEActionSheetTextController imageWithUIColor:[UIColor colorWithDayColorName:@"ff5869" nightColorName:@"67778b"]] forState:UIControlStateNormal];
    
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    self.navigationController.view.frame = CGRectMake(0, screenHeight - self.finishedButton.bottom - 10 - bottomInset, screenWidth, self.finishedButton.bottom + 10 + bottomInset);
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
    
    [self.finishedButton addTarget:self withActionBlock:^{
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:AWEActionSheetFinishedClickNotification object:nil userInfo:@{@"source": @"report"}];
    } forControlEvent:UIControlEventTouchUpInside];
    
    WeakSelf;
    [self.titleView.backButton addTarget:self withActionBlock:^{
        StrongSelf;
        if (self.keyboardListener.keyboardHeight > 0) {
            [self.view endEditing:YES];
            self.popLock = YES;
        }
        else {
            [UIView animateWithDuration:AWEActionSheetAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                StrongSelf;
                self.navigationController.view.alpha = 0.0f;
            } completion:^(BOOL finished) {
                StrongSelf;
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    } forControlEvent:UIControlEventTouchUpInside];
    
    self.viewHeight = self.finishedButton.height + 10 + bottomInset;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!isEmptyString(self.manager.criticismInput)) {
        self.inputTextView.text = self.manager.criticismInput;
        [self.finishedButton setEnabled:YES];
    }
    self.titleView.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.inputTextView becomeFirstResponder];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.titleView.hidden = YES;
    [self.view endEditing:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;
    
    NSArray *windowViewControllers = self.navigationController.viewControllers;
    
    if ([self isEqual:[windowViewControllers lastObject]]) {
        self.inputTextView.frame = CGRectMake(14 + padding, AWEActionSheetNavigationBarHeight + 5, width - (2 * 14), 62.f);
        self.finishedButton.frame = CGRectMake(0, self.inputTextView.bottom + 8, 57, 28);
        self.finishedButton.right = self.inputTextView.right;
        [self.titleView setNeedsLayout];
        
        CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
        self.navigationController.view.frame = CGRectMake(0, screenHeight - self.finishedButton.bottom - 10 - bottomInset, self.navigationController.view.size.width, self.finishedButton.bottom + 10 + bottomInset);

    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - TTKeyboardListener

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = CGRectGetHeight([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    
    [UIView animateWithDuration:AWEActionSheetAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect navRect = self.navigationController.view.frame;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGFloat temp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = temp;
        }
        navRect.origin.y = screenHeight - self.finishedButton.bottom - 10 - keyboardHeight;
        self.navigationController.view.frame = navRect;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)keyboardDidHide {
    [UIView animateWithDuration:AWEActionSheetAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect navRect = self.navigationController.view.frame;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGFloat temp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = temp;
        }
        navRect.origin.y = screenHeight - self.finishedButton.bottom - 10 - self.keyboardListener.keyboardHeight;
        self.navigationController.view.frame = navRect;
        self.navigationController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (self.popLock) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.manager.criticismInput = textView.text;
    [self.inputTextView showOrHidePlaceHolderTextView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    //Has Focus
    return YES;
}

+ (UIImage *)imageWithUIColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
