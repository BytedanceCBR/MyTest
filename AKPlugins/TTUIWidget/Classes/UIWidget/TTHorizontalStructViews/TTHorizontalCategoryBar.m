//
//  TTHorizontalTabbar.m
//  HorizontalTabbar
//
//  Created by 刘廷勇 on 15/8/25.
//  Copyright (c) 2015年 liuty. All rights reserved.
//

#import "TTHorizontalCategoryBar.h"
#import <Masonry/Masonry.h>
#import "TTBadgeNumberView.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"

#define kTextFont [UIFont systemFontOfSize:15]
static const NSTimeInterval animateDuration = 0.3f;
static const CGFloat transformScale = 1.2f;

#pragma mark - TTCategoryItem
@implementation TTCategoryItem

- (instancetype)init {
    if (self = [super init]) {
        self.badgeNum = 0;
        self.title = @"";
    }
    return self;
}

@end

#pragma mark - TTCategoryCell
/** 频道Cell */
@interface TTCategoryCell : UICollectionViewCell

/** 标题栏 */
@property (nonatomic, strong) SSThemedLabel * _Nonnull titleLabel;
/** 高亮标题栏 */
@property (nonatomic, strong) SSThemedLabel * _Nonnull maskLabel;
/** 右侧分割线 */
@property (nonatomic, strong) SSThemedView * _Nonnull rightLine;
/** 红点 */
@property (nonatomic, strong) TTBadgeNumberView * _Nonnull badgeView;
/** 频道项 */
@property (nonatomic, strong) TTCategoryItem *  _Nonnull cellItem;
/** 启用高亮显示 */
@property (nonatomic) BOOL enableHighlightedStatus;
/** 启用高亮动画 */
@property (nonatomic) BOOL animatedHighlighted;
/** 启用高亮变大动画 */
@property (nonatomic) BOOL animatedBiggerState;

@end

@implementation TTCategoryCell

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.animatedHighlighted = YES;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        [self.maskLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleLabel);
        }];
        
        [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).offset(3);
            make.top.equalTo(self.contentView.mas_top).priorityLow();
        }];
        
        [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(12);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(15);
            make.width.mas_equalTo([TTDeviceHelper ssOnePixel]);
        }];
    }
    return self;
}

#pragma mark set/get
- (SSThemedLabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor redColor];
        _titleLabel.font = kTextFont;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)maskLabel {
    if (_maskLabel == nil) {
        _maskLabel = [[SSThemedLabel alloc] init];
        _maskLabel.textAlignment = NSTextAlignmentCenter;
        _maskLabel.backgroundColor = [UIColor clearColor];
        _maskLabel.textColor = [UIColor redColor];
        _maskLabel.font = kTextFont;
        _maskLabel.alpha = 0;
        [self.contentView addSubview:_maskLabel];
    }
    return _maskLabel;
}

- (SSThemedView *)rightLine {
    if (_rightLine == nil) {
        _rightLine = [[SSThemedView alloc] init];
        _rightLine.backgroundColorThemeKey = kColorLine1;
        _rightLine.hidden = YES;
        [self.contentView addSubview:_rightLine];
    }
    return _rightLine;
}

- (TTBadgeNumberView *)badgeView {
    if (_badgeView == nil) {
        _badgeView = [[TTBadgeNumberView alloc] init];
        _badgeView.hidden = YES;
        [_badgeView setBadgeLabelFontSize:8];
        [self.contentView addSubview:_badgeView];
    }
    return _badgeView;
}

