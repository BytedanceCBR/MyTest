//
//  FHPersonalHomePageFeedViewModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/7.
//

#import "FHPersonalHomePageFeedViewModel.h"
#import "FHPersonalHomePageFeedCollectionViewCell.h"
#import "FHCommonDefines.h"


@interface FHPersonalHomePageFeedViewModel () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic,weak) FHPersonalHomePageFeedViewController *viewController;
@property(nonatomic,weak) UICollectionView *collectionView;
@property(nonatomic,strong) NSArray *titleArray;
@property(nonatomic,weak) FHPersonalHomePageFeedCollectionViewCell *currentCell;
@end

@implementation FHPersonalHomePageFeedViewModel

- (instancetype)initWithController:(FHPersonalHomePageFeedViewController *)viewController collectionView:(UICollectionView *)collectionView {
    if(self = [super init]) {
        _viewController = viewController;
        _collectionView = collectionView;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
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
    self.viewController.headerView.sectionTitles = self.titleArray;

    [self.collectionView reloadData];
    [self updateSelectCell:0];
}

- (void)updateSelectCell:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(index >= 0 && index < self.titleArray.count) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    });
}

#pragma mark collectionView protocol
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellClassName = NSStringFromClass([FHPersonalHomePageFeedCollectionViewCell class]);
    NSString *identifier = [NSString stringWithFormat:@"%@_%zd",cellClassName,indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if([cell isKindOfClass:[FHPersonalHomePageFeedCollectionViewCell class]]) {
        FHPersonalHomePageFeedCollectionViewCell *feedListCell = (FHPersonalHomePageFeedCollectionViewCell *)cell;
        feedListCell.viewController = self.viewController;
    }
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = self.collectionView.bounds.size;
    return cellSize;
}

@end
