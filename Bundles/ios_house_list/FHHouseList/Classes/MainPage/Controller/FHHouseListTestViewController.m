//
//  FHHouseListTestViewController.m
//  FHHouseList
//
//  Created by bytedance on 2020/10/28.
//

#import "FHHouseListTestViewController.h"
#import "FHHouseNewTopContainer.h"
#import "FHHouseNewTopContainerViewModel.h"
#import "UIViewAdditions.h"
#import "FHFakeInputNavbar.h"
#import "FHSearchHouseModel.h"
#import <TTBaseLib/TTBaseMacro.h>

@interface FHHouseListTestViewController ()
@property (nonatomic, strong) FHHouseNewTopContainerViewModel *houseNewTopViewModel;
@property (nonatomic, strong) FHHouseNewTopContainer *topView;
@end

@implementation FHHouseListTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.houseNewTopViewModel = [[FHHouseNewTopContainerViewModel alloc] init];
    CGFloat height = [FHHouseNewTopContainer viewHeightWithViewModel:self.houseNewTopViewModel];
    FHHouseNewTopContainer *topView = [[FHHouseNewTopContainer alloc] initWithFrame:CGRectMake(0, [FHFakeInputNavbar perferredHeight], self.view.width, height)];
    topView.viewModel = self.houseNewTopViewModel;
    WeakSelf;
    topView.onStateChanged = ^{
        StrongSelf;
        self.topView.height = [FHHouseNewTopContainer viewHeightWithViewModel:self.houseNewTopViewModel];
    };
    [self.view addSubview:topView];
    topView.clipsToBounds = YES;
    self.topView = topView;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 600, 100, 50);
    button.centerX = self.view.width / 2;
    [button setTitle:@"点我" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)onButtonClicked:(id)sender {
    FHCourtBillboardPreviewButtonModel *button = [[FHCourtBillboardPreviewButtonModel alloc] init];
    button.text = @"查看全部榜单";
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger index = 0; index < 3; index++) {
        FHCourtBillboardPreviewItemModel *item0 = [[FHCourtBillboardPreviewItemModel alloc] init];
        item0.title = [NSString stringWithFormat:@"我是title撒娇都撒到卡上看到卡索拉的卡拉斯sdks拉到卡拉斯的%ld", index];
        item0.subtitle = [NSString stringWithFormat:@"我是subtitle阿手机看电视卡的卡上看到拉上看到卡洛斯的阿斯科利的快乐撒%ld", index];
        item0.pricingPerSqm = @"6000000000元/平米";
        
        [items addObject:item0];
    }
    
    
    FHCourtBillboardPreviewModel *model = [[FHCourtBillboardPreviewModel alloc] init];
    model.title = @"楼盘人气榜";
    model.items = items;
    model.button = button;
    
    [self.houseNewTopViewModel.billboardViewModel loadFinishWithData:model];
}

@end
