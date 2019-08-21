//
//  FHTopicDetailViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHTopicDetailViewController.h"
#import "FHExploreDetailToolbarView.h"
#import "SSCommonLogic.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "FHCommentViewController.h"
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"
#import "FHTopicHeaderInfo.h"
#import "FHTopicSectionHeaderView.h"

@interface FHTopicDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong)   UIScrollView       *mainScrollView;
@property (nonatomic, strong)   UIImageView        *headerImageView;
@property (nonatomic, strong)   FHTopicHeaderInfo       *headerInfoView;
@property (nonatomic, strong)   FHTopicSectionHeaderView       *sectionHeaderView;
@property (nonatomic, assign)   CGFloat       minSubScrollViewHeight;
@property (nonatomic, assign)   CGFloat       maxSubScrollViewHeight;
@property (nonatomic, assign)   CGFloat       topHeightOffset;
@property (nonatomic, strong)   UIScrollView       *subScrollView;

@end

@implementation FHTopicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    [self setupDetailNaviBar];
    [self setNavBarTransparent:YES];
    // _mainScrollView
    _mainScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_mainScrollView];
    if (@available(iOS 11.0 , *)) {
         _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _mainScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _mainScrollView.delegate = self;
    
    // _headerImageView
    _headerImageView = [[UIImageView alloc] init];
    NSString *imageName = [NSString stringWithFormat:@"fh_ugc_community_detail_header_back0"];
    _headerImageView.image = [UIImage imageNamed:imageName];
    _headerImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 144);
    [self.mainScrollView addSubview:_headerImageView];
    
    // _headerInfoView
    _headerInfoView = [[FHTopicHeaderInfo alloc] init];
    _headerInfoView.frame = CGRectMake(0, 144, SCREEN_WIDTH, 50);
    [self.mainScrollView addSubview:_headerInfoView];
    
    // sectionHeaderView
    _sectionHeaderView = [[FHTopicSectionHeaderView alloc] init];
    _sectionHeaderView.frame = CGRectMake(0, 194, SCREEN_WIDTH, 50);
    [self.mainScrollView addSubview:_sectionHeaderView];
    // 244
    self.topHeightOffset = CGRectGetMaxY(self.sectionHeaderView.frame);
    
    // 计算subScrollView的高度
    CGFloat navOffset = 64;
    if (@available(iOS 11.0 , *)) {
        navOffset = 44.f + self.view.tt_safeAreaInsets.top;
    } else {
        navOffset = 64;
    }
    self.minSubScrollViewHeight = SCREEN_HEIGHT - self.topHeightOffset;// 暂时不用，数据较少时也可在下面展示空页面
    self.maxSubScrollViewHeight = SCREEN_HEIGHT - navOffset - 50;
    
    // subScrollView
    _subScrollView = [[UIScrollView alloc] init];
    if (@available(iOS 11.0 , *)) {
         _subScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _subScrollView.frame = CGRectMake(0, self.topHeightOffset, SCREEN_WIDTH, self.maxSubScrollViewHeight);
    _subScrollView.delegate = self;
    _subScrollView.backgroundColor = [UIColor whiteColor];
    [self.mainScrollView addSubview:self.subScrollView];
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.maxSubScrollViewHeight + self.topHeightOffset);
    
    // 添加子的tableView
    _subScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, self.maxSubScrollViewHeight);
    _subScrollView.pagingEnabled = YES;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.maxSubScrollViewHeight)];
    leftView.backgroundColor = [UIColor redColor];
    [_subScrollView addSubview:leftView];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, self.maxSubScrollViewHeight)];
    rightView.backgroundColor = [UIColor blueColor];
    [_subScrollView addSubview:rightView];
    
    // 空态页
    [self addDefaultEmptyViewFullScreen];
}

// 导航栏透明
- (void)setNavBarTransparent:(BOOL)transparent {
    if (!transparent) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:NO];
    } else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}

- (void)setupDetailNaviBar {
    self.customNavBarView.title.text = @"话题";
}

- (void)dealloc
{

}

#pragma mark - UIScrollViewDelegate
// mainScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollView) {
        
    }
}

@end
