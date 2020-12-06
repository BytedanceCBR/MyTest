//
//  FHHouseBaseNewCell.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/23.
//

#import "FHHouseBaseNewCell.h"

@implementation FHHouseBaseNewCell

@synthesize subTitleLabel = _subTitleLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    NSAssert(![self isMemberOfClass:[FHHouseBaseNewCell class]], @"业务不可直接用基类，请继承基类");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (UIImage *)placeholderImage {
    return [UIImage imageNamed: @"house_cell_placeholder"];
}

- (void)updateMainImageWithUrl:(NSString *)url {
    NSURL *imgUrl = [NSURL URLWithString:url];
    if (imgUrl) {
        [self.mainImageView bd_setImageWithURL:imgUrl placeholder:[[self class] placeholderImage]];
    } else {
        self.mainImageView.image = [[self class] placeholderImage];
    }
}

- (void)initUI {
    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(HOR_MARGIN);
        layout.paddingRight = YGPointValue(HOR_MARGIN);
        layout.width = YGPointValue(SCREEN_WIDTH);
        layout.alignItems = YGAlignFlexStart;
    }];
    
    self.houseCellBackView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.houseCellBackView];
    self.houseCellBackView.hidden = YES;
    [self.houseCellBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(15);
        layout.right = YGPointValue(15);
        layout.width = YGPointValue(SCREEN_WIDTH - 30);
        layout.height = YGPointValue(130);
        layout.flexGrow = 1;
    }];
    [self.houseCellBackView setBackgroundColor:[UIColor whiteColor]];
    [self.houseCellBackView.yoga markDirty];
    
    self.leftInfoView = [[UIView alloc] init];
    [self.leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPointValue(106 + 6);
        layout.height = YGPointValue(140.5);
    }];
    
    [self.contentView addSubview:self.leftInfoView];
    [self.leftInfoView addSubview:self.houseMainImageBackView];
    [self.leftInfoView addSubview:self.mainImageView];
    [self.leftInfoView addSubview:self.imageTagLabelBgView];
    [self.imageTagLabelBgView addSubview:self.imageTagLabel];
    
    [self.houseMainImageBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(11.5 + 3);
        layout.left = YGPointValue(8.5);
        layout.width = YGPointValue(106 - 6);
        layout.height = YGPointValue(80 - 6);
    }];
    
    [self.mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(11.5);
        layout.left = YGPointValue(5.5);
        layout.width = YGPointValue(106);
        layout.height = YGPointValue(80);
    }];
    
    [self.mainImageView addSubview:self.vrLoadingView];
    self.vrLoadingView.hidden = YES;
    [self.vrLoadingView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(6);
        layout.marginTop = YGPointValue(58);
        layout.width = YGPointValue(16);
        layout.height = YGPointValue(16);
    }];
    
    [self.leftInfoView addSubview:self.videoImageView];
    self.videoImageView.hidden = YES;
    [self.videoImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(6 + 5.5);
        layout.marginTop = YGPointValue(58 + 11.5);
        layout.width = YGPointValue(16);
        layout.height = YGPointValue(16);
    }];
    
    [self.leftInfoView addSubview:self.houseVideoImageView];
    self.houseVideoImageView.image = [UIImage imageNamed:@"icon_list_house_video_small"];
    
    [self.houseVideoImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(27.0f);
        layout.left = YGPointValue(25.0f);
        layout.width = YGPointValue(20.0f);
        layout.height = YGPointValue(20.0f);
    }];
    
    [self.imageTagLabelBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(0);
        layout.top = YGPointValue(10);
        layout.width = YGPointValue(48);
        layout.height = YGPointValue(17);
    }];
    
    [self.imageTagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(0);
        layout.top = YGPointValue(0);
        layout.width = YGPointValue(48);
        layout.height = YGPointValue(17);
    }];
    
    self.rightInfoView = [[UIView alloc] init];
    [self.contentView addSubview:self.rightInfoView];
    
    [self.rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(12);
        layout.flexDirection = YGFlexDirectionColumn;
        layout.flexGrow = 1;
        layout.marginTop = YGPointValue(11.5 - 1.5);
        layout.justifyContent = YGJustifyFlexStart;
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.height = YGPointValue(107);
    }];
    
    UIView *titleView = [[UIView alloc] init];
    [self.rightInfoView addSubview:titleView];
    self.priceBgView = [[UIView alloc] init];
    [self.priceBgView setBackgroundColor:[UIColor whiteColor]];
    [self.rightInfoView addSubview:self.priceBgView];
    [self.rightInfoView addSubview:self.subTitleLabel];
    [self.rightInfoView addSubview:self.statInfoLabel];
    [self.rightInfoView addSubview:self.tagLabel];
    
    [self.rightInfoView addSubview:self.bottomRecommendView];
    
    [titleView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(0);
        layout.paddingRight = YGPointValue(0);
        layout.alignItems = YGAlignFlexStart;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    [titleView addSubview:self.mainTitleLabel];
    [titleView addSubview:self.tagTitleLabel];
    [titleView setBackgroundColor:[UIColor whiteColor]];
    
    self.mainTitleLabel.font = [UIFont themeFontSemibold:16];
    [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    
    [self.priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.width = YGPointValue(172);
        layout.height = YGPointValue(22);
        layout.marginTop = YGPointValue(2);
        layout.justifyContent = YGJustifyFlexStart;
        layout.alignItems = YGAlignFlexStart;
    }];
    
    [self.priceBgView addSubview:self.priceLabel];
    self.priceBgView.backgroundColor = [UIColor whiteColor];
    
    
    [self.priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue(172);
    }];
    
    self.tagTitleLabel.hidden = YES;
    [self.tagTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(3);
        layout.marginLeft = YGPointValue(4);
        layout.height = YGPointValue(16);
        layout.width = YGPointValue(16);
    }];
    
    [self.subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(3);
        layout.height = YGPointValue(15);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    [_statInfoLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    self.tagLabel.font = [UIFont themeFontRegular:10];
    [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(5);
        layout.marginLeft = YGPointValue(-2);
        layout.height = YGPointValue(14);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    
    [self.bottomRecommendView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.maxWidth = YGPointValue([UIScreen mainScreen].bounds.size.width - 106 - 50);
        layout.height = YGPointValue(24);
        layout.marginTop = YGPointValue(5);
        layout.justifyContent = YGJustifyFlexStart;
        layout.alignItems = YGAlignFlexStart;
    }];
    
    self.bottomRecommendViewBack = [[UIView alloc] init];
    self.bottomRecommendViewBack.layer.borderWidth = 0.5;
    self.bottomRecommendViewBack.layer.cornerRadius = 2;
    [self.bottomRecommendView addSubview:self.bottomRecommendViewBack];
    [self.bottomRecommendViewBack configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.maxWidth = YGPointValue([UIScreen mainScreen].bounds.size.width - 106 - 50);
        layout.height = YGPointValue(18);
        layout.marginTop = YGPointValue(3);
        layout.justifyContent = YGJustifyFlexStart;
        layout.alignItems = YGAlignFlexStart;
    }];
    
    [self.bottomRecommendViewBack addSubview:self.bottomIconImageView];
    [self.bottomIconImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(4);
        layout.marginLeft = YGPointValue(2);
        layout.height = YGPointValue(12);
        layout.width = YGPointValue(12);
    }];
    
    self.bottomRecommendLabel.font = [UIFont themeFontRegular:11];
    self.bottomRecommendLabel.textColor = [UIColor themeGray1];
    [self.bottomRecommendLabel setBackgroundColor:[UIColor whiteColor]];
    [self.bottomRecommendViewBack addSubview:self.bottomRecommendLabel];
    [self.bottomRecommendLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(3);
        layout.marginLeft = YGPointValue(5);
        layout.maxWidth = YGPointValue([UIScreen mainScreen].bounds.size.width - 106 - 80);
        layout.marginRight = YGPointValue(3);
        layout.height = YGPointValue(13);
    }];
    
    [self.rightInfoView addSubview:self.recReasonView];
    [self.recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isIncludedInLayout = NO;
        layout.marginTop = YGPointValue(6);
        layout.height = YGPointValue(16);
    }];
    self.recReasonView.hidden = YES;
}

- (UIView *)bottomRecommendView {
    if (!_bottomRecommendView) {
        _bottomRecommendView = [[UIView alloc] init];
    }
    return _bottomRecommendView;
}

- (UIImageView *)bottomIconImageView {
    if (!_bottomIconImageView) {
        _bottomIconImageView= [[UIImageView alloc]init];
        _bottomIconImageView.backgroundColor = [UIColor clearColor];
    }
    return _bottomIconImageView;
}

- (UILabel *)bottomRecommendLabel {
    if (!_bottomRecommendLabel) {
        _bottomRecommendLabel = [[UILabel alloc]init];
        _bottomRecommendLabel.font = [UIFont themeFontMedium:12];
        _bottomRecommendLabel.textColor = [UIColor themeGray1];
    }
    return _bottomRecommendLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont themeFontRegular:12];
        _subTitleLabel.textColor = [UIColor themeGray2];
    }
    return _subTitleLabel;
}

- (void)setSubTitleLabel:(UILabel *)subTitleLabel {
    _subTitleLabel = subTitleLabel;
}

- (CGFloat)contentMaxWidth {
    return  SCREEN_WIDTH - HOR_MARGIN * 2  - 106 - 12 - 7; //根据UI图 直接计算出来
}

@end
