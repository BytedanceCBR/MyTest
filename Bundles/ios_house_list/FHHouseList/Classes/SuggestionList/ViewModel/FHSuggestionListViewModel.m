//
//  FHSuggestionListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewModel.h"
#import "FHSuggestionListViewController.h"
#import "FHSuggestionCollectionViewCell.h"

@interface FHSuggestionListViewModel ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic , weak) FHSuggestionListViewController *listController;
@property (nonatomic, weak) FHBaseCollectionView *collectionView;
@end

@implementation FHSuggestionListViewModel

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
    }
    return self;
}

- (void)initCollectionView:(FHBaseCollectionView *)collectionView
{
    self.collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.collectionView registerClass:[FHSuggestionCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHSuggestionCollectionViewCell class])];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = NSStringFromClass([FHSuggestionCollectionViewCell class]);
    FHSuggestionCollectionViewCell *cell = (FHSuggestionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSInteger row = indexPath.item;
    if (row % 2 == 1) {
        cell.backgroundColor = [UIColor redColor];
    } else {
        cell.backgroundColor = [UIColor blackColor];
    }
    return cell;
}
@end