- (void)setCellItem:(TTCategoryItem *)cellItem {
    self.titleLabel.text = cellItem.title;
    self.maskLabel.text = cellItem.title;
    
    switch (cellItem.badgeStyle) {
        case TTCategoryItemBadgeStyleNone:
            self.badgeView.badgeNumber = TTBadgeNumberHidden;
            break;
        case TTCategoryItemBadgeStylePoint:
            self.badgeView.badgeNumber = TTBadgeNumberPoint;
            break;
        case TTCategoryItemBadgeStyleNumber:
            self.badgeView.badgeNumber = cellItem.badgeNum;
            break;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.enableHighlightedStatus) {
        [UIView animateWithDuration:(self.animatedHighlighted ? animateDuration : 0) animations:^{
            if (selected) {
                self.titleLabel.alpha = 0;
                self.maskLabel.alpha = 1;
                if (self.animatedBiggerState) {
                    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, transformScale, transformScale);
                }
            } else {
                self.titleLabel.alpha = 1;
                self.maskLabel.alpha = 0;
                if (self.animatedBiggerState) {
                    self.transform = CGAffineTransformIdentity;
                }
            }
        }];
    }
}

#pragma mark UI setting
- (void)setTabBarTextColor:(UIColor *)textColor maskColor:(UIColor *)maskColor lineColor:(UIColor *)lineColor {
    if (textColor) {
        self.titleLabel.textColor = textColor;
    }
    if (maskColor) {
        self.maskLabel.textColor = maskColor;
    }
    if (lineColor) {
        self.rightLine.backgroundColor = lineColor;
    }
}

- (void)setTabBarTextColorThemeKey:(NSString *)textColorKey maskColorThemeKey:(NSString *)maskColorKey lineColorThemeKey:(NSString *)lineColorKey {
    if (!isEmptyString(textColorKey)) {
        self.titleLabel.textColorThemeKey = textColorKey;
    }
    if (!isEmptyString(maskColorKey)) {
        self.maskLabel.textColorThemeKey = maskColorKey;
    }
    if (!isEmptyString(lineColorKey)) {
        self.rightLine.backgroundColorThemeKey = lineColorKey;
    }
}

- (void)setTabBarTextFont:(UIFont *)font {
    if (font) {
        self.titleLabel.font = font;
        self.maskLabel.font = font;
        //        [self.rightLine mas_updateConstraints:^(MASConstraintMaker *make) {
        //            make.height.mas_equalTo(font.pointSize);
        //        }];
    }
}

- (void)setTabBarTextFont:(UIFont *)textFont maskTextFont:(UIFont *)maskFont {
    if (textFont && maskFont) {
        self.titleLabel.font = textFont;
        self.maskLabel.font = maskFont;
    }
}

- (void)setBadgeViewOffset:(UIOffset)offset {
    [self.badgeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(offset.horizontal);
        make.top.equalTo(self.titleLabel.mas_top).offset(offset.vertical).priorityHigh();
    }];
    [self updateConstraintsIfNeeded];
}

- (void)setTitleLabelOffset:(UIOffset)offset {
    //    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.left.and.right.equalTo(self).offset(offset.horizontal);
    //    }];
}

@end

#pragma mark - TTHorizontalCategoryBar
@interface TTHorizontalCategoryBar () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) SSThemedView *bottomIndicator;
@property (nonatomic, strong) SSThemedView *bottomSeperator;

@property (nonatomic, assign) BOOL firstLoad;

@property (nonatomic) BOOL rightLineState;
@property (nonatomic) BOOL animateBiggerState;

@property (nonatomic, strong) UIColor * _Nullable textColor;
@property (nonatomic, strong) UIColor * _Nullable maskColor;
@property (nonatomic, strong) UIColor *_Nullable lineColor;
@property (nonatomic, copy) NSString * _Nullable textColorThemeKey;
@property (nonatomic, copy) NSString * _Nullable maskColorThemeKey;
@property (nonatomic, copy) NSString * _Nullable lineColorThemeKey;
@property (nonatomic, assign) BOOL setByThemeKey;

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *maskFont;

@end

@implementation TTHorizontalCategoryBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self setupConstraints];
        self.firstLoad = YES;
        self.animateBiggerState = YES;
        self.enableAnimatedHighlighted = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<TTHorizontalCategoryBarDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        [self initView];
        [self setupConstraints];
        self.firstLoad = YES;
        self.animateBiggerState = YES;
        self.enableAnimatedHighlighted = YES;
    }
    return self;
}

