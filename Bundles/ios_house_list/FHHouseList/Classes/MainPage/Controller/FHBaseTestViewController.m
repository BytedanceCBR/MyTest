//
//  FHBaseTestViewController.m
//  FHHouseList
//
//  Created by bytedance on 2021/1/26.
//

#import "FHBaseTestViewController.h"
#import "FHBaseTableView.h"
#import "FHMineMyCollectionViewCell.h"
#import "FHMineHeaderView.h"
#import "FHMineMyItemView.h"
#import <Masonry/Masonry.h>

#import "FHMineViewController.h"
#import <Masonry/Masonry.h>
#import "TTNavigationController.h"
#import "TTRoute.h"
#import "FHMineViewModel.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "UIViewController+Track.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTReachability.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "UIViewController+Track.h"
#import "TTTabBarItem.h"
#import "TTTabBarManager.h"
#import <FHPopupViewCenter/FHPopupViewManager.h>
#import "ToastManager.h"
#import "UIImage+FIconFont.h"
#import "FHMineMyMutiItemCell.h"

#define FHBackWhiteImage ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor])

@interface FHBaseTestViewController ()
@property (nonatomic , strong) FHMineHeaderView *headerView;
@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic,strong) UIButton *settingBtn;
@property(nonatomic,strong) UIButton *phoneBtn;
@property(nonatomic,strong) UIButton *backBtn;

@property (nonatomic, assign) CGFloat naviBarHeight;
@property (nonatomic, assign) CGFloat headerViewHeight;
@end

@implementation FHBaseTestViewController
-(void) backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) initMyNavBar
{
    [self setupDefaultNavBar:NO];
    
    self.customNavBarView.title.text=@"我的";
    self.customNavBarView.title.textColor= [UIColor whiteColor];
    self.customNavBarView.title.alpha = 0;
    self.customNavBarView.seperatorLine.alpha = 0;
    self.customNavBarView.leftBtn.hidden = YES;
    self.customNavBarView.bgView.alpha = 0;
    self.customNavBarView.bgView.image = [UIImage imageNamed:@"fh_mine_header_bg_orange"];
    
    self.settingBtn = [[UIButton alloc] init];
    [self.settingBtn setBackgroundImage: [UIImage imageNamed:@"fh_mine_setting"] forState:UIControlStateNormal];
    [self.settingBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];

    self.phoneBtn = [[UIButton alloc] init];
    [self.phoneBtn setBackgroundImage:[UIImage imageNamed:@"fh_mine_phone"] forState:UIControlStateNormal];
    [self.phoneBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addRightViews:@[_settingBtn,_phoneBtn] viewsWidth:@[@24,@24] viewsHeight:@[@24,@24] viewsRightOffset:@[@20,@30]];

    [self.view layoutIfNeeded];
    self.naviBarHeight = CGRectGetMaxY(self.customNavBarView.frame);
}

-(void) initView
{
    self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor themeGray7];
    self.tableView.estimatedRowHeight = 124;
    [self.view addSubview:self.tableView];
}
-(void) initConstraints
{
    CGFloat bottom= 49;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
}
- (void)setupHeaderView {
    self.headerViewHeight = 74 + self.naviBarHeight;
    
    FHMineHeaderView *headerView = [[FHMineHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.headerViewHeight) naviBarHeight:self.naviBarHeight];
    headerView.userInteractionEnabled = YES;
    headerView.editIcon.alpha=0;
    headerView.editIcon.hidden=YES;
    headerView.iconBorderView.alpha=0;
    headerView.iconBorderView.hidden=YES;
    self.tableView.tableHeaderView = headerView;
    
    
    self.backBtn = [[UIButton alloc] init];
    [self.backBtn setImage:FHBackWhiteImage forState:UIControlStateNormal];
    [self.backBtn setImage:FHBackWhiteImage forState:UIControlStateHighlighted];
    [self.backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneBtn.mas_top);
        make.left.mas_equalTo(self.tableView.tableHeaderView.mas_left).offset(5);
        make.width.mas_equalTo(self.phoneBtn.mas_width);
        make.height.mas_equalTo(self.phoneBtn.mas_height);
    }];

}
#pragma  mark 加载
- (void)viewDidLoad
{
    self.automaticallyAdjustsScrollViewInsets=NO;
    [super viewDidLoad];
    [self initMyNavBar];
    [self initView];
    [self initConstraints];
    [self setupHeaderView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 120;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (FHMineMyItemView *)itemWithImageName:(NSString *)imgName andLabelText:(NSString *)labelText
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = labelText;
    label.font = [UIFont themeFontMedium:10];
    FHMineMyItemView *item = [[FHMineMyItemView alloc] initWithImageView:imgView andLabel:label];
    return item;
}
#pragma mark 返回cell方法
- (FHMineMyMutiItemCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHMineMyMutiItemCell *cell = [[FHMineMyMutiItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if(indexPath.row==0 && indexPath.item==0){
        
    }
    else{
        [cell hiddenHeaderView];
    }
    if(indexPath.row==0){
        
        [cell setItemTitle:@"我的关注"];
        NSMutableArray *arr = [NSMutableArray new];
        FHMineMyItemView *item;
        item = [self itemWithImageName:@"my1" andLabelText:@"二手房"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my2" andLabelText:@"新房"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my3" andLabelText:@"小区"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my4" andLabelText:@"租房"];
        [arr addObject:item];
        
        [cell addItems:arr andRow:0];
        return cell;
    }
    else if(indexPath.row==1){
        [cell setItemTitle:@"我的服务"];
        NSMutableArray *arr = [NSMutableArray new];
        FHMineMyItemView *item;
        item = [self itemWithImageName:@"my5" andLabelText:@"搜索订阅"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my6" andLabelText:@"浏览历史"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my7" andLabelText:@"收藏文章"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my8" andLabelText:@"用户反馈"];
        [arr addObject:item];
        
        [cell addItems:arr andRow:1];
        return cell;
        
    }
    else if(indexPath.row == 2){
        [cell setItemTitle:@"购房工具"];
        NSMutableArray *arr = [NSMutableArray new];
        FHMineMyItemView *item;
        item = [self itemWithImageName:@"my9" andLabelText:@"地图找房"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my10" andLabelText:@"查房价"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my11" andLabelText:@"房贷计算"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my12" andLabelText:@"帮我找房"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my13" andLabelText:@"城市行情"];
        [arr addObject:item];
        item = [self itemWithImageName:@"my14" andLabelText:@"购房百科"];
        [arr addObject:item];
        
        [cell addItems:arr andRow:2];
        return cell;
    }
    FHMineMyCollectionViewCell *tcell = [[FHMineMyCollectionViewCell alloc] init];
    
    return tcell;
}
@end
