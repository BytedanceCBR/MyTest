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
        [self.contentView addSubview:self.feedVC.view];
        
        self.feedVC.cell = self;
    }
    return self;
}

@end
