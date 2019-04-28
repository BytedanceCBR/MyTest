//
//  TTPopularHashtagCollectionView.m
//  Article
//
//  Created by lipeilun on 2018/1/17.
//

#import "TTPopularHashtagCollectionView.h"
#import "TTPopularHashtagCollectionViewCell.h"
#import <UIColor+TTThemeExtension.h>
#import <TTRoute/TTRoute.h>
#import <SSImpressionManager.h>

@interface TTPopularHashtagCollectionView() <UICollectionViewDelegate, UICollectionViewDataSource, SSImpressionProtocol>
@property (nonatomic, assign) BOOL isDisplay;

@end

@implementation TTPopularHashtagCollectionView

+ (TTPopularHashtagCollectionView *)collectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = [TTDeviceUIUtils tt_newPadding:12];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    TTPopularHashtagCollectionView *collectionView = [[TTPopularHashtagCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.delegate = collectionView;
    collectionView.dataSource = collectionView;
    collectionView.scrollEnabled = NO;
    [collectionView registerClass:[TTPopularHashtagCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TTPopularHashtagCollectionViewCell class])];
    return collectionView;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        self.showsHorizontalScrollIndicator = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setCellDatas:(NSArray<FRForumStructModel *> *)cellDatas {
    if (![self modelChanged:cellDatas]) {
        return;
    }
    
    _cellDatas = cellDatas;
    [self reloadData];
}

- (BOOL)modelChanged:(NSArray<FRForumStructModel *> *)cellDatas {
    if (self.cellDatas.count != cellDatas.count) {
        return YES;
    }

    NSInteger index = 0;
    for (FRForumStructModel *model in cellDatas) {
        if (![model isEqual:self.cellDatas[index++]]) {
            return YES;
        }
    }

    return NO;
}

- (void)willDisplay {
    _isDisplay = YES;

    [[SSImpressionManager shareInstance] enterPopularHashtagWithCategoryName:[self _categoryName] cellID:[self _cellId]];
    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)didEndDisplaying {
    _isDisplay = NO;
    [[SSImpressionManager shareInstance] leavePopularHashtagWithCategoryName:[self _categoryName] cellID:[self _cellId]];
}

//impression需要
- (NSString*)_cellId {
    if (self.trackDelegate && [self.trackDelegate respondsToSelector:@selector(popularHashtagImpressionCellId)]) {
        return [self.trackDelegate popularHashtagImpressionCellId];
    }

    return @"";
}

//impression需要
- (NSString*)_categoryName {
    if (self.trackDelegate && [self.trackDelegate respondsToSelector:@selector(popularHashtagImpressionCategoryName)]) {
        return [self.trackDelegate popularHashtagImpressionCategoryName];
    }

    return @"";
}

- (void)needRerecordImpressions {
    if (self.cellDatas.count == 0) {
        return;
    }

    for (NSIndexPath* indexPath in self.indexPathsForVisibleItems) {
        if (self.cellDatas.count > indexPath.item) {
            FRForumStructModel *model = self.cellDatas[indexPath.item];
            [[SSImpressionManager shareInstance] recordPopularHashtagConcernId:model.concern_id.stringValue
                                                                  categoryName:[self _categoryName]
                                                                        cellId:[self _cellId]
                                                                        status:_isDisplay ? SSImpressionStatusRecording : SSImpressionStatusSuspend
                                                                          rank:indexPath.item + 1];
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    FRForumStructModel *model = self.cellDatas[indexPath.item];
    NSString *schema = model.schema;
    if (!isEmptyString(schema)) {
        schema = [schema stringByAppendingString:[NSString stringWithFormat:@"&from_page=hot_topic&rank=%ld", indexPath.item + 1]];
        if ([[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:schema]]) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:schema]];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.cellDatas.count) {
        return;
    }
    FRForumStructModel *model = [self.cellDatas objectAtIndex:indexPath.item];
    if (model) {
        [[SSImpressionManager shareInstance] recordPopularHashtagConcernId:model.concern_id.stringValue
                                                              categoryName:[self _categoryName]
                                                                    cellId:[self _cellId]
                                                                    status:_isDisplay ? SSImpressionStatusRecording : SSImpressionStatusSuspend
                                                                      rank:indexPath.item + 1];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.cellDatas.count) {
        return;
    }
    FRForumStructModel *model = [self.cellDatas objectAtIndex:indexPath.item];
    if (model) {
        [[SSImpressionManager shareInstance] recordPopularHashtagConcernId:model.concern_id.stringValue
                                                              categoryName:[self _categoryName]
                                                                    cellId:[self _cellId]
                                                                    status:SSImpressionStatusEnd
                                                                      rank:indexPath.item + 1];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellDatas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTPopularHashtagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTPopularHashtagCollectionViewCell class]) forIndexPath:indexPath];
    [cell configWithModel:[self.cellDatas objectAtIndex:indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.width - [TTDeviceUIUtils tt_newPadding:12.f] ) /2, [TTDeviceUIUtils tt_newPadding:54.f]);
}

@end
