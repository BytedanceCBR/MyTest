//
//  NIHFeedCollectionHouseCell.m
//  Article
//
//  Created by 张静 on 2018/9/7.
//

#import "NIHFeedCollectionHouseCell.h"
#import "UIScrollView+Refresh.h"
#import "TTDeviceHelper.h"
#import "TTCategory.h"
#import "Bubble-Swift.h"
#import "TTTopBar.h"
#import "UIScrollView+Refresh.h"

@interface NIHFeedCollectionHouseCell () // <ExploreMixedListBaseViewDelegate>
//@property (nonatomic, strong) ExploreMixedListView *listView;
@property (nonatomic, strong) TTCategory *category;

@property (nonatomic, strong) HomeViewController *houseListViewController;

@end

@implementation NIHFeedCollectionHouseCell

@synthesize sourceViewController = _sourceViewController;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)willAppear {
    [self.houseListViewController willAppear];
}

- (void)didAppear {
    [self.houseListViewController didAppear];
}

- (void)willDisappear {
    [self.houseListViewController willDisappear];
}

- (void)didDisappear {
    [self.houseListViewController didDisappear];
}

- (void)setupCellModel:(nonnull id<TTFeedCategory>)model isDisplay:(BOOL)isDisplay {
    
    // Configure the cell
    if ([model isKindOfClass:[TTCategory class]]) {
        if (_category != model) {
            _category = (TTCategory *)model;
            [self configHouseListVC];
        }
//        [self.feedListViewController refreshFeedListForCategory:self.category isDisplayView:isDisplay fromLocal:YES fromRemote:NO reloadFromType:TTReloadTypeNone getRemoteWhenLocalEmpty:NO];
    }
    
}

- (void)configHouseListVC
{
    if (self.houseListViewController) {
        [self.houseListViewController prepareForReuse];
        return;
    }
    CGFloat topPadding = 0;
    CGFloat bottomPadding = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom + 44;
    
    if ([TTDeviceHelper isPadDevice]) {
        topPadding = 64 + 44;
    }
    self.houseListViewController = [[HomeViewController alloc] init];
//    self.houseListViewController.delegate = self;
    UIViewController *viewController = self.sourceViewController;
    [viewController addChildViewController:self.houseListViewController];
    [self.contentView addSubview:self.houseListViewController.view];
    [self.houseListViewController didMoveToParentViewController:viewController];
    [self.houseListViewController setListTopInset:topPadding BottomInset:bottomPadding];

    CGFloat statusBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    CGFloat topOffset = statusBarHeight + kTopSearchButtonHeight;
    topOffset = 0;
    [self.houseListViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(topOffset);
        make.left.right.bottom.equalTo(@0);
    }];
}

- (void)refreshDataWithType:(ListDataOperationReloadFromType)refreshType
{
    self.houseListViewController.reloadFromType = (TTReloadType)refreshType;
    
    [self triggerPullRefresh];
}

- (void)triggerPullRefresh
{
    [self.houseListViewController pullAndRefresh];
}

@end
