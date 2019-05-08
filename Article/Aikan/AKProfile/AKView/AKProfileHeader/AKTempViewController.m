//
//  AKTempViewController.m
//  Article
//
//  Created by chenjiesheng on 2018/3/2.
//

#import "AKUILayout.h"
#import "AKAwardCoinManager.h"
#import "AKProfileHeaderView.h"
#import "AKPhotoCarouselView.h"
#import "AKTempViewController.h"
#import "AKPhotoCarouselCellModel.h"
#import "AKProfileHeaderViewUnLogin.h"
#import "AKProfileHeaderViewLogined.h"
#import "AKRedPacketOptionalLoginView.h"


#import <TTRoute.h>
#import <SSThemed.h>
#import <UIViewController+NavigationBarStyle.h>
@interface AKTempViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView        *tableView;

@end

@implementation AKTempViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttHideNavigationBar = YES;
    }
    return self;
}

+ (void)load
{
    RegisterRouteObjWithEntryName(@"ak_profile_test");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    [AKAwardCoinManager showAwardCoinTipInView:self.view tipType:AKAwardCoinTipTypeArticle];
    AKRedPacketOptionalLoginView *loginView = [[AKRedPacketOptionalLoginView alloc] initWithSupportPlatforms:@[PLATFORM_PHONE,PLATFORM_QZONE] delegate:nil];
    [self.view addSubview:loginView];
    loginView.center = self.view.center;
}

- (void)showTipWithTipType:(AKAwardCoinTipType)tipType
{
    [AKAwardCoinManager showAwardCoinTipInView:self.view tipType:tipType];
}

#pragma UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = [UIColor blueColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}
@end
