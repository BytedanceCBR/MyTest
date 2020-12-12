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
@end

@implementation FHPersonalHomePageFeedCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.feedVC = [[FHPersonalHomePageFeedListViewController alloc] init];
        self.feedVC.view.frame = self.contentView.frame;
        self.feedVC.tableView.frame = self.contentView.frame;
        self.feedVC.emptyView.frame = self.contentView.frame;
        [self.contentView addSubview:self.feedVC.view];
    }
    return self;
}


-(void)updateHomePageManager:(FHPersonalHomePageManager *)homePageManager TabName:(NSString *)tabName index:(NSInteger)index {
    self.homePageManager = homePageManager;
    self.feedVC.homePageManager = homePageManager;
    self.feedVC.tabName = tabName;
    self.feedVC.index = index;
    self.homePageManager.feedListVCArray[index] = self.feedVC;
}

@end
