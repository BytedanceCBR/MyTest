//
//  FHDetailMapPageViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/1/31.
//

#import "FHDetailMapPageViewController.h"
#import "FHDetailMapPageNaviBarView.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface FHDetailMapPageViewController () <TTRouteInitializeProtocol>
@property (nonatomic, strong) FHDetailMapPageNaviBarView *naviBar;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIView * bottomBarView;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation FHDetailMapPageViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        TTRouteUserInfo *userInfo = paramObj.userInfo;
        NSLog(@"userinfo = %@",[userInfo.allInfo objectForKey:@"url"]);
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNaviBar];
    
    // Do any additional setup after loading the view.
}

- (void)setUpNaviBar
{
    _naviBar = [[FHDetailMapPageNaviBarView alloc] initWithBackImage:[UIImage imageNamed:@"icon-return"]];
    [self.view addSubview:_naviBar];
    
    
    __weak typeof(self) wself = self;
    _naviBar.backActionBlock = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };

    CGFloat navHeight = 44;
    
    if (@available(iOS 11.0 , *)) {
        CGFloat top  = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
        if (top > 0) {
            navHeight += top;
        }else{
            navHeight += [self statusBarHeight];
        }
    }else{
        navHeight += [self statusBarHeight];
    }
    
    [self.naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.view);
        make.height.mas_equalTo(navHeight);
    }];
}

- (void)setUpBottomBarView
{
    _bottomBarView = [UIView new];
    [self.view addSubview:_bottomBarView];
    
    
    [_bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0 , *)) {
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.bottomAnchor);
        }else
        {
            make.bottom.equalTo(self.view);
        }
        make.left.top.right.mas_equalTo(self.view);
        make.height.mas_equalTo(43);
        make.left.right.equalTo(self.view);
    }];
    
    NSArray *nameArray = [NSArray arrayWithObjects:@"银行",@"公交",@"地铁",@"教育",@"医院",@"休闲",@"购物",@"健身",@"美食", nil];
    NSArray *imageNameArray = [NSArray arrayWithObjects:@"tab-bank-1",@"tab-bus",@"tab-subway",@"tab-education",@"tab-hospital",@"tab-relaxation",@"tab-mall",@"tab-swim",@"tab-food", nil];
    NSArray *keyWordArray = [NSArray arrayWithObjects:@"bank",@"bus",@"subway",@"scholl",@"hospital",@"entertainment",@"shopping",@"gym",@"food", nil];
    
    
    //        let items = [Item(name: "银行", icon: #imageLiteral(resourceName: "tab-bank-1"), selectedIcon: #imageLiteral(resourceName: "tab-bank-pressed")),
    //                     Item(name: "公交", icon: #imageLiteral(resourceName: "tab-bus"), selectedIcon: #imageLiteral(resourceName: "tab-bus-pressed")),
    //                     Item(name: "地铁", icon: #imageLiteral(resourceName: "tab-subway"), selectedIcon: #imageLiteral(resourceName: "tab-subway-pressed")),
    //                     Item(name: "教育", icon: #imageLiteral(resourceName: "tab-education"), selectedIcon: #imageLiteral(resourceName: "tab-education-pressed")),
    //                     Item(name: "医院", icon: #imageLiteral(resourceName: "tab-hospital"), selectedIcon: #imageLiteral(resourceName: "tab-hospital-pressed")),
    //                     Item(name: "休闲", icon: #imageLiteral(resourceName: "tab-relaxation"), selectedIcon: #imageLiteral(resourceName: "tab-relaxation-pressed")),
    //                     Item(name: "购物", icon: #imageLiteral(resourceName: "tab-mall"), selectedIcon: #imageLiteral(resourceName: "tab-mall-pressed")),
    //                     Item(name: "健身", icon: #imageLiteral(resourceName:"tab-swim"), selectedIcon: #imageLiteral(resourceName: "tab-swim_press")),
    //                     Item(name: "美食", icon: #imageLiteral(resourceName: "tab-food"), selectedIcon: #imageLiteral(resourceName: "tab-food_press"))]
