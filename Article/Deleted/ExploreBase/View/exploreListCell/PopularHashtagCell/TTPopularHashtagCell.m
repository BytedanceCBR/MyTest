//
//  TTPopularHashtagCell.m
//  Article
//
//  Created by lipeilun on 2018/1/17.
//

#import "TTPopularHashtagCell.h"
#import "TTPopularHashtagCollectionView.h"
#import "PopularHashtagData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreArticleCellViewConsts.h"
#import <TTAlphaThemedButton.h>
#import <TTRoute/TTRoute.h>
#import <UIImageView+WebCache.h>

@implementation TTPopularHashtagCell

+ (Class)cellViewClass {
    return [TTPopularHashtagCellView class];
}

- (void)willDisplay {
    [self.cellView willAppear];
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
}

- (void)willAppear {
    [self.cellView willAppear];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context {
    [self.cellView didDisappear];
}

@end

#pragma mark - cell view

@interface TTPopularHashtagCellView() <TTPopularHashtagTrackDelegate>
@property (nonatomic, strong) SSThemedImageView *topIcon;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTAlphaThemedButton *moreButton;
@property (nonatomic, strong) TTPopularHashtagCollectionView *collectionView;
@property (nonatomic, strong) SSThemedView *bottomLineView;
@property (nonatomic, strong) PopularHashtagData *popularData;
@end

@implementation TTPopularHashtagCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topIcon];
        [self addSubview:self.titleLabel];
        [self addSubview:self.moreButton];
        [self addSubview:self.bottomLineView];
    }
    return self;
}

+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)cellType {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if (!orderedData.popularHashtagData) {
        return 0;
    }
    
    CGFloat height = 0;
    PopularHashtagData *popularHashtagData = orderedData.popularHashtagData;
    if (!isEmptyString([popularHashtagData title]) || (!isEmptyString([popularHashtagData dayIconURL]) && !isEmptyString([popularHashtagData nightIconURL]))) {
        height += [TTDeviceUIUtils tt_newPadding:40];
    } else {
        height += [TTDeviceUIUtils tt_newPadding:15];
    }
    
    NSInteger line = (popularHashtagData.forumModelArray.count + 1) / 2;
    height += line * [TTDeviceUIUtils tt_newPadding:54];
    return height;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    NSString *iconURL = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? self.popularData.dayIconURL : self.popularData.nightIconURL;
    if (!isEmptyString(iconURL)) {
        [self.topIcon sd_setImageWithURL:[NSURL URLWithString:iconURL]];
    }
}

- (void)willAppear {
    [self.collectionView willDisplay];
}

- (void)didDisappear {
    [self.collectionView didEndDisplaying];
}

- (id)cellData {
    return self.orderedData;
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    
    if ([self.orderedData.originalData isKindOfClass:[PopularHashtagData class]]) {
        self.popularData = (PopularHashtagData *)self.orderedData.originalData;
    } else {
        self.popularData = nil;
        return;
    }
    
    NSString *iconURL = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? self.popularData.dayIconURL : self.popularData.nightIconURL;
    if (!isEmptyString(iconURL)) {
        [self.topIcon sd_setImageWithURL:[NSURL URLWithString:iconURL]];
    }
    
    self.titleLabel.text = self.popularData.title;
    [self.moreButton setTitle:[self.popularData showMoreText] forState:UIControlStateNormal];
    
    if (isEmptyString(iconURL) && isEmptyString(self.popularData.title)) {
        self.topIcon.hidden = YES;
        self.titleLabel.hidden = YES;
        self.moreButton.hidden = YES;
    } else {
        self.topIcon.hidden = NO;
        self.titleLabel.hidden = NO;
        if (isEmptyString([self.popularData showMoreSchema])) {
            self.moreButton.hidden = YES;
        } else {
            self.moreButton.hidden = NO;
        }
    }
    
    self.collectionView.cellDatas = self.popularData.forumModelArray;
    self.collectionView.categoryName = self.orderedData.categoryID;
}

- (void)refreshUI {
    self.topIcon.frame = CGRectMake(kCellLeftPadding, [TTDeviceUIUtils tt_newPadding:15], [TTDeviceUIUtils tt_newPadding:16], [TTDeviceUIUtils tt_newPadding:16]);
    
    CGSize size = [[self.popularData showMoreText] boundingRectWithSize:CGSizeMake(100, [TTDeviceUIUtils tt_newPadding:16])
                                                                options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13]]}
                                                                context:nil].size;
    self.moreButton.frame = CGRectMake(self.width - kCellRightPadding - size.width - 10, 0, size.width + 10, [TTDeviceUIUtils tt_newPadding:16]);
    self.moreButton.centerY = self.topIcon.centerY;
    self.moreButton.imageEdgeInsets = UIEdgeInsetsMake(3, self.moreButton.width - 10, 3, 0);
    self.moreButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);

    self.titleLabel.size = CGSizeMake(self.moreButton.left - self.topIcon.right - 2 * kCellLeftPadding - 12, [TTDeviceUIUtils tt_newPadding:16]);
    self.titleLabel.left = self.topIcon.right + 6;
    self.titleLabel.centerY = self.topIcon.centerY;
    
    NSInteger line = (self.popularData.forumModelArray.count + 1) / 2;
    if (!self.topIcon.hidden) {
        self.collectionView.frame = CGRectMake(kCellLeftPadding, [TTDeviceUIUtils tt_newPadding:40], self.width - kCellLeftPadding -kCellRightPadding, line * [TTDeviceUIUtils tt_newPadding:54]);
    } else {
        self.collectionView.frame = CGRectMake(kCellLeftPadding, [TTDeviceUIUtils tt_newPadding:15], self.width - kCellLeftPadding -kCellRightPadding, line * [TTDeviceUIUtils tt_newPadding:54]);
    }

    
    self.bottomLineView.frame = CGRectMake(kCellLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
    if ([(ExploreOrderedData *)self.orderedData nextCellHasTopPadding] || self.hideBottomLine) {
        self.bottomLineView.hidden = YES;
    } else {
        self.bottomLineView.hidden = NO;
    }
}

#pragma mark - action

- (void)showMoreButtonClicked:(id)sender {
    [TTTrackerWrapper eventV3:@"enter_hot_topic_list" params:@{@"category_name":self.orderedData.categoryID?:@""}];
    if (!isEmptyString([self.popularData showMoreSchema]) && [[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:[self.popularData showMoreSchema]]]) {
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[self.popularData showMoreSchema]]];
    }
}

#pragma mark - GET

- (SSThemedImageView *)topIcon {
    if (!_topIcon) {
        _topIcon = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _topIcon.contentMode = UIViewContentModeScaleAspectFill;
        _topIcon.clipsToBounds = YES;
        _topIcon.backgroundColor = [UIColor clearColor];
        _topIcon.enableNightCover = NO;
    }
    return _topIcon;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _titleLabel.text = @"正在直播";
    }
    return _titleLabel;
}

- (TTAlphaThemedButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[TTAlphaThemedButton alloc] init];
        _moreButton.titleColorThemeKey = kColorText1;
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13]];
        _moreButton.imageName = @"popular_hashtag_arrow";
        _moreButton.hidden = YES;
        [_moreButton addTarget:self action:@selector(showMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (TTPopularHashtagCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [TTPopularHashtagCollectionView collectionView];
        _collectionView.trackDelegate = self;
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLineView;
}

- (NSString *)popularHashtagImpressionCategoryName {
    return self.orderedData.categoryID;
}

- (NSString *)popularHashtagImpressionCellId {
    return self.orderedData.uniqueID;
}
@end

