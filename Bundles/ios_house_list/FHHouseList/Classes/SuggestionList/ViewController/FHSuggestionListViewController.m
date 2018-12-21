//
//  FHSuggestionListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewController.h"
#import "FHSuggestionListNavBar.h"
#import "TTDeviceHelper.h"

@interface FHSuggestionListViewController ()

@property (nonatomic, strong)     FHSuggestionListNavBar     *naviBar;

@property (nonatomic, strong)     FHSuggestionListReturnBlock       wBlk;

@end

@implementation FHSuggestionListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
//        self.neighborhoodId = paramObj.userInfo.allInfo[@"neighborhoodId"];
//        self.houseId = paramObj.userInfo.allInfo[@"houseId"];
//        self.searchId = paramObj.userInfo.allInfo[@"searchId"];
//        self.houseType = [paramObj.userInfo.allInfo[@"house_type"] integerValue];
//        self.relatedHouse = [paramObj.userInfo.allInfo[@"related_house"] boolValue];
//        self.neighborListVCType = [paramObj.userInfo.allInfo[@"list_vc_type"] integerValue];
//
//        NSLog(@"%@\n", self.searchId);
        NSLog(@"%@\n",paramObj.userInfo.allInfo);
        _wBlk = paramObj.userInfo.allInfo[@"callback_block"];
        NSLog(@"_wBlk:%@",_wBlk);
        TTRouteObject *route = nil;//= [[TTRoute sharedRoute] routeObjWithOpenURL:NSURL URLWithString:paramObj userInfo:paramObj];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.wBlk(route);
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
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
