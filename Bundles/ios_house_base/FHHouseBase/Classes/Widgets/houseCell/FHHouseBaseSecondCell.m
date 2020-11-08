//
//  FHHouseBaseSecondCell.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/11/6.
//

#import "FHHouseBaseSecondCell.h"
#import "FHHouseListBaseItemModel.h"
#import "UIImage+FIconFont.h"

@implementation FHHouseBaseSecondCell

+ (CGFloat)heightForData:(id)data {
    BOOL isLastCell = NO;
    if([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
        isLastCell = model.isLastCell;
        CGFloat reasonHeight = [model showRecommendReason] ? 22 : 0;
        return (isLastCell ? 108 : 88) + reasonHeight;
    }
    return 88;
}

- (void)initUI {
    CGFloat leftMargin = 9;
    CGFloat rightMargin = 12;
    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(leftMargin);
        layout.paddingRight = YGPointValue(leftMargin);
        layout.paddingTop = YGPointValue(0);
        layout.width = YGPointValue(SCREEN_WIDTH);
        layout.height = YGPointValue(88);
        layout.flexGrow = 1;
    }];
    
    self.houseCellBackView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.houseCellBackView];
    [self.houseCellBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(15);
        layout.right = YGPointValue(15);
        layout.top = YGPointValue(0);
        layout.width = YGPointValue(SCREEN_WIDTH - 30);
        layout.height = YGPointValue(88);
        layout.flexGrow = 1;
    }];
    
    [self.leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.width = YGPointValue(97);
        layout.left = YGPointValue(leftMargin);
        layout.top = YGPointValue(0);
        layout.height = YGPointValue(88);
    }];
    
    [self.contentView addSubview:self.leftInfoView];
    [self.leftInfoView addSubview:self.houseMainImageBackView];
    [self.leftInfoView addSubview:self.mainImageView];
    
    [self.leftInfoView addSubview:self.imageTagLabelBgView];
    [self.imageTagLabelBgView addSubview:self.imageTagLabel];
    
    [self.mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(12);
        layout.left = YGPointValue(6);
        layout.width = YGPointValue(85);
        layout.height = YGPointValue(64);
    }];
    
    //企业担保图标，加到mainImageView上
    [self.mainImageView addSubview:self.topLeftTagImageView];
    
    [self.topLeftTagImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(0);
        layout.top = YGPointValue(0);
        layout.width = YGPointValue(48);
        layout.height = YGPointValue(18);
    }];
    [self.houseMainImageBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(12 + 3);
        layout.left = YGPointValue(6 + 3);
        layout.width = YGPointValue(85 - 6);
        layout.height = YGPointValue(64 - 6);
    }];
    [self.leftInfoView addSubview:self.houseVideoImageView];
    [self.houseVideoImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(64 - 10);
        layout.left = YGPointValue(12);
        layout.width = YGPointValue(16);
        layout.height = YGPointValue(16.0f);
    }];
    [self.contentView addSubview:self.rightInfoView];
    [self.rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(102 + 12);
        layout.flexDirection = YGFlexDirectionColumn;
        layout.flexGrow = 1;
        layout.top = YGPointValue(0);
        layout.justifyContent = YGJustifyFlexStart;
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
        layout.height = YGPointValue(88);
    }];
    UIView *titleView = [[UIView alloc] init];
    [self.rightInfoView addSubview:titleView];
    [self.rightInfoView addSubview:self.subTitleLabel];
    //[self.rightInfoView addSubview:self.statInfoLabel];
    [self.rightInfoView addSubview:self.tagLabel];
    
    [titleView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(0);
        layout.paddingRight = YGPointValue(0);
        layout.alignItems = YGAlignFlexStart;
        layout.marginTop = YGPointValue(12);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    [titleView addSubview:self.mainTitleLabel];
    [titleView addSubview:self.tagTitleLabel];
    
    if ([UIDevice btd_isScreenWidthLarge320]) {
        self.mainTitleLabel.font = [UIFont themeFontSemibold:18];
    }else {
        self.mainTitleLabel.font = [UIFont themeFontSemibold:16];
    }
    
    [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(20);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    
    self.tagTitleLabel.hidden = YES;
    [self.tagTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(1.5);
        layout.marginLeft = YGPointValue(4);
        layout.height = YGPointValue(16);
        layout.width = YGPointValue(16);
    }];
    
    [self.subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(1);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth] - 36);
        layout.flexGrow = 0;
    }];
    
