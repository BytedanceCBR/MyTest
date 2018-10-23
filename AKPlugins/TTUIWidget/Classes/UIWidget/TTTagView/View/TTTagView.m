//
//  TTTagView.m
//  Article
//
//  Created by 王霖 on 4/19/16.
//
//

#import "TTTagView.h"
#import "TTTagItem.h"
#import "TTTagViewConfig.h"
#import "TTTagCollectionViewCell.h"
#import "TTLeftCollectionViewFlowLayout.h"
#import "TTCenterCollectionViewFlowLayout.h"
#import "NSObject+MultiDelegates.h"

@class ObjectType;

@interface TTTagView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong, nullable) Class clazz;
@property (nonatomic, copy, nullable)   TTTagViewConfig *config;
@property (nonatomic, strong)           NSMutableArray <ObjectType *> *tagItems;
@property (nonatomic, strong)           UICollectionView *tagCollectionView;

@end

@implementation TTTagView

static NSString *cellIdentifier = @"cellIdentifier";

#pragma mark -- Life Circle


- (instancetype)initWithFrame:(CGRect)frame configuration:(TTTagViewConfig *)config alignment:(TTTagViewAlignment)alignment {
    self = [super initWithFrame:frame];
    if (self) {
        _rowNumber = 0;
        _config = config;
        UICollectionViewFlowLayout *flowLayout = [self flowLayoutWithAlignment:alignment];
        [self setupCollectionViewWithFlowLayout:flowLayout];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame configuration:[[TTTagViewConfig alloc] init] alignment:TTTagViewAlignmentJustified];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithCoder:aDecoder];
}

- (void)dealloc {
    if ([self isHeightRestricted]) {
        [self removeKVO];
    }
    [self tt_removeAllDelegates];
    self.tagCollectionView.dataSource = nil;
}

#pragma mark -- Setup Components

- (UICollectionViewFlowLayout *)flowLayoutWithAlignment:(TTTagViewAlignment)alignment {
    UICollectionViewFlowLayout *flowLayout = nil;
    switch (alignment) {
        case TTTagViewAlignmentJustified:
            flowLayout = [[UICollectionViewFlowLayout alloc] init];
            break;
        case TTTagViewAlignmentLeft:
            flowLayout = [[TTLeftCollectionViewFlowLayout alloc] init];
            break;
        case TTTagViewAlignmentCenter:
            flowLayout = [[TTCenterCollectionViewFlowLayout alloc] init];
            break;
        default:
            flowLayout = [[UICollectionViewFlowLayout alloc] init];
            break;
    }
    
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = self.config.lineSpacing;
    flowLayout.minimumInteritemSpacing = self.config.interitemSpacing;
    flowLayout.sectionInset = self.config.padding;
    
    return flowLayout;
}

- (void)setupCollectionViewWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout {
    self.tagCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    self.tagCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tagCollectionView.scrollEnabled = YES;
    self.tagCollectionView.scrollsToTop = NO;
    self.tagCollectionView.showsHorizontalScrollIndicator = NO;
    self.tagCollectionView.showsVerticalScrollIndicator = YES;
    self.tagCollectionView.backgroundColor = [UIColor clearColor];
    self.tagCollectionView.delegate = self;
    self.tagCollectionView.dataSource = self;
    [self.tagCollectionView registerClass:[TTTagCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.tagCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [self.tagCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self addSubview:self.tagCollectionView];
};

#pragma mark -- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if([self intendMultiSections]) {
        return self.tagItems.count;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([self intendMultiSections]) {
        return ((NSArray<TTTagItem *> *)[self.tagItems objectAtIndex:section]).count;
    }
    return self.tagItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell registerCellButtonClass:self.clazz];
    if([self intendMultiSections]) {
        [cell updateCellWithTagItem:[((NSArray *)[self.tagItems objectAtIndex:indexPath.section]) objectAtIndex:indexPath.row]];
    }
    else {
        [cell updateCellWithTagItem:((TTTagItem *)[self.tagItems objectAtIndex:indexPath.row])];
    }
    
    return cell ? cell : [[UICollectionViewCell alloc] init];
}

// 设置Footer的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if([self intendMultiSections]) {
        if (section != self.tagItems.count - 1) {
            return CGSizeMake(0, self.config.lineSpacing);
        }
    }
    
    if (self.footerView && section == self.tagItems.count - 1) {
        return self.footerView.bounds.size;
    }
    return CGSizeZero;
}

// 设置Footer的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(section == 0 && self.headerView) {
        return self.headerView.bounds.size;
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if(![self intendMultiSections]) return nil;
    
    UICollectionReusableView *supplementaryView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        UICollectionReusableView *view = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        view.backgroundColor = [UIColor clearColor];
        if (indexPath.section == self.tagItems.count) {
            [view addSubview:self.footerView];
        }
        supplementaryView = view;
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        if (indexPath.section == 0) {
            UICollectionReusableView *view = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"HeadererView" forIndexPath:indexPath];
            view.backgroundColor = [UIColor clearColor];
            [view addSubview:self.headerView];
            supplementaryView = view;
        }
    }
    
    return supplementaryView;
}

#pragma mark -- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTTagItem * tagItem = nil;
    if([self intendMultiSections]) {
        tagItem = ((TTTagItem *)[((NSArray<TTTagItem *> *)[self.tagItems objectAtIndex:indexPath.section]) objectAtIndex:indexPath.row]);
    }
    else {
        tagItem = ((TTTagItem *)self.tagItems[indexPath.row]);
    }
    
    CGSize itemSize = [TTTagCollectionViewCell cellSizeWithTagItem:tagItem maxWidth:self.frame.size.width];
    return itemSize;
}

