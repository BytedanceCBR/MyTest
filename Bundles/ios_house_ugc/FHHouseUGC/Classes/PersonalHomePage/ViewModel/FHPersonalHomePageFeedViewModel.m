//
//  FHPersonalHomePageFeedViewModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/7.
//

#import "FHPersonalHomePageFeedViewModel.h"
#import "FHPersonalHomePageFeedCollectionViewCell.h"
#import "FHPersonalHomePageFeedListViewController.h"
#import "FHPersonalHomePageManager.h"
#import "FHCommonDefines.h"


@interface FHPersonalHomePageFeedViewModel () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property(nonatomic,weak) FHPersonalHomePageFeedViewController *viewController;
@property(nonatomic,weak) UICollectionView *collectionView;
@property(nonatomic,strong) NSArray *titleArray;
@property(nonatomic,weak) FHPersonalHomePageTabListModel *tabListModel;
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
    self.tabListModel = model;
    
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

    if(model.data.tabList.count > 0) {
        self.homePageManager.isNoFeed = NO;
        [self.collectionView reloadData];
        [self updateSelectCell:0];
    } else {
        self.homePageManager.isNoFeed = YES;
        [self.viewController.emptyView showEmptyWithTip:@"TA没有留下任何足迹，去其他地方看看吧！" errorImageName:@"fh_ugc_home_page_no_auth" showRetry:NO];
    }
}

- (void)updateSelectCell:(NSInteger)index {
    if(index >= 0 && index < self.titleArray.count) {
        self.homePageManager.currentIndex = index;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self feedListVCLoadData:index];
    }
}

#pragma mark collectionView protocol
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    NSString *cellClassName = NSStringFromClass([FHPersonalHomePageFeedCollectionViewCell class]);
    NSString *identifier = [NSString stringWithFormat:@"%@_%zd",cellClassName,indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if([cell isKindOfClass:[FHPersonalHomePageFeedCollectionViewCell class]]) {
        FHPersonalHomePageFeedCollectionViewCell *feedListCell = (FHPersonalHomePageFeedCollectionViewCell *)cell;
        if(index >= 0 && index < self.tabListModel.data.tabList.count) {
            FHPersonalHomePageTabItemModel *itemModel = self.tabListModel.data.tabList[index];
            [feedListCell updateHomePageManager:self.homePageManager TabName:itemModel.name index:index];
            if(index == self.homePageManager.currentIndex) {
                [self feedListVCLoadData:index];
            }
        }
    }
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = self.collectionView.bounds.size;
    return cellSize;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self feedListVCLoadData:self.homePageManager.currentIndex];
}

- (void)feedListVCLoadData:(NSInteger)index {
    if(index >= 0 && index < self.homePageManager.feedListVCArray.count) {
        FHPersonalHomePageFeedListViewController *feedVC = self.homePageManager.feedListVCArray[index];
        if([feedVC isKindOfClass:[FHPersonalHomePageFeedListViewController class]]) {
            [feedVC firstLoadData];
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.homePageManager collectionViewBeginScroll:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.homePageManager collectionViewDidScroll:scrollView];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.homePageManager collectionViewDidEndDragging:scrollView];
}

@end