- (void)initView {
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.interitemSpacing = 20;
    self.itemExpandSpacing = 15;
    self.leftAlignmentPadding = 15;
    self.bottomIndicatorMinLength = 0;
    if ([self.delegate respondsToSelector:@selector(insetForSection)]) {
        self.flowLayout.sectionInset = [self.delegate insetForSection];
    }
    else {
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    }
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = nil;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[TTCategoryCell class] forCellWithReuseIdentifier:NSStringFromClass([TTCategoryCell class])];
    
    self.bottomIndicator = [[SSThemedView alloc] initWithFrame:CGRectZero];
    self.bottomIndicator.backgroundColor = [UIColor redColor];
    self.bottomIndicator.layer.cornerRadius = 1;
    [self.collectionView addSubview:self.bottomIndicator];
    
    //    UIView *view = [[UIView alloc] init];
    //    [self.collectionView addSubview:view];
    
    self.bottomSeperator = [[SSThemedView alloc] init];
    self.bottomSeperator.backgroundColorThemeKey = kColorLine1;
    [self addSubview:self.bottomSeperator];
    
    self.bottomIndicatorEnabled = YES;
    self.setByThemeKey = NO;
    self.enableSelectedHighlight = YES;
    self.bottomIndicatorFitTitle = NO;
}

- (void)setupConstraints {
    // 不能对UIColletionView添加约束，iOS7下会crash
    self.collectionView.frame = self.bounds;
    
    self.bottomIndicator.top = self.collectionView.height - 2;
    self.bottomIndicator.height = 2;
    self.bottomIndicator.layer.cornerRadius = 1;
    //    [self.bottomIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.equalTo(self);
    //        make.height.equalTo(@3);
    //    }];
    
    [self.bottomSeperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.equalTo(self);
        make.height.equalTo(@([TTDeviceHelper ssOnePixel]));
    }];
}

- (void)setBottomIndeicatorBottomSpacing:(CGFloat)bottomIndeicatorBottomSpacing {
    if (_bottomIndeicatorBottomSpacing != bottomIndeicatorBottomSpacing) {
        _bottomIndeicatorBottomSpacing = bottomIndeicatorBottomSpacing;
        self.bottomIndicator.top = self.collectionView.height - 2 - bottomIndeicatorBottomSpacing;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateBottomIndicatorConstraints];
    });
}

- (CGFloat)itemExpandSpacing {
    if (self.bottomIndicatorFitTitle) {
        return _itemExpandSpacing;
    }
    return 0;
}

- (void)setCategories:(NSArray *)categories
{
    _categories = categories;
    [self.collectionView reloadData];
    if (_categories != categories) {
        self.selectedIndex = 0;
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    if (_interitemSpacing != interitemSpacing) {
        _interitemSpacing = interitemSpacing;
        self.flowLayout.minimumLineSpacing = interitemSpacing;
        self.flowLayout.minimumInteritemSpacing = interitemSpacing;
        [self.flowLayout invalidateLayout];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= _categories.count) {
        return;
    }
    
    TTCategoryCell *cell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
    TTCategoryCell *lastSelectedCell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]];
    
    lastSelectedCell.selected = NO;
    cell.selected = YES;
    
    _selectedIndex = selectedIndex;
    
    UICollectionViewLayoutAttributes *lastAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]];
    CGFloat expandSpacing = self.itemExpandSpacing + self.itemInsetSpacing;
    self.bottomIndicator.width = lastAttributes.frame.size.width - expandSpacing * 2;
    self.bottomIndicator.left = lastAttributes.frame.origin.x + expandSpacing;
    //    [self.bottomIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(@(lastAttributes.frame.size.width - expandSpacing * 2));
    //        make.left.equalTo(@(lastAttributes.frame.origin.x + expandSpacing));
    //    }];
    //    [self updateBottomIndicatorConstraintsWithCell:cell];
    WeakSelf;
    [UIView animateWithDuration:animateDuration animations:^{
        StrongSelf;
        if (self.bottomIndicatorEnabled) {
            [self.bottomIndicator layoutIfNeeded];
            UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
            self.bottomIndicator.width = attributes.frame.size.width - expandSpacing * 2;
            self.bottomIndicator.left = attributes.frame.origin.x + expandSpacing;
            //            [self.bottomIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
            //                make.width.equalTo(@(attributes.frame.size.width - expandSpacing * 2));
            //                make.left.equalTo(@(attributes.frame.origin.x + expandSpacing));
            //            }];
        }
    }];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if (self.didSelectCategory) {
        self.didSelectCategory(selectedIndex);
    }
}

