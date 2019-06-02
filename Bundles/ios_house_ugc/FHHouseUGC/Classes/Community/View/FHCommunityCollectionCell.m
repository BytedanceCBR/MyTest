//
//  FHCommunityCollectionCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHCommunityCollectionCell.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "FHNearbyViewController.h"
#import "FHMyJoinViewController.h"

@interface FHCommunityCollectionCell ()

@property(nonatomic, strong) UIViewController *vc;

@end

@implementation FHCommunityCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        _type = FHCommunityCollectionCellTypeNone;
    }
    
    return self;
}

- (void)setType:(FHCommunityCollectionCellType)type {
    if(_type == FHCommunityCollectionCellTypeNone){
        _type = type;
        [self initViews];
    }
}

- (void)initViews {
    switch (self.type) {
        case FHCommunityCollectionCellTypeNearby:
            self.vc = [[FHNearbyViewController alloc] init];
            [self.contentView addSubview:_vc.view];
            break;
        case FHCommunityCollectionCellTypeMyJoin:
            self.vc = [[FHMyJoinViewController alloc] init];
            [self.contentView addSubview:_vc.view];
            break;
        case FHCommunityCollectionCellTypeDiscovery:
            self.vc = [[ArticleTabBarStyleNewsListViewController alloc] init];
            [self.contentView addSubview:_vc.view];
            break;
            
        default:
            break;
    }
}

@end
