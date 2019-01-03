//
//  FHHouseFindListViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindListViewModel.h"
#import "FHHouseFindCollectionCell.h"

#define kFHHouseFindCollectionViewCell @"kFHHouseFindCollectionViewCell"
@interface FHHouseFindListViewModel () <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,weak)UICollectionView *collectionView;
@end

@implementation FHHouseFindListViewModel

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    
    self = [super init];
    if (self) {
        
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        
        [self.collectionView registerClass:[FHHouseFindCollectionCell class] forCellWithReuseIdentifier:kFHHouseFindCollectionViewCell];
    }
    
    return self;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFHHouseFindCollectionViewCell forIndexPath:indexPath];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

    //    if ((_userDrag && ![self.lastCategoryID isEqualToString:self.currentCategory.categoryID]) || _userClick) {
//        if ([[cell class] conformsToProtocol:@protocol(TTFeedCollectionCell)]) {
//            id<TTFeedCollectionCell> collectionCell = (id<TTFeedCollectionCell>)cell;
//
//            if ([collectionCell respondsToSelector:@selector(willDisappear)]) {
//                [collectionCell willDisappear];
//            }
//
//            TTCategory *category = [self categoryAtIndex:indexPath.item];
//            [self leaveCategory:category];
//
//            if ([collectionCell respondsToSelector:@selector(didDisappear)]) {
//                [collectionCell didDisappear];
//            }
//        }
//    }
}


@end
