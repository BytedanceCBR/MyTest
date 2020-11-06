//
//  FHHouseBaseSelectedCell.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/11/4.
//

#import "FHHouseBaseSelectedCell.h"
#import "FHCommonDefines.h"

@interface FHHouseBaseSelectedCell()

@property (nonatomic, strong) UIImageView* checkView;

@end

@implementation FHHouseBaseSelectedCell

- (void)initUI {
    [self.contentView addSubview:self.leftInfoView];
    [self.leftInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
        make.width.mas_equalTo(114);
        make.height.mas_equalTo(85);
    }];
    [self.leftInfoView addSubview:self.mainImageView];
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.leftInfoView addSubview:self.imageTagLabelBgView];
    [self.imageTagLabelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(16);
    }];
    [self.imageTagLabelBgView addSubview:self.imageTagLabel];
    [self.imageTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(1);
        make.top.mas_equalTo(3);
        make.width.mas_equalTo(46);
        make.height.mas_equalTo(10);
    }];
    [self.contentView addSubview:self.rightInfoView];
    [self.rightInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftInfoView.mas_right).offset(12);
        make.top.bottom.mas_equalTo(self.leftInfoView);
        make.width.mas_equalTo(SCREEN_WIDTH - 170);
    }];
    [self.rightInfoView addSubview:self.mainTitleLabel];
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-2);
        make.height.mas_equalTo(22);
        make.left.right.mas_equalTo(0);
    }];
    [self.rightInfoView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(17);
        make.left.right.mas_equalTo(0);
    }];
    [self.rightInfoView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(6);
        make.left.mas_equalTo(-3);
        make.right.mas_equalTo(0);
        //make.height.mas_equalTo(15);
    }];
    [self.rightInfoView addSubview:self.priceBgView];
    [self.priceBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tagLabel.mas_bottom).offset(5);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    [self.priceBgView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
    }];
    self.checkView = [[UIImageView alloc] init];
    self.checkView.image = [UIImage imageNamed:@"fh_im_share_unchecked2"];
    [self.contentView addSubview:self.checkView];
    [self.checkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mainImageView).mas_equalTo(-6);
        make.top.mas_equalTo(self.mainImageView).mas_offset(6);
        make.width.height.mas_equalTo(20);
    }];
}

- (void)setItemSelected:(BOOL)itemSelected {
    if (itemSelected) {
        _checkView.image = [UIImage imageNamed:@"fh_im_share_checked2"];
    } else {
        _checkView.image = [UIImage imageNamed:@"fh_im_share_unchecked2"];
    }
}

- (void)setDisable:(BOOL)isDisable {
    if (isDisable) {
        self.contentView.alpha = 0.3;
    } else {
        self.contentView.alpha = 1;
    }
}

- (void)updateTitlesLayout:(BOOL)showTags {
    CGSize titleSize = self.cellModel.titleSize;
    self.mainTitleLabel.numberOfLines = showTags?1:2;
    BOOL oneRow = showTags || titleSize.height < 30;
    [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(oneRow ? -2 : -5);
        make.height.mas_equalTo(oneRow ? 22 : 50);
    }];
    [self.subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(oneRow ? 4 : 1);
    }];
    CGFloat priceBgTopMargin = showTags ? 5 :(oneRow ? 6 : 2);
    [self.priceBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(priceBgTopMargin);
    }];
}

@end