//    [_statInfoLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.marginTop = YGPointValue(0);
//        layout.height = YGPointValue(19);
//        layout.maxWidth = YGPointValue([self contentSmallImageTagMaxWidth]);
//        layout.flexGrow = 0;
//    }];
    CGFloat maxWidth = [self contentSmallImageMaxWidth] - 70;
    [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(8);
        layout.marginLeft = YGPointValue(0);
        layout.height = YGPointValue(16);
        layout.maxWidth = YGPointValue(maxWidth);
    }];
    
    [self.contentView addSubview:self.priceBgView];
    
    [self.priceBgView addSubview:self.closeBtn];
    [self.priceBgView addSubview:self.pricePerSqmLabel];
    [self.priceBgView addSubview:self.priceLabel];
    
    [self.priceBgView setBackgroundColor:[UIColor clearColor]];
    [self.priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexGrow = 1;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.width = YGPointValue(72 + rightMargin);
        layout.height = YGPointValue(88);
        layout.right = YGPointValue(0);
        layout.top = YGPointValue(0);
        layout.right = YGPointValue(3);
        layout.justifyContent = YGJustifyFlexStart;
        layout.position = YGPositionTypeAbsolute;
        layout.alignItems = YGAlignFlexEnd;
    }];
    [_closeBtn configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.right = YGPointValue(rightMargin);
        layout.marginTop = YGPointValue(14);
        layout.width = YGPointValue(16);
        layout.height = YGPointValue(16);
    }];
    
    self.pricePerSqmLabel.textAlignment = 2;
    [self.pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(6);
        layout.right = YGPointValue(rightMargin);
        layout.maxWidth = YGPointValue(72);
    }];
    
    [self.priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.right = YGPointValue(rightMargin);
        layout.marginTop = YGPointValue(6);
        layout.maxWidth = YGPointValue(72);
    }];
    
    
    [self.rightInfoView addSubview:self.recReasonView];
    [self.recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isIncludedInLayout = NO;
        layout.marginTop = YGPointValue(6);
        layout.height = YGPointValue(16);
    }];
    self.recReasonView.hidden = YES;
    
    
    
