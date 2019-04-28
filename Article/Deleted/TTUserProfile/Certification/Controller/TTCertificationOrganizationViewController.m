//
//  TTCertificationOrganizationViewController.m
//  Article
//
//  Created by wangdi on 2017/5/23.
//
//

#import "TTCertificationOrganizationViewController.h"

@interface TTCertificationOrganizationViewController ()

@end

@implementation TTCertificationOrganizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupSubview
{
    [super setupSubview];
    SSThemedView *topLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [TTDeviceUIUtils tt_newPadding:6])];
    topLine.backgroundColorThemeKey = kColorBackground3;
    [self.view addSubview:topLine];
    self.iconView.top = [TTDeviceUIUtils tt_newPadding:88];
    self.iconView.imageName = @"Information_notpass";
    self.descLabel.top = self.iconView.bottom + [TTDeviceUIUtils tt_newPadding:14];
    self.descLabel.text = @"暂未开通机构认证申请";
    self.timeLabel.top = self.descLabel.bottom + [TTDeviceUIUtils tt_newPadding:5];
    self.timeLabel.text = @"敬请等待";
}

@end
