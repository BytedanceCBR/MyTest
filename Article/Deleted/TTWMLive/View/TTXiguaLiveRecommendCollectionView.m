//
//  TTXiguaLiveRecommendCollectionView.m
//  Article
//
//  Created by lipeilun on 2017/12/5.
//

#import "TTXiguaLiveRecommendCollectionView.h"
#import "TTXiguaLiveRecommendNoPicLayout.h"
#import "TTXiguaLiveRecommendWithPicLayout.h"
#import "TTXiguaLiveRecommendNoPicCell.h"
#import "TTXiguaLiveRecommendWithPicCell.h"
#import "TTXiguaLiveRecommendNoPicSingleCell.h"
#import "TTXiguaLiveRecommendNoPicSingleLayout.h"
#import "TTXiguaLiveManager.h"
#import <SSImpressionManager.h>
#import "SSThemed.h"

static NSString *const kCellReuseIdentifier = @"kCellReuseIdentifier";

@interface TTXiguaLiveRecommendCollectionView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SSImpressionProtocol>
@property (nonatomic, copy) NSDictionary *extraDict;
@property (nonatomic, assign) BOOL isDisplay;
@end

@implementation TTXiguaLiveRecommendCollectionView

+ (TTXiguaLiveRecommendCollectionView *)collectionViewWithLayoutType:(TTXiguaLiveRecommendUserCellType)type {
    //为了预防以后像推人卡片一样增加各种出现动画特效等，用两个不一样的layout类
    Class cellClass;
    UICollectionViewFlowLayout *flowLayout;
    BOOL scrollable = YES;
    switch (type) {
        case TTXiguaLiveRecommendUserCellTypeWithPic:
            flowLayout = [[TTXiguaLiveRecommendWithPicLayout alloc] init];
            cellClass = [TTXiguaLiveRecommendWithPicCell class];
            break;
        case TTXiguaLiveRecommendUserCellTypeNoPicSingle:
            flowLayout = [[TTXiguaLiveRecommendNoPicSingleLayout alloc] init];
            cellClass = [TTXiguaLiveRecommendNoPicSingleCell class];
            scrollable = NO;
            break;
        case TTXiguaLiveRecommendUserCellTypeNoPic:
        default:
            flowLayout = [[TTXiguaLiveRecommendNoPicLayout alloc] init];
            cellClass = [TTXiguaLiveRecommendNoPicCell class];
            break;
    }
    TTXiguaLiveRecommendCollectionView *collectionView = [[TTXiguaLiveRecommendCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.delegate = collectionView;
    collectionView.dataSource = collectionView;
    collectionView.scrollEnabled = scrollable;
    collectionView.cellType = type;
    [collectionView registerClass:cellClass forCellWithReuseIdentifier:kCellReuseIdentifier];
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

+ (CGFloat)heightWithLayoutType:(TTXiguaLiveRecommendUserCellType)type {
    CGFloat result = 0;
    switch (type) {
        case TTXiguaLiveRecommendUserCellTypeWithPic:
            result = [TTDeviceUIUtils tt_newPadding:245.f];
            break;
        case TTXiguaLiveRecommendUserCellTypeNoPicSingle:
            result = [TTDeviceUIUtils tt_newPadding:94.f];
            break;
        case TTXiguaLiveRecommendUserCellTypeNoPic:
        default:
            result = [TTDeviceUIUtils tt_newPadding:130.f];
            break;
    }
    return result;
}

- (void)setCellDatas:(NSArray<TTXiguaLiveModel *> *)cellDatas {
    if (![self modelChanged:cellDatas]) {
        return;
    }
    
    _cellDatas = cellDatas;
    [self reloadData];
}

- (BOOL)modelChanged:(NSArray<TTXiguaLiveModel *> *)cellDatas {
    if (self.cellDatas.count != cellDatas.count) {
        return YES;
    }
    
    NSInteger index = 0;
    for (TTXiguaLiveModel *model in cellDatas) {
        if (![model isEqual:self.cellDatas[index++]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)willDisplay {
    _isDisplay = YES;
    for (TTXiguaLiveRecommendBaseCell *cell in self.visibleCells) {
        [cell tryBeginAnimation];
    }
    
    [[SSImpressionManager shareInstance] enterXiguaLiveRecommendWithCategoryName:[self _categoryName] cellID:[self _cellId]];
    [[SSImpressionManager shareInstance] addRegist:self];
    
}

- (void)didEndDisplaying {
    _isDisplay = NO;
    for (TTXiguaLiveRecommendBaseCell *cell in self.visibleCells) {
        [cell tryStopAnimation];
    }
    [[SSImpressionManager shareInstance] leaveXiguaLiveRecommendWithCategoryName:[self _categoryName] cellID:[self _cellId]];
}

//impression需要
- (NSString*)_cellId {
    if (self.trackDelegate && [self.trackDelegate respondsToSelector:@selector(xiguaLiveImpressionCellId)]) {
        return [self.trackDelegate xiguaLiveImpressionCellId];
    }
    
    return @"";
}

//impression需要
- (NSString*)_categoryName {
    if (self.trackDelegate && [self.trackDelegate respondsToSelector:@selector(xiguaLiveImpressionCategoryName)]) {
        return [self.trackDelegate xiguaLiveImpressionCategoryName];
    }
    
    return @"";
}

- (void)needRerecordImpressions {
    if (self.cellDatas.count == 0) {
        return;
    }
    
    for (NSIndexPath* indexPath in self.indexPathsForVisibleItems) {
        if (self.cellDatas.count > indexPath.item) {
            TTXiguaLiveModel *xiguaModel = self.cellDatas[indexPath.item];
            [[SSImpressionManager shareInstance] recordXiguaLiveRecommendGroupId:xiguaModel.groupId
                                                                    categoryName:[self _categoryName]
                                                                          cellId:[self _cellId]
                                                                          status:_isDisplay ? SSImpressionStatusRecording : SSImpressionStatusSuspend
                                                                          params:nil];
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateCardPositionIndex:indexPath.item + 1 model:[self.cellDatas objectAtIndex:indexPath.item]];
    UIViewController *audienceVC = [[TTXiguaLiveManager sharedManager] audienceRoomWithUserID:[[self.cellDatas objectAtIndex:indexPath.item] liveUserInfoModel].userId extraInfo:self.extraDict];
    [self.navigationController pushViewController:audienceVC animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TTXiguaLiveRecommendBaseCell class]]) {
        [(TTXiguaLiveRecommendBaseCell *)cell tryBeginAnimation];
    }
    if (self.cellDatas.count == 0 || self.cellDatas.count <= indexPath.item) {
        return;
    }
    
    TTXiguaLiveModel *xiguaModel = [self.cellDatas objectAtIndex:indexPath.item];
    if (xiguaModel) {
        [[SSImpressionManager shareInstance] recordXiguaLiveRecommendGroupId:xiguaModel.groupId
                                                                categoryName:[self _categoryName]
                                                                      cellId:[self _cellId]
                                                                      status:_isDisplay ? SSImpressionStatusRecording : SSImpressionStatusSuspend
                                                                      params:nil];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TTXiguaLiveRecommendBaseCell class]]) {
        [(TTXiguaLiveRecommendBaseCell *)cell tryStopAnimation];
    }
    
    if (self.cellDatas.count == 0 || self.cellDatas.count <= indexPath.item) {
        return;
    }
    
    TTXiguaLiveModel *xiguaModel = [self.cellDatas objectAtIndex:indexPath.item];
    if (xiguaModel) {
        [[SSImpressionManager shareInstance] recordXiguaLiveRecommendGroupId:xiguaModel.groupId
                                                                categoryName:[self _categoryName]
                                                                      cellId:[self _cellId]
                                                                      status:SSImpressionStatusEnd
                                                                      params:nil];
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
    TTXiguaLiveRecommendBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [cell configWithModel:[self.cellDatas objectAtIndex:indexPath.item]];
    if (self.cellType == TTXiguaLiveRecommendUserCellTypeNoPicSingle) {
        [(TTXiguaLiveRecommendNoPicSingleCell *)cell refreshLayerUI];
        [(TTXiguaLiveRecommendNoPicSingleCell *)cell setExtraDict:self.extraDict];
        [self updateCardPositionIndex:1 model:[self.cellDatas objectAtIndex:indexPath.item]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    switch (self.cellType) {
        case TTXiguaLiveRecommendUserCellTypeWithPic:
            size = CGSizeMake([TTDeviceUIUtils tt_newPadding:147.f], [TTDeviceUIUtils tt_newPadding:221.f]);
            break;
        case TTXiguaLiveRecommendUserCellTypeNoPicSingle:
            size = CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:12.f], [TTDeviceUIUtils tt_newPadding:74.f]);
            break;
        case TTXiguaLiveRecommendUserCellTypeNoPic:
        default:
            size = CGSizeMake([TTDeviceUIUtils tt_newPadding:198.f], [TTDeviceUIUtils tt_newPadding:111.f]);
            break;
    }
    return size;
}

#pragma mark - GET
- (NSDictionary *)extraDict {
    if ([self.trackDelegate respondsToSelector:@selector(trackExtraParamDict)]) {
        return [self.trackDelegate trackExtraParamDict];
    }
    return nil;
}

#pragma mark - util

- (void)updateCardPositionIndex:(NSInteger)index model:(TTXiguaLiveModel *)model {
    NSMutableDictionary *meDict = [self.extraDict mutableCopy];
    [meDict setValue:@(index) forKey:@"card_position"];
    switch (self.cellType) {
        case TTXiguaLiveRecommendUserCellTypeWithPic:
            [meDict setValue:@"vertical_images_cards" forKey:@"cell_type"];
            break;
        case TTXiguaLiveRecommendUserCellTypeNoPicSingle:
            [meDict setValue:@"none_image" forKey:@"cell_type"];
            break;
        case TTXiguaLiveRecommendUserCellTypeNoPic:
        default:
            [meDict setValue:@"horizontal_title_cards" forKey:@"cell_type"];
            break;
    }
    self.extraDict = meDict.copy;

}

@end








































