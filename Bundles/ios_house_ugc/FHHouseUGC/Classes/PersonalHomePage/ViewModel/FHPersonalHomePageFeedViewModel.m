//
//  FHPersonalHomePageFeedViewModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/7.
//

#import "FHPersonalHomePageFeedViewModel.h"
#import "FHPersonalHomePageFeedHeaderView.h"
#import "FHPersonalHomePageFeedCollectionViewCell.h"
#import "FHCommonDefines.h"


@interface FHPersonalHomePageFeedViewModel () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic,weak) FHPersonalHomePageFeedViewController *viewController;
@property(nonatomic,weak) UICollectionView *collectionView;
@property(nonatomic,strong) NSArray *titleArray;
@end


@implementation FHPersonalHomePageFeedViewModel

- (instancetype)initWithController:(FHPersonalHomePageFeedViewController *)viewController collectionView:(UICollectionView *)collectionView {
    if(self = [super init]) {
        _viewController = viewController;
        _collectionView = collectionView;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [self.collectionView registerClass:[FHPersonalHomePageFeedHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FHPersonalHomePageFeedHeaderView class])];
    }
    return self;
}


-(void)updateWithHeaderViewMdoel:(FHPersonalHomePageTabListModel *)model {
    NSMutableArray *titleArray = [NSMutableArray array];
    
    Class cellClass = [FHPersonalHomePageFeedCollectionViewCell class];
    NSString *cellClassName = NSStringFromClass(cellClass);
    
    for(NSInteger i = 0;i < model.data.tabList.count; i++) {
        NSString *identifier = [NSString stringWithFormat:@"%@_%zd",cellClassName,i];
        [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
        
        FHPersonalHomePageTabItemModel *itemModel = model.data.tabList[i];
        if(!IS_EMPTY_STRING(itemModel.showName)) {
            [titleArray addObject:itemModel.showName];
        }
    }
    self.titleArray = titleArray;
    [self.collectionView reloadData];
}



#pragma mark collectionView protocol
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellClassName = NSStringFromClass([FHPersonalHomePageFeedCollectionViewCell class]);
    NSString *identifier = [NSString stringWithFormat:@"%@_%zd",cellClassName,indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FHPersonalHomePageFeedHeaderView class]) forIndexPath:indexPath];
    if([reusableView isKindOfClass:[FHPersonalHomePageFeedHeaderView class]]) {
        FHPersonalHomePageFeedHeaderView *headerView = (FHPersonalHomePageFeedHeaderView *)reusableView;
        [headerView updateWithTitles:self.titleArray];
    }
    return reusableView;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 44);
}

@end
