//
//  FHPersonalHomePageFeedCollectionViewCell.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/7.
//

#import "FHPersonalHomePageFeedCollectionViewCell.h"
#import "FHPersonalHomePageFeedListViewController.h"

@interface FHPersonalHomePageFeedCollectionViewCell ()
@property(nonatomic,strong) FHPersonalHomePageFeedListViewController *feedVC;
@property(nonatomic,assign) BOOL isFirstLoad;
@end

@implementation FHPersonalHomePageFeedCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.feedVC = [[FHPersonalHomePageFeedListViewController alloc] init];
        self.feedVC.view.frame = self.contentView.frame;
        self.feedVC.tableView.frame = self.contentView.frame;
        [self.contentView addSubview:self.feedVC.view];
        self.isFirstLoad = NO;
    }
    return self;
}


- (void)updateTabName:(NSString *)tabName index:(NSInteger)index {
    self.feedVC.tabName = tabName;
    self.feedVC.index = index;
}

-(void)setHomePageManager:(FHPersonalHomePageManager *)homePageManager {
    _homePageManager = homePageManager;
    _feedVC.homePageManager = homePageManager;
    [_homePageManager.feedListVCArray addObject:_feedVC];
}

-(void)startLoadData {
    if(!self.isFirstLoad) {
        self.isFirstLoad = YES;
        [self.feedVC startLoadData];
    }
}

@end
