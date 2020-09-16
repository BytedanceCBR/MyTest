//
//  FHFloorPanDetailMediaHeaderView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/7.
//

#import "FHFloorPanDetailMediaHeaderView.h"
#import "FHDetailHeaderTitleView.h"
#import "FHVideoAndImageItemCorrectingView.h"
#import "FHCommonDefines.h"
#import <ByteDanceKit/NSString+BTDAdditions.h>

@interface FHFloorPanDetailMediaHeaderView ()
@property (nonatomic, strong) FHDetailHeaderTitleView *titleView;            //头图下面的标题栏
@property (nonatomic, strong) UIView *bottomGradientView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) FHVideoAndImageItemCorrectingView *itemView;   //图片户型的标签
@property (nonatomic, strong) FHDetailNewMediaHeaderScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *itemIndexArray;
@property (nonatomic, strong) NSMutableArray *itemArray;

@property (nonatomic, copy) NSArray<FHMultiMediaItemModel *> *medias;
@end


@implementation FHFloorPanDetailMediaHeaderView

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
    self.scrollView = [[FHDetailNewMediaHeaderScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [FHFloorPanDetailMediaHeaderView cellHeight])];
    self.scrollView.closeInfinite = NO;
    [self addSubview:self.scrollView];
    [self addSubview:self.bottomGradientView];
    self.titleView = [[FHDetailHeaderTitleView alloc]init];
    [self addSubview:self.titleView];

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
        make.height.mas_equalTo([FHFloorPanDetailMediaHeaderView cellHeight]);
    }];
    [self.bottomGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView);
        make.bottom.equalTo(self.scrollView);
        make.height.mas_equalTo(self.bottomGradientView.frame.size.height);
    }];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.scrollView.mas_bottom).offset(-40);
        make.height.equalTo(0);
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

- (void)updateTitleModel:(FHDetailHouseTitleModel *)model {
    self.titleView.model = model;
    [self reckoncollectionHeightWithData:model];
}

- (UIView *)bottomGradientView {
    if (!_bottomGradientView) {
        CGFloat aspect = 375.0 / 25;
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
    [self.scrollView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    NSInteger curPage = [self.scrollView getCurPagae];

    [self setInfoLabelText:[NSString stringWithFormat:@"%ld/%lu", (long)curPage, (unsigned long)self.medias.count]];

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
    if (index >= 0 && index < self.medias.count) {
        FHMultiMediaItemModel *itemModel = self.medias[index];
        NSString *groupType = itemModel.groupType;
        [self.itemView selectedItem:groupType];
        NSInteger curPage = [self.scrollView getCurPagae];
        [self setInfoLabelText:[NSString stringWithFormat:@"%ld/%lu", (long)curPage, (unsigned long)self.medias.count]];
    }
}

- (void)reckoncollectionHeightWithData:(FHDetailHouseTitleModel *)titleModel {
    CGFloat titleHeight = 40;
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont themeFontMedium:24] };
    CGRect rect = [titleModel.titleStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 66, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributes
                                                    context:nil];          //算出标题的高度
    if (titleModel.advantage.length > 0 && titleModel.businessTag.length > 0) { //如果头图下面有横幅那么高度增加40
        titleHeight += 40;
    }

    CGFloat rectHeight = rect.size.height;
    if (rectHeight > [UIFont themeFontMedium:24].lineHeight * 1) {
        rectHeight = [UIFont themeFontMedium:24].lineHeight * 1;
    }

    titleHeight += 20 + rectHeight - 21;//20是标题具体顶部的距离，21是重叠的41减去透明阴影的20 (21 = 41 - 20)
    
    if (titleModel.isFloorPan) {    //户型详情页特有的总价Label
        if (titleModel.tags && titleModel.tags.count > 1) {
           titleHeight += 20 + 20 + 24;
        } else {
            titleHeight += 20 + 12;
        }
    }
    [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(titleHeight);
    }];
}


@end
