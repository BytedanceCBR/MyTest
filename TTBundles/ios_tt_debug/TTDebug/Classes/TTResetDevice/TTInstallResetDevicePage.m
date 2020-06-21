//
//  TTInstallResetDevicePage.m
//  TTDebugKit
//
//  Created by han yang on 2019/11/18.
//

#if INHOUSE

#import "TTInstallResetDevicePage.h"
#import <ByteDanceKit/BTDMacros.h>

@interface TTInstallResetDeviceAnimation : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL isPresenting;
+ (instancetype)deviceAnimationIsPresenting:(BOOL)isPresenting;
@end

@implementation TTInstallResetDeviceAnimation

+ (instancetype)deviceAnimationIsPresenting:(BOOL)isPresenting
{
    TTInstallResetDeviceAnimation *animation = [[TTInstallResetDeviceAnimation alloc] init];
    animation.isPresenting = isPresenting;
    return animation;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresenting) {
        [self presentAnimateTransition:transitionContext];
    }else {
        [self dismissAnimateTransition:transitionContext];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)presentAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    TTInstallResetDevicePage *devicePage = (TTInstallResetDevicePage *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    devicePage.view.alpha = 0.0;
    devicePage.centerBackgroundView.alpha = 0.0;
    devicePage.centerBackgroundView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:devicePage.view];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        devicePage.view.alpha = 1.0;
        devicePage.centerBackgroundView.alpha = 1.0;
        devicePage.centerBackgroundView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)dismissAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    TTInstallResetDevicePage *devicePage = (TTInstallResetDevicePage *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        devicePage.view.alpha = 0.0;
        devicePage.centerBackgroundView.alpha = 0.0;
        devicePage.centerBackgroundView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end

@interface TTInstallResetDevicePage ()<UIPickerViewDelegate, UIPickerViewDataSource, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong, readwrite) UIView *centerBackgroundView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *horizontalLineView;
@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UISwitch *autoResetSwitch;
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *dataSource;
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *internalDataArray;
@property (nonatomic, copy) NSString *ageLevel;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, assign) BOOL isAutoReset;

@end

@implementation TTInstallResetDevicePage

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = @[@[@"男性", @"女性"], @[@"0-18周岁", @"19-23周岁", @"24-30周岁", @"31-40周岁", @"41-50周岁", @"51周岁以上"]];
        _internalDataArray = @[@[@"male", @"female"], @[@"1", @"2", @"3", @"4", @"5", @"6"]];
        _ageLevel = @"1";
        _gender = @"male";
        _isAutoReset = NO;
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:self.centerBackgroundView];
    [self.centerBackgroundView addSubview:self.titleLabel];
    [self.centerBackgroundView addSubview:self.pickerView];
    [self.centerBackgroundView addSubview:self.horizontalLineView];
    [self.centerBackgroundView addSubview:self.verticalLineView];
    [self.centerBackgroundView addSubview:self.cancelButton];
    [self.centerBackgroundView addSubview:self.okButton];
    [self.centerBackgroundView addSubview:self.detailLabel];
    [self.centerBackgroundView addSubview:self.autoResetSwitch];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return component == 0 ? 2 : 6;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.dataSource[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.gender = self.internalDataArray[component][row];
    } else {
        self.ageLevel = self.internalDataArray[component][row];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView) {
        tView = [[UILabel alloc] init];
        tView.font = [UIFont systemFontOfSize:17.0f];
        tView.textAlignment = NSTextAlignmentCenter;
        tView.textColor = [UIColor blackColor];
    }
    tView.text = self.dataSource[component][row];

    return tView;
}

- (void)onClickedCancelButton
{
    @weakify(self)
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        if (self.cancelButtonDidClicked) {
            self.cancelButtonDidClicked();
        }
    }];
}

- (void)onClickedOkButton
{
    @weakify(self)
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        if (self.okButtonDidClicked) {
            self.okButtonDidClicked(self.gender, self.ageLevel, self.isAutoReset);
        }
    }];
}

- (void)onClickedSwitch:(UISwitch *)sender
{
    if (sender.on) {
        NSString *message = @"打开【自动重置开关】，每次冷启动会自动生成新did，该did只在当前冷启动后app生命周期生效；\n关闭【自动重置开关】，下次冷启动后一直生效；";
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否要开启自动重置模式"
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        @weakify(self)
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认开启"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self)
            self.isAutoReset = YES;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self)
            self.isAutoReset = NO;
            sender.on = NO;
        }];
        [alertVC addAction:okAction];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        self.isAutoReset = NO;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [TTInstallResetDeviceAnimation deviceAnimationIsPresenting:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [TTInstallResetDeviceAnimation deviceAnimationIsPresenting:NO];
}

#pragma mark - Getter Method
- (UIView *)centerBackgroundView
{
    if (_centerBackgroundView == nil) {
        _centerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
        _centerBackgroundView.center = self.view.center;
        _centerBackgroundView.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1];
        _centerBackgroundView.layer.cornerRadius = 12.0f;
        _centerBackgroundView.clipsToBounds = YES;
    }
    return _centerBackgroundView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 16, 230, 20)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"请选择性别以及年龄";
    }
    return _titleLabel;
}

- (UIPickerView *)pickerView
{
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 250, 116)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (UIView *)verticalLineView
{
    if (_verticalLineView == nil) {
        CGFloat width = 1.0 / [UIScreen mainScreen].scale;
        _verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(125, 206, width, 45)];
        _verticalLineView.backgroundColor = [UIColor grayColor];
    }
    return _verticalLineView;
}

- (UIView *)horizontalLineView
{
    if (_horizontalLineView == nil) {
        _horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 206, 250, 1.0 / [UIScreen mainScreen].scale)];
        _horizontalLineView.backgroundColor = [UIColor grayColor];
    }
    return _horizontalLineView;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 205, 124, 45);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(onClickedCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)okButton
{
    if (_okButton == nil) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(126, 205, 124, 45);
        [_okButton setTitle:@"确定" forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0] forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_okButton addTarget:self action:@selector(onClickedOkButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

- (UILabel *)detailLabel
{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 173, 155, 30)];
        _detailLabel.font = [UIFont systemFontOfSize:16.0f];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.textColor = [UIColor blackColor];
        _detailLabel.text = @"【自动重置开关】";
    }
    return _detailLabel;
}

- (UISwitch *)autoResetSwitch
{
    if (_autoResetSwitch == nil) {
        _autoResetSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(170, 170, 60, 30)];
        [_autoResetSwitch addTarget:self action:@selector(onClickedSwitch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _autoResetSwitch;
}

@end

#endif
