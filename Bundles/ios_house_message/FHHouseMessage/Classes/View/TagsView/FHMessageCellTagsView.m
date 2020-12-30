//
//  FHMessageCellTagsView.m
//  FHHouseMessage
//
//  Created by wangzhizhou on 2020/12/21.
//

#import "FHMessageCellTagsView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "FHMessageCellTagsViewLayout.h"
#import "FHMessageTagViewCell.h"
#import <Masonry.h>
#import <ByteDanceKit.h>

@interface FHMessageCellTagsView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) FHMessageCellTagsViewLayout *layout;
@property (nonatomic, copy) NSArray<FHMessageCellTagModel *> *tags;
@end

@implementation FHMessageCellTagsView
- (FHMessageCellTagsViewLayout *)layout {
    if(!_layout) {
        _layout = [[FHMessageCellTagsViewLayout alloc] init];
        _layout.minimumInteritemSpacing = 2;
        _layout.minimumLineSpacing = 2;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.estimatedItemSize = CGSizeMake(118, 16);
        _layout.sectionInset = UIEdgeInsetsZero;
    }
    return _layout;
}
- (UICollectionView *)collectionView {
    if(!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        [_collectionView registerClass:FHMessageTagViewCell.class forCellWithReuseIdentifier:[FHMessageTagViewCell reuseIdentifier]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}
- (instancetype)init {
    if(self = [super init]) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}
- (void)updateWithTags:(NSArray<FHMessageCellTagModel *> *)tags {
    self.tags = [tags sortedArrayUsingComparator:^NSComparisonResult(FHMessageCellTagModel *  _Nonnull obj1, FHMessageCellTagModel *  _Nonnull obj2) {
        if(obj1.priority < obj2.priority) {
            return NSOrderedAscending;
        } else if(obj1.priority == obj2.priority) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tags.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHMessageTagViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[FHMessageTagViewCell reuseIdentifier] forIndexPath:indexPath];
    if(indexPath.row >= 0 && indexPath.row < self.tags.count) {
        FHMessageCellTagModel *tag = [self.tags btd_objectAtIndex:indexPath.row];
        [cell updateWithTag:tag];
    }
    return cell;
}

#pragma mark - 点击事件透传
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if(self.isPassthrough) {
        CGPoint btnPointInA = [self.collectionView convertPoint:point fromView:self];
        if ([self.collectionView pointInside:btnPointInA withEvent:event]) {
            return self.superview;
        }
    }
    
    // 否则，返回默认处理
    return [super hitTest:point withEvent:event];
}
@end
