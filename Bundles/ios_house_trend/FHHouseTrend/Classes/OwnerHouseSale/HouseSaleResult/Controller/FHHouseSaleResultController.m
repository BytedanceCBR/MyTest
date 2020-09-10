//
//  FHHouseSaleResultController.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleResultController.h"
#import "UIColor+Theme.h"
#import "FHUserTracker.h"

@interface FHHouseSaleResultController ()

@property(nonatomic ,strong) UIView *topContentView;
@property(nonatomic ,strong) UIImageView *iconView;
@property(nonatomic ,strong) UILabel *titleLabel;
@property(nonatomic ,strong) UILabel *descLabel;

@property(nonatomic ,strong) UIView *bottomContentView;
@property(nonatomic ,strong) UIButton *strategyBtn;
@property(nonatomic ,strong) UIButton *phoneBtn;
@property(nonatomic ,strong) UIView *spLine;

@end

@implementation FHHouseSaleResultController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.tracerDict[@"page_type"] = @"publisher_success_detail";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self addGoDetailLog];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.seperatorLine.hidden = YES;
    self.customNavBarView.leftBtn.hidden = YES;
    
    UIButton *finishBtn = [[UIButton alloc] init];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [finishBtn addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addRightViews:@[finishBtn] viewsWidth:@[@28] viewsHeight:@[@20] viewsRightOffset:@[@15]];
}

- (void)finish {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initView {
    self.view.backgroundColor = [UIColor themeGray7];
    
    self.topContentView = [[UIView alloc] init];
    _topContentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topContentView];
    
    self.iconView = [[UIImageView alloc] init];
    _iconView.image = [UIImage imageNamed:@"house_sale_result_icon"];
    [self.topContentView addSubview:_iconView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:24] textColor:[UIColor themeGray1]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"发布成功";
    [self.topContentView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    _descLabel.text = @"稍后将有专属经纪人电话服务";
    _descLabel.textAlignment = NSTextAlignmentCenter;
    _descLabel.numberOfLines = 2;
    [self.topContentView addSubview:_descLabel];
    
    self.bottomContentView = [[UIView alloc] init];
    _bottomContentView.backgroundColor = [UIColor whiteColor];
    _bottomContentView.layer.masksToBounds = YES;
    _bottomContentView.layer.cornerRadius = 10;
    [self.view addSubview:_bottomContentView];
    
    self.spLine = [[UIView alloc] init];
    _spLine.backgroundColor = [UIColor themeGray7];
    [self.bottomContentView addSubview:_spLine];
    
    CGFloat btnWidth = ([UIScreen mainScreen].bounds.size.width - 30 - 1)/2;
    
    self.strategyBtn = [self buttonWithFrame:CGRectMake(0, 0, btnWidth, 72) title:@"买房攻略" imageName:@"house_sale_strategy_icon" action:@selector(goToStrategy)];
    [self.bottomContentView addSubview:_strategyBtn];
    
    self.phoneBtn = [self buttonWithFrame:CGRectMake(0, 0, btnWidth, 72) title:@"电话客服" imageName:@"house_sale_phone_icon" action:@selector(goToPhone)];
    [self.bottomContentView addSubview:_phoneBtn];

}

- (void)initConstraints {
    [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topContentView).offset(30);
        make.centerX.mas_equalTo(self.topContentView);
        make.width.height.mas_equalTo(80);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.topContentView).offset(30);
        make.right.mas_equalTo(self.topContentView).offset(-30);
        make.height.mas_equalTo(33);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(12);
        make.left.mas_equalTo(self.topContentView).offset(30);
        make.right.mas_equalTo(self.topContentView).offset(-30);
        make.bottom.mas_equalTo(self.topContentView).offset(-20);
    }];
    
    [self.bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topContentView.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.height.mas_equalTo(72);
    }];
    
    [self.spLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.bottomContentView);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(40);
    }];
    
    CGFloat btnWidth = ([UIScreen mainScreen].bounds.size.width - 30 - 1)/2;
    [self.strategyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(self.bottomContentView);
        make.width.mas_equalTo(btnWidth);
    }];
    
    [self.phoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(self.bottomContentView);
        make.width.mas_equalTo(btnWidth);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title imageName:(NSString *)imageName action:(SEL)action{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    btn.imageView.contentMode = UIViewContentModeCenter;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont themeFontSemibold:18];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, -6)];
    if(action){
        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    btn.titleLabel.layer.masksToBounds = YES;
    btn.titleLabel.backgroundColor = [UIColor whiteColor];
  
    return btn;
}

- (void)goToStrategy {
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    dict[@"tracer"] = tracer;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
    NSURL* url = [NSURL URLWithString:@"sslocal://detail?groupid=6865159951162016268&item_id=6865159951162016268&report_params=%7b%22enter_from%22%3a%22publisher_success_detail%22%2c%22log_pb%22%3a%7b%22group_id%22%3a%226865159951162016268%22%2c%22group_source%22%3a%222%22%7d%2c%22page_type%22%3a%22article_detail%22%2c%22element_from%22%3a%22selling_strategy%22%7d"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)goToPhone {
    [self addClickCustomerServicePhoneLog];
    NSString *phoneUrl = [NSString stringWithFormat:@"telprompt://%@",@"400-6124-360"];
    NSURL *url = [NSURL URLWithString:phoneUrl];
    [[UIApplication sharedApplication]openURL:url];
}

#pragma mark - 埋点
- (void)addGoDetailLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    tracerDict[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDict[@"event_tracking_id"] = @"107639";
    TRACK_EVENT(@"go_detail", tracerDict);
}

- (void)addClickCustomerServicePhoneLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"enter_from"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDict[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDict[@"event_tracking_id"] = @"107641";
    TRACK_EVENT(@"click_customer_service_phone", tracerDict);
}

@end
