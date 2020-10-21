//
//  FHNeighborhoodDetailMediaHeaderView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailMediaHeaderView.h"
#import "FHDetailHeaderTitleView.h"
#import "FHVideoAndImageItemCorrectingView.h"
#import "FHCommonDefines.h"
#import <ByteDanceKit/NSString+BTDAdditions.h>

@interface FHNeighborhoodDetailMediaHeaderView ()

@property (nonatomic, strong) UIView *bottomGradientView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) FHVideoAndImageItemCorrectingView *itemView;   //图片户型的标签
@property (nonatomic, strong) FHDetailNewMediaHeaderScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *itemIndexArray;
@property (nonatomic, strong) NSMutableArray *itemArray;

@property (nonatomic, copy) NSArray<FHMultiMediaItemModel *> *medias;

@property (nonatomic, assign) BOOL segmentViewChangedFlag;

@end

@implementation FHNeighborhoodDetailMediaHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        [self initConstaints];
    }
    return self;
}

#pragma mark - UI

+ (CGFloat)cellHeight {
    CGFloat photoCellHeight = 281;
    photoCellHeight = round([UIScreen mainScreen].bounds.size.width / 375.0f * photoCellHeight + 0.5);
    return photoCellHeight;
}

- (void)createUI {
    self.scrollView = [[FHDetailNewMediaHeaderScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [FHNeighborhoodDetailMediaHeaderView cellHeight])];
    self.scrollView.closeInfinite = NO;
    [self addSubview:self.scrollView];
    [self addSubview:self.bottomGradientView];
    self.itemView = [[FHVideoAndImageItemCorrectingView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
    self.itemView.hidden = YES;

    [self addSubview:self.itemView];

    // 底部右侧序号信息标签
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.font = [UIFont themeFontRegular:12];
    self.infoLabel.textColor = [UIColor whiteColor];
    self.infoLabel.layer.cornerRadius = 11;
    self.infoLabel.layer.masksToBounds = YES;
    [self addSubview:self.infoLabel];

    __weak typeof(self) wSelf = self;
    self.itemView.selectedBlock = ^(NSInteger index, NSString *_Nonnull name, NSString *_Nonnull value) {
        [wSelf selectItem:index];
    };
    self.scrollView.didSelectiItemAtIndex = ^(NSInteger index) {
        if (wSelf.didSelectiItemAtIndex) {
            wSelf.didSelectiItemAtIndex(index);
        }
    };

    self.scrollView.scrollToIndex = ^(NSInteger index) {
        [wSelf updateItemAndInfoLabel:index];
    };

    self.scrollView.willDisplayCellForItemAtIndex = ^(NSInteger index) {
        if (wSelf.willDisplayCellForItemAtIndex) {
            wSelf.willDisplayCellForItemAtIndex(index);
        }
    };
    
    self.scrollView.goToPictureListFrom = ^(NSString * _Nonnull name) {
        if (wSelf.goToPictureListFrom) {
            wSelf.goToPictureListFrom(name);
        }
    };
}

- (void)initConstaints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo([FHNeighborhoodDetailMediaHeaderView cellHeight]);
    }];
    [self.bottomGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView);
        make.bottom.equalTo(self.scrollView);
        make.height.mas_equalTo(self.bottomGradientView.frame.size.height);
    }];

    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-35);//
        make.width.mas_equalTo(self.scrollView.mas_width);
        make.height.mas_equalTo(20);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(self.scrollView.mas_right).offset(-15);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-35);
    }];

    [self layoutIfNeeded];
}


- (void)updateMultiMediaModel:(FHMultiMediaModel *)model {
    self.infoLabel.hidden = NO;
    self.medias = model.medias.copy;
    if (self.medias.count > 0) {
        [self setInfoLabelText:[NSString stringWithFormat:@"%d/%lu", 1, (unsigned long)self.medias.count]];
    } else {
        self.infoLabel.hidden = YES;
    }

    self.itemArray = [NSMutableArray array];
    self.itemIndexArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.medias.count; i++) {
        FHMultiMediaItemModel *itemModel = self.medias[i];
        if (![_itemArray containsObject:itemModel.groupType]) {
            [_itemArray addObject:itemModel.groupType];
            [self.itemIndexArray addObject:@(i)];
        }
    }
    [self.scrollView updateModel:model];
    if (_itemArray.count > 1) {
        self.itemView.hidden = NO;
        [self setNeedsLayout];
        [self layoutIfNeeded];
        self.itemView.titleArray = _itemArray;
        [self.itemView selectedItem:_itemArray[0]];
    } else {
        self.itemView.hidden = YES;
    }
    
}

- (UIView *)bottomGradientView {
    if (!_bottomGradientView) {
        CGFloat aspect = 375.0 / 22;
        CGFloat width = SCREEN_WIDTH;

        CGFloat height = round(width / aspect + 0.5);
        CGRect frame = CGRectMake(0, 0, width, height);
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = frame;
        gradientLayer.colors = @[
            (__bridge id)[UIColor colorWithWhite:1 alpha:0].CGColor,
            (__bridge id)[UIColor themeGray7].CGColor
        ];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 0.9);

        _bottomGradientView = [[UIView alloc] initWithFrame:frame];
        [_bottomGradientView.layer addSublayer:gradientLayer];
    }
    return _bottomGradientView;
}


#pragma mark - operator

- (void)setInfoLabelText:(NSString *)text {
    self.infoLabel.text = text;
    CGFloat width = [text btd_widthWithFont:[UIFont themeFontRegular:12] height:20];
    width += 14;
    if (width < 44) {
        width = 44;
    }
    if (width == self.infoLabel.frame.size.width) {
        return;
    }
    [self.infoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (void)selectItem:(NSInteger)index {
    if (index < 0 || index >= self.itemIndexArray.count) {
        return;
    }
    NSInteger item = [self.itemIndexArray[index] integerValue] + 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    
    self.segmentViewChangedFlag = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.segmentViewChangedFlag = NO;
            NSInteger curPage = [self.scrollView getCurPagae];
            [self setInfoLabelText:[NSString stringWithFormat:@"%ld/%lu", (long)curPage, (unsigned long)self.medias.count]];
        });
    }];
    
    
    if (self.didClickItemViewName) {
        self.didClickItemViewName(self.itemArray[index]);
    }
}


- (void)scrollToItemAtIndex:(NSInteger)index {
    NSInteger item = index + 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.scrollView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self updateItemAndInfoLabel:index];
}

- (void)updateItemAndInfoLabel:(NSInteger)index {
    if (self.segmentViewChangedFlag) {
        return;
    }
    if (index >= 0 && index < self.medias.count) {
        FHMultiMediaItemModel *itemModel = self.medias[index];
        NSString *groupType = itemModel.groupType;
        [self.itemView selectedItem:groupType];
        NSInteger curPage = [self.scrollView getCurPagae];
        [self setInfoLabelText:[NSString stringWithFormat:@"%ld/%lu", (long)curPage, (unsigned long)self.medias.count]];
    }
}
@end
