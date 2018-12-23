//
//  FHSuggestionListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewController.h"
#import "FHSuggestionListNavBar.h"
#import "TTDeviceHelper.h"
#import "FHHouseType.h"
#import "FHHouseTypeManager.h"
#import "FHPopupMenuView.h"

@interface FHSuggestionListViewController ()

@property (nonatomic, strong)     FHSuggestionListNavBar     *naviBar;
@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, weak)     FHPopupMenuView       *popupMenuView;


@property (nonatomic, strong)     FHSuggestionListReturnBlock       retBlk;

@end

@implementation FHSuggestionListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
//        self.neighborhoodId = paramObj.userInfo.allInfo[@"neighborhoodId"];
//        self.houseId = paramObj.userInfo.allInfo[@"houseId"];
//        self.searchId = paramObj.userInfo.allInfo[@"searchId"];
        _houseType = [paramObj.userInfo.allInfo[@"house_type"] integerValue];
//        self.relatedHouse = [paramObj.userInfo.allInfo[@"related_house"] boolValue];
//        self.neighborListVCType = [paramObj.userInfo.allInfo[@"list_vc_type"] integerValue];
//
//        NSLog(@"%@\n", self.searchId);
        NSLog(@"%@\n",paramObj.userInfo.allInfo);
        _retBlk = paramObj.userInfo.allInfo[@"callback_block"];
        NSLog(@"_wBlk:%@",_retBlk);
        TTRouteObject *route = nil;//= [[TTRoute sharedRoute] routeObjWithOpenURL:NSURL URLWithString:paramObj userInfo:paramObj];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.retBlk(route);
        });
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
}

- (void)setupUI {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHSuggestionListNavBar alloc] init];
    [self.view addSubview:_naviBar];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(naviHeight);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar setSearchPlaceHolderText:[[FHHouseTypeManager sharedInstance] searchBarPlaceholderForType:self.houseType]];
    _naviBar.searchTypeLabel.text = [[FHHouseTypeManager sharedInstance] stringValueForType:self.houseType];
    CGSize size = [self.naviBar.searchTypeLabel sizeThatFits:CGSizeMake(100, 20)];
    [self.naviBar.searchTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    [_naviBar.searchTypeBtn addTarget:self action:@selector(searchTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setHouseType:(FHHouseType)houseType {
    _houseType = houseType;
    [_naviBar setSearchPlaceHolderText:[[FHHouseTypeManager sharedInstance] searchBarPlaceholderForType:houseType]];
    _naviBar.searchTypeLabel.text = [[FHHouseTypeManager sharedInstance] stringValueForType:houseType];
    CGSize size = [self.naviBar.searchTypeLabel sizeThatFits:CGSizeMake(100, 20)];
    [self.naviBar.searchTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
}

- (void)searchTypeBtnClick:(UIButton *)btn {
    NSArray *items = @[@(FHHouseTypeSecondHandHouse),
                       @(FHHouseTypeRentHouse),
                       @(FHHouseTypeNewHouse),
                       @(FHHouseTypeNeighborhood),];
    //TODO: add by zyk configCcache中数据获取
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHHouseType houseType = [obj integerValue];
        FHPopupMenuItem *item = [self getPopupItemBy:houseType];
        [menuItems addObject:item];
    }];
    
    FHPopupMenuView *popup = [[FHPopupMenuView alloc] initWithTargetView:self.naviBar.searchTypeBtn menus:menuItems];
    [self.view addSubview:popup];
    self.popupMenuView = popup;
    [popup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.mas_equalTo(self.view);
    }];
    [self.popupMenuView showOnTargetView];
    
}
- (FHPopupMenuItem *)getPopupItemBy:(FHHouseType)ht {
    FHPopupMenuItem *item = [[FHPopupMenuItem alloc] initWithHouseType:ht isSelected:self.houseType == ht];
    __weak typeof(self) weakSelf = self;
    item.itemClickBlock = ^(FHHouseType houseType) {
        weakSelf.houseType = houseType;
        [weakSelf.popupMenuView removeFromSuperview];
    };
    return item;
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