#pragma mark -- KVO

- (void)addKVO {
    [self.tagCollectionView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeKVO {
    [self.tagCollectionView removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.tagCollectionView && [keyPath isEqualToString:@"frame"]) {
        [self invalidateIntrinsicContentSize];
    }
}

#pragma mark -- Public Methods

- (void)setRowNumber:(NSUInteger)rowNumber {
    if (_rowNumber == rowNumber) {
        return;
    }
    _rowNumber = rowNumber;
    if ([self isHeightRestricted]) {
        [self addKVO];
        [self invalidateIntrinsicContentSize];
        self.tagCollectionView.scrollEnabled = NO;
    } else {
        self.tagCollectionView.scrollEnabled = YES;
    }
}

- (void)registerCellButtonClass:(Class)clazz {
    if (!_clazz) {
        _clazz = clazz;
    }
}

- (void)refreshWithTagItems:(NSMutableArray <ObjectType *> *)tagItems {
    self.tagItems = tagItems;
    [self.tagCollectionView reloadData];
    if ([self isHeightRestricted]) {
    [self invalidateIntrinsicContentSize];
    }
}

- (void)insertTagItems:(NSMutableArray <ObjectType *> *)items afterItem:(TTTagItem *)item needScroll:(BOOL)needScroll finishBlock:(void(^)(BOOL autoScroll))finishBlock; {
    if ([self intendMultiSections]) {
        __block NSUInteger insertedSectionIndex = 0;
        [self.tagItems enumerateObjectsUsingBlock:^(ObjectType * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop) {
            [(NSArray <TTTagItem *> *)obj1 enumerateObjectsUsingBlock:^(TTTagItem * _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop) {
                if (obj2 == item) {
                    insertedSectionIndex = idx1;
                    *stop = YES;
                }
            }];
        }];
        
        [items enumerateObjectsUsingBlock:^(ObjectType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.tagItems insertObject:obj atIndex:insertedSectionIndex + idx + 1];
        }];
        
        NSIndexSet *insertedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertedSectionIndex + 1, items.count)];
        
        __weak typeof(self) weakSelf = self;
        [self.tagCollectionView performBatchUpdates:^{
            [weakSelf.tagCollectionView insertSections:insertedSet];
        } completion:^(BOOL finished) {
            if(finished && needScroll) {
                NSUInteger lastInsertedIndex = ((NSArray *)((NSMutableArray <NSArray <TTTagItem *> *> *)weakSelf.tagItems)[insertedSet.lastIndex]).count - 1;
                UICollectionViewCell *cell = [weakSelf.tagCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:lastInsertedIndex inSection:insertedSet.lastIndex]];
                if (!CGRectContainsRect(self.tagCollectionView.bounds, cell.frame)) {
                    if (finishBlock) {
                        finishBlock(YES);
                    }
                    [weakSelf.tagCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:lastInsertedIndex inSection:insertedSet.lastIndex] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
                } else {
                    if (finishBlock) {
                        finishBlock(NO);
                    }
                }
            } else {
                if (finishBlock) {
                    finishBlock(NO);
                }
            }
        }];
    }
    else{
        NSUInteger insertedSectionIndex = [(NSArray <TTTagItem *> *)self.tagItems indexOfObject:item];
        NSMutableArray *indexPathes = [NSMutableArray array];
        [items enumerateObjectsUsingBlock:^(ObjectType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:insertedSectionIndex + idx + 1 inSection:0];
            [self.tagItems insertObject:obj atIndex:insertedSectionIndex + idx + 1];
            [indexPathes addObject:path];
        }];
        [self.tagCollectionView performBatchUpdates:^{
            [self.tagCollectionView insertItemsAtIndexPaths:indexPathes];
        } completion:^(BOOL finished) {
            if(finished && needScroll) {
                NSUInteger lastInsertedIndex = insertedSectionIndex + items.count - 1;
                UICollectionViewCell *cell = [self.tagCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:lastInsertedIndex inSection:0]];
                if (!CGRectContainsRect(self.tagCollectionView.bounds, cell.frame)) {
                    if (finishBlock) {
                        finishBlock(YES);
                    }
                    [self.tagCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:lastInsertedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
                } else {
                    if (finishBlock) {
                        finishBlock(NO);
                    }
                }
            } else {
                if (finishBlock) {
                    finishBlock(NO);
                }
            }
        }];
    }
}

#pragma mark -- Size

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = [super sizeThatFits:size];
    return [self ajustHeight:resultSize];
}

- (CGSize)intrinsicContentSize {
    CGSize resultSize = [super intrinsicContentSize];
    return [self ajustHeight:resultSize];
}

- (CGSize)ajustHeight:(CGSize)resultSize {
    resultSize.height = self.tagCollectionView.collectionViewLayout.collectionViewContentSize.height;
    TTTagItem *item = nil;
    
    if ([self intendMultiSections]) {
        return resultSize;
    }
    else {
        item =  ((NSArray <TTTagItem *> *)self.tagItems)[0];
    }
    
    if (self.rowNumber != 0) {
        CGFloat singleRowHeight = item.font.pointSize + item.padding.top + item.padding.bottom;
        CGFloat maxHeight = self.rowNumber * singleRowHeight + (self.rowNumber - 1) * self.config.lineSpacing;
        if (resultSize.height > maxHeight) {
            resultSize.height = maxHeight;
        }
    }
    return resultSize;
}
#pragma mark -- Helper

- (BOOL)isHeightRestricted {
    return self.rowNumber != 0;
}

//是否支持多个section update入参为二维数组
- (BOOL)intendMultiSections {
    return [(NSArray *)(self.tagItems).firstObject isKindOfClass:[NSArray class]];
}

@end