//    CGFloat leftMargin = 9;
//    CGFloat rightMargin = 12;
//    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.flexDirection = YGFlexDirectionRow;
//        layout.paddingLeft = YGPointValue(leftMargin);
//        layout.paddingRight = YGPointValue(leftMargin);
//        layout.paddingTop = YGPointValue(0);
//        layout.width = YGPointValue(SCREEN_WIDTH);
//        layout.height = YGPointValue(88);
//        layout.flexGrow = 1;
//    }];
//    [self.contentView addSubview:self.houseCellBackView];
//    [self.houseCellBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.position = YGPositionTypeAbsolute;
//        layout.left = YGPointValue(15);
//        layout.right = YGPointValue(15);
//        layout.top = YGPointValue(0);
//        layout.width = YGPointValue(SCREEN_WIDTH - 30);
//        layout.height = YGPointValue(88);
//        layout.flexGrow = 1;
//    }];
//
//    [self.contentView addSubview:self.leftInfoView];
//    [self.leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.position = YGPositionTypeAbsolute;
//        layout.width = YGPointValue(97);
//        layout.left = YGPointValue(leftMargin);
//        layout.top = YGPointValue(0);
//        layout.height = YGPointValue(88);
//    }];
//    [self.leftInfoView addSubview:self.houseMainImageBackView];
//    [self.leftInfoView addSubview:self.mainImageView];
//    [self.leftInfoView addSubview:self.imageTagLabelBgView];
//    [self.imageTagLabelBgView addSubview:self.imageTagLabel];
//
//    [self.mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.position = YGPositionTypeAbsolute;
//        layout.top = YGPointValue(12);
//        layout.left = YGPointValue(6);
//        layout.width = YGPointValue(85);
//        layout.height = YGPointValue(64);
//    }];
//
//    //企业担保图标，加到mainImageView上
//    [self.mainImageView addSubview:self.topLeftTagImageView];
//
//    [self.topLeftTagImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.position = YGPositionTypeAbsolute;
//        layout.left = YGPointValue(0);
//        layout.top = YGPointValue(0);
//        layout.width = YGPointValue(48);
//        layout.height = YGPointValue(18);
//    }];
//
//    [self.houseMainImageBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.position = YGPositionTypeAbsolute;
//        layout.top = YGPointValue(12 + 3);
//        layout.left = YGPointValue(6 + 3);
//        layout.width = YGPointValue(85 - 6);
//        layout.height = YGPointValue(64 - 6);
//    }];
//
//    [self.leftInfoView addSubview:self.houseVideoImageView];
//    [self.houseVideoImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.position = YGPositionTypeAbsolute;
//        layout.top = YGPointValue(64 - 10);
//        layout.left = YGPointValue(12);
//        layout.width = YGPointValue(16);
//        layout.height = YGPointValue(16.0f);
//    }];
//    [self.contentView addSubview:self.rightInfoView];
//    [self.rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.position = YGPositionTypeAbsolute;
//        layout.left = YGPointValue(102 + 12);
//        layout.flexDirection = YGFlexDirectionColumn;
//        layout.flexGrow = 1;
//        layout.top = YGPointValue(0);
//        layout.justifyContent = YGJustifyFlexStart;
//        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
//        layout.height = YGPointValue(88);
//    }];
//
//    UIView *titleView = [[UIView alloc] init];
//    [self.rightInfoView addSubview:titleView];
//    [self.rightInfoView addSubview:self.subTitleLabel];
//    [self.rightInfoView addSubview:self.tagLabel];
//
//    [titleView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.flexDirection = YGFlexDirectionRow;
//        layout.paddingLeft = YGPointValue(0);
//        layout.paddingRight = YGPointValue(0);
//        layout.alignItems = YGAlignFlexStart;
//        layout.marginTop = YGPointValue(12);
//        layout.height = YGPointValue(22);
//        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
//    }];
//    [titleView addSubview:self.mainTitleLabel];
//    [titleView addSubview:self.tagTitleLabel];
//    if ([UIDevice btd_isScreenWidthLarge320]) {
//        self.mainTitleLabel.font = [UIFont themeFontSemibold:18];
//    }else {
//        self.mainTitleLabel.font = [UIFont themeFontSemibold:16];
//    }
//
//    [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.marginTop = YGPointValue(0);
//        layout.height = YGPointValue(20);
//        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
//    }];
//
//    self.tagTitleLabel.hidden = YES;
//    [self.tagTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.marginTop = YGPointValue(1.5);
//        layout.marginLeft = YGPointValue(4);
//        layout.height = YGPointValue(16);
//        layout.width = YGPointValue(16);
//    }];
//
//    [self.subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.marginTop = YGPointValue(1);
//        layout.height = YGPointValue(19);
//        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth] - 36);
//        layout.flexGrow = 0;
//    }];
//    CGFloat maxWidth = [self contentSmallImageMaxWidth] - 70;
//    [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.marginTop = YGPointValue(8);
//        layout.marginLeft = YGPointValue(0);
//        layout.height = YGPointValue(16);
//        layout.maxWidth = YGPointValue(maxWidth);
//    }];
//
//    [self.contentView addSubview:self.priceBgView];
//    [self.priceBgView addSubview:self.pricePerSqmLabel];
//    [self.priceBgView addSubview:self.priceLabel];
//
//    [self.priceBgView setBackgroundColor:[UIColor clearColor]];
//    [self.priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.flexGrow = 1;
//        layout.flexDirection = YGFlexDirectionColumn;
//        layout.width = YGPointValue(72 + 20);
//        layout.height = YGPointValue(88);
//        layout.right = YGPointValue(0);
//        layout.top = YGPointValue(0);
//        layout.right = YGPointValue(3);
//        layout.justifyContent = YGJustifyFlexStart;
//        layout.position = YGPositionTypeAbsolute;
//        layout.alignItems = YGAlignFlexEnd;
//    }];
//    self.pricePerSqmLabel.textAlignment = 2;
//    [self.pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.marginTop = YGPointValue(6);
//        layout.right = YGPointValue(rightMargin);
//        layout.maxWidth = YGPointValue(72);
//    }];
//
//    [self.priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.right = YGPointValue(rightMargin);
//        layout.marginTop = YGPointValue(57);
//        layout.maxWidth = YGPointValue(172);
//        layout.position = YGPositionTypeAbsolute;
//    }];
//
//    [self.rightInfoView addSubview:self.recReasonView];
//    [self.recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isIncludedInLayout = NO;
//        layout.marginTop = YGPointValue(6);
//        layout.height = YGPointValue(16);
//    }];
//    self.recReasonView.hidden = YES;
}

- (CGFloat)contentSmallImageMaxWidth {
    return  SCREEN_WIDTH + 40 - 72 - 90; //根据UI图 直接计算出来
}

#pragma mark 字符串处理
- (NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    
    if (originPrice.length < 1) {
        return nil;
    }
    NSAttributedString *attri = [[NSAttributedString alloc]initWithString:originPrice attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle),NSStrikethroughColorAttributeName:[UIColor themeGray1]}];
    return attri;
}

- (CGFloat)contentSmallImageTagMaxWidth {
    return  SCREEN_WIDTH - 65 - 72 - 90; //根据UI图 直接计算出来
}

- (void)updateSamllTitlesLayout:(BOOL)showTags {
    if (self.tagLabel.yoga.isIncludedInLayout != showTags) {
        [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = showTags;
        }];
    }
    [self.mainTitleLabel.yoga markDirty];
    [self.rightInfoView.yoga markDirty];
    [self.tagLabel.yoga markDirty];
    [self.priceLabel.yoga markDirty];
    [self.pricePerSqmLabel.yoga markDirty];
    [self.priceBgView.yoga markDirty];
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        _closeBtn.hidden = YES;
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e673", [UIColor themeGray5]);
        [_closeBtn setImage:img forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dislike) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -20, -10, -20);
    }
    return _closeBtn;
}

@end