- (void)updateBottomIndicatorConstraints {
    CGFloat expandSpacing = self.itemExpandSpacing + self.itemInsetSpacing;
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
    self.bottomIndicator.width = attributes.frame.size.width - expandSpacing * 2;
    self.bottomIndicator.left = attributes.frame.origin.x + expandSpacing;
}

- (void)scrollToIndex:(NSUInteger)index
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self updateBottomIndicatorConstraints];
}

- (void)setBottomIndicatorColor:(UIColor *)bottomIndicatorColor
{
    if (_bottomIndicatorColor != bottomIndicatorColor) {
        _bottomIndicatorColor = bottomIndicatorColor;
        self.bottomIndicator.backgroundColor = bottomIndicatorColor;
    }
}

- (void)setBottomIndicatorColorThemeKey:(NSString *)bottomIndicatorColorThemeKey {
    if (_bottomIndicatorColorThemeKey != bottomIndicatorColorThemeKey) {
        _bottomIndicatorColorThemeKey = bottomIndicatorColorThemeKey;
        self.bottomIndicator.backgroundColorThemeKey = bottomIndicatorColorThemeKey;
    }
}

- (void)setBottomIndicatorEnabled:(BOOL)bottomIndicatorEnabled
{
    _bottomIndicatorEnabled = bottomIndicatorEnabled;
    self.bottomIndicator.hidden = !bottomIndicatorEnabled;
}

