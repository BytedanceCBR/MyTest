//
//  SSInHouseDebugViewController.m
//  Article
//
//  Created by liufeng on 2017/8/14.
//
//

#if INHOUSE

#import "SSInHouseDebugViewController.h"
#import "SSInHouseFeatureManager.h"

@interface SSInHouseDebugViewController ()

@end

@implementation SSInHouseDebugViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"内测功能[重启后生效]";
    self.dataSource = [self _constructDataSource];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"说明" style:UIBarButtonItemStylePlain target:self action:@selector(_showDiscussion)];
}

- (void)_showDiscussion
{
    NSString *branchName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BranchName"];
    NSString *msg = [NSString stringWithFormat:@"branchName:%@", branchName];
    [[[UIAlertView alloc] initWithTitle:@"说明" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

- (NSArray <STTableViewSectionItem *>*)_constructDataSource
{
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:2];
    SSInHouseFeature *fe = SSInHouseFeatureManager.localFeature;
    SSInHouseFeature *remoteFe = SSInHouseFeatureManager.remoteFeature;
    
    STTableViewCellItem *item00 = [[STTableViewCellItem alloc] initWithTitle:@"在状态栏显示快速反馈入口" target:self action:NULL];
    item00.switchStyle = YES;
    item00.switchAction = @selector(_updateQuickFeedbackGate:);
    item00.checked = fe.show_quick_feedback_gate;
    item00.detail = [NSString stringWithFormat:@"show_quick_feedback_gate:%d", remoteFe.show_quick_feedback_gate];
    STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"反馈" items:@[item00]];
    [dataSource addObject:section0];
    
    STTableViewCellItem *item10 = [[STTableViewCellItem alloc] initWithTitle:@"仅支持手机号登陆" target:self action:NULL];
    item10.switchStyle = YES;
    item10.switchAction = @selector(_updateLoginPlatformPhoneOnly:);
    item10.checked = fe.login_phone_only;
    item10.detail = [NSString stringWithFormat:@"login_phone_only:%d", remoteFe.login_phone_only];
    
    STTableViewCellItem *item11 = [[STTableViewCellItem alloc] initWithTitle:@"隐藏账号密码登录" target:self action:NULL];
    item11.switchStyle = YES;
    item11.switchAction = @selector(supportLoginWithPassword);
    item11.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"ak_hidden_login_switch_button"];
    item11.detail = item11.checked ? @"显示账号密码登录中" : @"隐藏账号密码登录中";
    
    STTableViewSectionItem *section1 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"登陆" items:@[item10,item11]];
    [dataSource addObject:section1];
    
  
    return dataSource;
}

- (void)_updateQuickFeedbackGate:(UISwitch *)sw
{
    SSInHouseFeature *fe = SSInHouseFeatureManager.localFeature;
    fe.show_quick_feedback_gate = sw.isOn;
    [[SSInHouseFeatureManager defaultManager] resetUserDiskCacheWithFeature:fe];
}

- (void)_updateLoginPlatformPhoneOnly:(UISwitch *)sw
{
    SSInHouseFeature *fe = SSInHouseFeatureManager.localFeature;
    fe.login_phone_only = sw.isOn;
    [[SSInHouseFeatureManager defaultManager] resetUserDiskCacheWithFeature:fe];
}

- (void)supportLoginWithPassword
{
    BOOL hidden = [[NSUserDefaults standardUserDefaults] boolForKey:@"ak_hidden_login_switch_button"];
    [[NSUserDefaults standardUserDefaults] setBool:!hidden forKey:@"ak_hidden_login_switch_button"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

#endif
