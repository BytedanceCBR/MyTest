//
//  TTVHomeViewController.m
//  Article
//
//  Created by pei yun on 2017/3/22.
//
//

#import "TTVHomeViewController.h"
#import "TTVScrollableSegmentControl.h"
#import "TTVFeedListViewController.h"
#import "TTVSegmentedPageViewController.h"
#import "TTVLabelSegmentedControl.h"
#import "NSArray+BlocksKit.h"

#import "TTVideoCategoryManager.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "CommonURLSetting.h"
#import "TTCategory+ConfigDisplayName.h"

@interface TTVHomeViewController () <TTVSegmentedPageViewDelegate, TTVScrollableSegmentControlDelegate>

@property (nonatomic, strong) TTVSegmentedPageViewController *segmentedPageVC;
@property (nonatomic, strong) NSArray *categories;

@end

@implementation TTVHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.segmentedPageVC = [[TTVSegmentedPageViewController alloc] init];
    _segmentedPageVC.viewFrame = CGRectMake(0, 20 + 44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
    _segmentedPageVC.pageDelegate = self;
    [self addChildViewController:_segmentedPageVC];
}

- (void)setCategories:(NSArray *)categories
{
    if (_categories != categories) {
        _categories = categories;
        if ([_categories count] > 0) {
            NSArray *titlesArray = [categories bk_map:^NSString *(TTCategory *category) {
                return [category adjustDisplayName];
            }];
            [self configureSegmentedPage:titlesArray];
        }
    }
}

- (void)configureSegmentedPage:(NSArray *)titles {
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:titles.count];
    for (int i = 0; i < titles.count; i ++) {
        TTVFeedListViewController *vc = [[TTVFeedListViewController alloc] init];
        [viewControllers addObject:vc];
    }
    TTVScrollableLabelSegmentControl *segmentControl = [[TTVScrollableLabelSegmentControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 2 * 20, 44)];
    segmentControl.titles = titles;
    segmentControl.visibleItemCount = 5.5;
    segmentControl.segmentedControlDelegate = self;
//    TTVLabelSegmentedControl *segmentControl = [TTVLabelSegmentedControl segmentedControlWithTitles:titles];
//    segmentControl.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 2 * 20, 44);
//    [segmentControl layoutTabs];
    [_segmentedPageVC setViewControllers:viewControllers segmentedControl:segmentControl];
    self.navigationItem.titleView = segmentControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UIView *view = self.segmentedPageVC.view;
        view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
        [self.view addSubview:view];
        [_segmentedPageVC didMoveToParentViewController:self];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fetchCategoryData];
    });
}

- (void)fetchCategoryData
{
    self.categories = [[TTVideoCategoryManager sharedManager] videoCategoriesWithDataDicts:nil];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting videoCategoryURLString] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error) {
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                NSArray *categories = jsonObj[@"data"];
                self.categories = [[TTVideoCategoryManager sharedManager] videoCategoriesWithDataDicts:categories];
            }
        }
    }];
}

- (void)loadDataWhenNeeded
{
    UIViewController *viewController = self.segmentedPageVC.viewControllers[self.segmentedPageVC.currentPageIndex];
    if ([viewController conformsToProtocol:@protocol(TTVSegmentedPageLoadDataProtocol)] && [viewController respondsToSelector:@selector(loadDataWhenNeeded)]) {
        [((id<TTVSegmentedPageLoadDataProtocol>)viewController) loadDataWhenNeeded];
    }
}

#pragma mark - TTVSegmentedPageViewDelegate 

- (void)viewControllerDidBecomeVisible:(UIViewController *)viewController firstAppear:(BOOL)firstAppear isSwiping:(BOOL)isSwiping
{
//    viewController.view.backgroundColor = self.segmentedPageVC.currentPageIndex % 2 == 0 ? [UIColor blueColor] : [UIColor yellowColor];
    if ([viewController.view isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)viewController.view).scrollsToTop = YES;
    }
    
    [self loadDataWhenNeeded];
}

- (void)viewControllerDidBecomeInvisible:(UIViewController *)viewController isSwiping:(BOOL)isSwiping
{
    if ([viewController.view isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)viewController.view).scrollsToTop = NO;
    }
}

- (void)viewControllerFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    // 添加统计事件
}

#pragma mark - TTVScrollableSegmentControlDelegate

@end
