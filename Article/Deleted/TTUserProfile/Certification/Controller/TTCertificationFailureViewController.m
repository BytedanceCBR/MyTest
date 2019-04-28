//
//  TTCertificationFailureViewController.m
//  Article
//
//  Created by wangdi on 2017/5/22.
//
//

#import "TTCertificationFailureViewController.h"
#import "TTCertificationOperationView.h"

@interface TTCertificationFailureViewController ()

@property (nonatomic, strong) TTCertificationOperationView *operationView;
@property (nonatomic, strong) SSThemedLabel *emailLabel;

@end

@implementation TTCertificationFailureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)setupSubview
{
    [super setupSubview];
    [self.view addSubview:self.emailLabel];
    [self.view addSubview:self.operationView];
}

- (void)themeChanged:(NSNotification*)notification {
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (SSThemedLabel *)emailLabel
{
    if(!_emailLabel) {
        _emailLabel = [[SSThemedLabel alloc] init];
        _emailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _emailLabel.textColorThemeKey = self.timeLabel.textColorThemeKey;
        _emailLabel.textAlignment = NSTextAlignmentCenter;
        _emailLabel.font = self.timeLabel.font;
        _emailLabel.left = self.timeLabel.left;
        _emailLabel.width = self.timeLabel.width;
        _emailLabel.height = self.timeLabel.height;
        _emailLabel.top = self.timeLabel.bottom + [TTDeviceUIUtils tt_newPadding:5];
//        _emailLabel.text = @"若有疑问可联系:weitoutiao@toutiao.com";
    }
    return _emailLabel;
}

- (TTCertificationOperationView *)operationView
{
    if(!_operationView) {
        _operationView = [[TTCertificationOperationView alloc] init];
        _operationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_operationView setTitle:@"重新申请" forState:UIControlStateNormal];
        _operationView.left = [TTDeviceUIUtils tt_newPadding:15];
        _operationView.width = self.view.width - 2 * _operationView.left;
        _operationView.height = [TTDeviceUIUtils tt_newPadding:44];
        _operationView.top = self.timeLabel.bottom + [TTDeviceUIUtils tt_newPadding:173];
        [_operationView addTarget:self action:@selector(operationViewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationView;
}

- (void)setEmailText:(NSString *)emailText
{
    _emailText = emailText;
    self.emailLabel.text = emailText;
    if(!isEmptyString(self.timeLabel.text)) {
        self.emailLabel.top = self.timeLabel.bottom + [TTDeviceUIUtils tt_newPadding:5];
    } else {
        self.emailLabel.top = self.timeLabel.top;
    }
}

- (void)operationViewClick
{
    if(self.operationViewClickBlock) {
        self.operationViewClickBlock();
    }
}

@end
