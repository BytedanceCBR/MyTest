//
//  FHNearbyViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHNearbyViewController.h"
#import "FHHotTopicView.h"
#import "FHInterestCommunityView.h"
#import "UIColor+Theme.h"
#import "FHCommunityFeedListController.h"

@interface FHNearbyViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) FHHotTopicView *hotTopicView;
@property(nonatomic, strong) FHInterestCommunityView *interestCommunityView;
@property(nonatomic, strong) UIView *feedListView;

@end

@implementation FHNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initConstraints];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _scrollView.backgroundColor = [UIColor themeGray7];
    [self.view addSubview:_scrollView];
    
    self.hotTopicView = [[UIView alloc] init];
    _hotTopicView.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview:_hotTopicView];
    
    self.interestCommunityView = [[UIView alloc] init];
    _interestCommunityView.backgroundColor = [UIColor yellowColor];
    [self.scrollView addSubview:_interestCommunityView];
    
    self.feedListView = [[UIView alloc] init];
    _feedListView.backgroundColor = [UIColor greenColor];
    [self.scrollView addSubview:_feedListView];
    
    FHCommunityFeedListController *vc =[[FHCommunityFeedListController alloc] init];
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.feedListView addSubview:vc.view];
}

- (void)initConstraints {
//    CGFloat bottom = 49;
//    if (@available(iOS 11.0 , *)) {
//        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
//    }
//
//    CGFloat top = 44;
//    CGFloat safeTop = 0;
//    if (@available(iOS 11.0, *)) {
//        safeTop =  [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
//    }
//    if (safeTop > 0) {
//        top += safeTop;
//    }else{
//        top += [[UIApplication sharedApplication]statusBarFrame].size.height;
//    }
//
//    CGFloat height = [UIScreen mainScreen].bounds.size.height - top - bottom;
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.view);
//        make.height.mas_equalTo(height);
    }];
    
    [self.hotTopicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.scrollView);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [self.interestCommunityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.view);
        make.top.mas_equalTo(self.hotTopicView.mas_bottom).offset(8);
        make.height.mas_equalTo(150);
    }];
    
    [self.feedListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.interestCommunityView.mas_bottom).offset(8);
        make.left.mas_equalTo(self.scrollView);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom);
    }];
}

@end