- (CGSize)sizeForItem:(TTCategoryItem *)item
{
    if ([self.delegate respondsToSelector:@selector(sizeForEachItem:)]) {
        return [self.delegate sizeForEachItem:item];
    }
    
    if (item.title.length > 0 ) {
        NSString *character = @"占";
        NSString *titleTmep = @"";
        if (item.title.length < self.bottomIndicatorMinLength) {
            for (int i = 0; i < self.bottomIndicatorMinLength; i++) {
                titleTmep = [titleTmep stringByAppendingString:character];
            }
        } else {
            titleTmep = item.title;
        }
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        CGFloat height = self.collectionView.frame.size.height - layout.sectionInset.top - layout.sectionInset.bottom;
        
        UIFont *font = kTextFont;
        if (self.textFont) {
            font = self.textFont;
        }
        
        CGSize size = [titleTmep boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : font} context:nil].size;
        TTBadgeNumberView *view = [[TTBadgeNumberView alloc] init];
        view.badgeNumber = 100;
        //        CGFloat bandgeWidth = view.frame.size.width + adapterSpace(12);
        
        return CGSizeMake(ceil(size.width + self.itemExpandSpacing * 2), floor(height - 10));
    } else {
        return CGSizeZero;
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    if (fromIndex < 0 || fromIndex >= [self.categories count] || toIndex < 0 || toIndex >= [self.categories count]) {
        return;
    }
    
    percentComplete = MAX(-1, MIN(percentComplete, 1));
    
    TTCategoryCell *fromCell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]];
    TTCategoryCell *toCell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
    
    if (self.bottomIndicatorEnabled) {
        UICollectionViewLayoutAttributes *fromAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]];
        UICollectionViewLayoutAttributes *toAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
        
        TTBadgeNumberView *view = [[TTBadgeNumberView alloc] init];
        view.badgeNumber = 100;
        
        CGFloat expandSpacing = self.itemExpandSpacing + self.itemInsetSpacing;
        CGFloat proposedWidth = CGRectGetWidth(fromAttributes.frame) - expandSpacing * 2;
        CGFloat targetWidth = CGRectGetWidth(toAttributes.frame) - expandSpacing * 2;
        
        CGPoint proposedOffset = fromAttributes.frame.origin;
        proposedOffset.x += expandSpacing;
        CGPoint targetOffset = toAttributes.frame.origin;
        targetOffset.x += expandSpacing;
        
        //        [self.bottomIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
        //            make.width.equalTo(@(proposedWidth + (targetWidth - proposedWidth) * fabs(percentComplete)));
        //            make.left.equalTo(@(proposedOffset.x + (targetOffset.x - proposedOffset.x) * fabs(percentComplete)));
        //        }];
        //
        //            NSLog(@"bottomIndicator Frame = (x:%lf, y:%lf, height:%lf, width:%lf), with Percent = %lf", self.bottomIndicator.frame.origin.x, self.bottomIndicator.frame.origin.y, self.bottomIndicator.frame.size.height, self.bottomIndicator.frame.size.width, percentComplete);
        //        if (percentComplete == 0) {
        //            NSLog(@"finished");
        //        }
        // 如果修改约束，会导致View的重布局
        CGRect frame = self.bottomIndicator.frame;
        frame.origin.x = proposedOffset.x + (targetOffset.x - proposedOffset.x) * fabs(percentComplete);
        frame.size.width = proposedWidth + (targetWidth - proposedWidth) * fabs(percentComplete);
        self.bottomIndicator.frame = frame;
        if (frame.origin.x >= self.frame.size.width) {
            [self.bottomIndicator setNeedsLayout];
        }
        
    }
    if (_enableAnimatedHighlighted){
        CGFloat transformScaleDelta = (transformScale - 1);
        CGFloat percent = fabs(percentComplete);
        
        CGFloat fromScale = 1 + transformScaleDelta * (1 - percent);
        CGFloat toScale = 1 + transformScaleDelta * percent;
        
        fromCell.titleLabel.alpha = percent;
        fromCell.maskLabel.alpha = 1 - percent;
        if (self.animateBiggerState) {
            
            fromCell.transform = CGAffineTransformMakeScale(fromScale, fromScale);
        }
        
        if (fromIndex != toIndex) {
            toCell.titleLabel.alpha = 1- percent;
            toCell.maskLabel.alpha = percent;
            if (self.animateBiggerState) {
                
                toCell.transform = CGAffineTransformMakeScale(toScale, toScale);
            }
        }
    }
}


- (void)showVerticalLine:(BOOL)show
{
    self.rightLineState = show;
}

- (void)setTabBarAnimateToBigger:(BOOL)animate {
    self.animateBiggerState = animate;
}

- (void)setTabBarTextColor:(UIColor *)textColor maskColor:(UIColor *)maskColor lineColor:(UIColor *)lineColor {
    self.textColor = textColor;
    self.maskColor = maskColor;
    self.lineColor = lineColor;
    self.setByThemeKey = NO;
}

- (void)setTabBarTextColorThemeKey:(NSString *)textColorKey maskColorThemeKey:(NSString *)maskColorKey lineColorThemeKey:(NSString *)lineColorKey {
    self.textColorThemeKey = textColorKey;
    self.maskColorThemeKey = maskColorKey;
    self.lineColorThemeKey = lineColorKey;
    self.setByThemeKey = YES;
}

- (void)setTabBarTextFont:(UIFont *)font {
    self.textFont = font;
    self.maskFont = font;
}

- (void)setTabBarTextFont:(UIFont *)textFont maskTextFont:(UIFont *)maskFont {
    self.textFont = textFont;
    self.maskFont = maskFont;
}