//    let categoryParams = [
//                          "银行": "bank",
//                          "公交": "bus",
//                          "地铁": "subway",
//                          "教育": "school",
//                          "医院": "hospital",
//                          "休闲": "entertainment",
//                          "购物": "shopping",
//                          "健身": "gym",
//                          "美食": "food"
//                          ]
//
    
    UIScrollView *scrollViewItem = [[UIScrollView alloc] init];
    [_bottomBarView addSubview:scrollViewItem];
    
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width / 6.5;
    
    scrollViewItem.contentSize = CGSizeMake(itemWidth, 43);
    
    
    for (int i = 0; i < [nameArray count]; i++) {
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(itemWidth * i, 0, itemWidth, scrollViewItem.contentSize.height)];
        [scrollViewItem addSubview:iconView];
        
        UIButton *buttonIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == self.selectedIndex) {
            [buttonIcon setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-pressed",imageNameArray[i]]] forState:UIControlStateSelected];
        }else
        {
            [buttonIcon setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
        }
        [buttonIcon setFrame:CGRectMake((itemWidth - 32) / 2, 0, 32, 32)];
        [iconView addSubview:buttonIcon];
        
        
        
        UILabel *buttonLabel = [UILabel new];
        buttonLabel.text = nameArray[i];
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        buttonLabel.font = [UIFont themeFontRegular:9];
        buttonLabel.textColor = [UIColor themeGray];
        [iconView setFrame:CGRectMake(0, 30, itemWidth, 13)];
        [iconView addSubview:buttonLabel];
      
        
//        UILabel *buttonLabel = [[UILabel alloc] init];
//        addSubview(iconButton)
//        iconButton.snp.makeConstraints { maker in
//            maker.height.width.equalTo(32)
//            maker.centerX.equalToSuperview()
//            maker.top.equalToSuperview()
//        }
//
//        addSubview(label)
//        label.snp.makeConstraints { maker in
//            maker.top.equalTo(iconButton.snp.bottom).offset(-5)
//            maker.centerX.equalToSuperview()
//            maker.height.equalTo(13)
//            maker.bottom.equalTo(-3)
//        }
    }
    
    
    
//    scrollViewItem.contentSize = CGSize(width: UIScreen.main.bounds.width/6.5 * CGFloat(items.count), height: 43)
//    items.forEach { contentScrollView.addSubview($0) }
//    items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
//    items.snp.makeConstraints { maker in
//        maker.top.bottom.equalToSuperview()
//        maker.width.equalTo(UIScreen.main.bounds.width/6.5)
//    }
//    contentScrollView.backgroundColor = UIColor.white
    

}


- (void)setUpMapView
{
    
    _mapView = [[MAMapView alloc] initWithFrame:self.view.frame];
//    let mapView = MAMapView(frame: mapContainer.bounds)
//    mapView.delegate = self
//    mapView.showsCompass = false
//    mapView.showsScale = true
//    mapView.isZoomEnabled = true
//    mapView.isScrollEnabled = true
//    mapView.showsUserLocation = false
//    mapView.zoomLevel = 15
//    mapContainer.addSubview(mapView)
//    mapView.snp.makeConstraints { maker in
//        maker.top.bottom.right.left.equalToSuperview()
//    }
//    //        if let stylePath = Bundle.main.path(forResource: "gaode_map_style", ofType: "data"){
//    //            if let styleUrl = URL(string:stylePath){
//    //                if let styleData = try? Data(contentsOf: styleUrl) {
//    //                    mapView.customMapStyleEnabled = true
//    //                    mapView.setCustomMapStyleWithWebData(styleData)
//    //                }
//    //            }
//    //        }
//
//
//    self.mapView = mapView
}

-(CGFloat)statusBarHeight
{
    CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (height < 1) {
        height = 20;
    }
    return height;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
