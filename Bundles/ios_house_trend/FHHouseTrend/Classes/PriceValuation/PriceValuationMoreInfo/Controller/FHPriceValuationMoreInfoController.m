//
//  FHPriceValuationMoreInfoController.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHPriceValuationMoreInfoController.h"
#import "FHPriceValuationMoreInfoView.h"
#import "FHPriceValuationMoreInfoViewModel.h"

@interface FHPriceValuationMoreInfoController ()

@property(nonatomic, strong) FHPriceValuationMoreInfoViewModel *viewModel;
@property(nonatomic ,strong) FHPriceValuationMoreInfoView *moreInfoView;

@end

@implementation FHPriceValuationMoreInfoController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
        self.infoModel = params[@"infoModel"];
        NSHashTable *temp_delegate = paramObj.allParams[@"delegate"];
        self.delegate = temp_delegate.anyObject;
        //        self.tracerModel = [[FHTracerModel alloc] init];
        //        self.tracerModel.enterFrom = params[@"enter_from"];
        //        self.tracerModel.enterType = params[@"enter_type"];
        //        [self addEnterCategoryLog];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"查房价";
}

- (void)initView {
    [self.view layoutIfNeeded];
    self.moreInfoView = [[FHPriceValuationMoreInfoView alloc] initWithFrame:self.view.bounds naviBarHeight:CGRectGetHeight(self.customNavBarView.frame)];
    if(self.infoModel){
        [_moreInfoView updateView:self.infoModel];
    }
    [self.view addSubview:_moreInfoView];
}

- (void)initConstraints {
    [self.moreInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHPriceValuationMoreInfoViewModel alloc] initWithView:self.moreInfoView controller:self];
}

@end