#pragma mark UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTCategoryCell class]) forIndexPath:indexPath];
    
    cell.cellItem = self.categories[indexPath.row];
    cell.enableHighlightedStatus = self.enableSelectedHighlight;
    cell.rightLine.hidden = ((indexPath.row == self.categories.count - 1) ? YES : !self.rightLineState);
    [cell setTabBarTextFont:self.textFont maskTextFont:self.maskFont];
    
    [cell setTitleLabelOffset:UIOffsetMake(10, 0)];
    if (self.setByThemeKey) {
        [cell setTabBarTextColorThemeKey:self.textColorThemeKey maskColorThemeKey:self.maskColorThemeKey lineColorThemeKey:self.lineColorThemeKey];
    } else {
        [cell setTabBarTextColor:self.textColor maskColor:self.maskColor lineColor:self.lineColor];
    }
    if ([self.delegate respondsToSelector:@selector(offsetOfBadgeViewToTitleView)]) {
        [cell setBadgeViewOffset:[self.delegate offsetOfBadgeViewToTitleView]];
    }
    cell.selected = NO;
    
    //for initial index
    if (self.selectedIndex == indexPath.item && self.firstLoad) {
        self.firstLoad = NO;
        cell.selected = YES;
        if (self.didSelectCategory) {
            self.didSelectCategory(indexPath.item);
        }
        
        [self updateBottomIndicatorConstraints];
        //        [self.bottomIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
        //            make.width.equalTo(@(CGRectGetWidth(cell.frame) - self.interitemSpacing * 2));
        //            make.left.equalTo(@(CGRectGetMinX(cell.frame) + self.interitemSpacing));
        //        }];
    }
    
    if (self.selectedIndex == indexPath.item) {
        cell.selected = YES;
    }
    return cell!=nil ? cell : [[UICollectionViewCell alloc] init];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -
#pragma mark UICollectionViewDelegate

- (void)didSelectItemAtIndex:(NSUInteger)index {
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didTapCategoryItem) {
        self.didTapCategoryItem(indexPath.item, self.selectedIndex);
    }
    
    if (self.selectedIndex != indexPath.item) {
        self.selectedIndex = indexPath.item;
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        //        [self updateBottomIndicatorConstraintsWithCell:[self.collectionView cellForItemAtIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((TTCategoryCell *)cell).animatedHighlighted = NO;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((TTCategoryCell *)cell).animatedHighlighted = _enableAnimatedHighlighted;
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTCategoryItem *item = self.categories[indexPath.item];
    return [self sizeForItem:item];
}

//For centering adjustment
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat totalWidth = 0;
    for (TTCategoryItem *item in self.categories) {
        totalWidth += [self sizeForItem:item].width;
    }
    CGFloat canvasWidth = collectionView.frame.size.width;
    CGFloat interitemSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumInteritemSpacing;
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];
    
    CGFloat inset = (canvasWidth - interitemSpacing * (numberOfItems - 1) - totalWidth) / 2;
    
    UIEdgeInsets sectionInset = ((UICollectionViewFlowLayout *)collectionViewLayout).sectionInset;
    if (self.leftAlignmentEnabled) {
        return UIEdgeInsetsMake(0, self.leftAlignmentPadding - self.itemExpandSpacing, 0, self.leftAlignmentPadding - self.itemExpandSpacing);
    }
    if (inset < sectionInset.left) {
        return sectionInset;
    } else {
        return UIEdgeInsetsMake(0, inset, 0, inset);
    }
}

- (void)setBottomSeperatorHidden:(BOOL)hidden {
    self.bottomSeperator.hidden = hidden;
}

- (void)setBadgeNumber:(NSUInteger)badgeNumber AtIndex:(NSUInteger)index {
    TTCategoryCell *cell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (cell) {
        cell.badgeView.badgeNumber = badgeNumber;
    }
}

- (void)reloadItemAtIndex:(NSUInteger)index {
    NSIndexPath *reloadPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:@[reloadPath]];
}

- (void)updateAppearanceColor
{
    [self.collectionView reloadData];
}

@end
