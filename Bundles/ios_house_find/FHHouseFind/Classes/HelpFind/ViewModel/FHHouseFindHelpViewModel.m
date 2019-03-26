//
//  FHHouseFindHelpViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindHelpViewModel.h"
#import "FHHouseFindHelpBottomView.h"

@interface FHHouseFindHelpViewModel ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) FHHouseFindHelpBottomView *bottomView;

@end

@implementation FHHouseFindHelpViewModel

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView bottomView:(FHHouseFindHelpBottomView *)bottomView
{
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _bottomView = bottomView;
        __weak typeof(self)wself = self;
        _bottomView.resetBlock = ^{
            [wself resetBtnDidClick];
        };
        _bottomView.confirmBlock = ^{
            [wself confirmBtnDidClick];
        };
    }
    return self;
}

- (void)resetBtnDidClick
{
    
}

- (void)confirmBtnDidClick
{
    
}

@end
