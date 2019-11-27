//
//  FHHomeMainViewModel.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHHomeMainViewModel.h"
#import "FHHomeMainViewController.h"
#import "FHHomeMainHouseCollectionCell.h"
#import "FHHomeMainFeedCollectionCell.h"

@interface FHHomeMainViewModel()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , weak) FHHomeMainViewController *viewController;
@end

@implementation FHHomeMainViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        [self registerCollectionCells];
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        self.viewController = (FHHomeMainViewController *)viewController;
    }
    return self;
}

- (void)registerCollectionCells
{
    [self.collectionView registerClass:[FHHomeMainHouseCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHHomeMainHouseCollectionCell class])];
    [self.collectionView registerClass:[FHHomeMainFeedCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHHomeMainFeedCollectionCell class])];
}

#pragma mark - UICollectionViewDelegate
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = NSStringFromClass([FHHomeMainBaseCollectionCell class]);

    if (indexPath.row == 0) {
        cellIdentifier = NSStringFromClass([FHHomeMainHouseCollectionCell class]);
    }else
    {
        cellIdentifier = NSStringFromClass([FHHomeMainFeedCollectionCell class]);
    }

    FHHomeMainBaseCollectionCell *cell = (FHHomeMainBaseCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    if (cell.contentVC) {
        [self.viewController addChildViewController:cell.contentVC];
    }
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollBegin" object:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

//侧滑切换tab
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:scrollView];
}


@end
