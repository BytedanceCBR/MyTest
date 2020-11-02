//
//  FHPriceComparisonSecondCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/27.
//

#import "FHPriceComparisonSecondCell.h"

@implementation FHPriceComparisonSecondCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [super initUI];
    [self.contentView addSubview:self.topLeftTagImageView];
    [self.topLeftTagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.mainImageView);
        make.size.mas_equalTo(CGSizeMake(48, 18));
    }];
    self.tagLabel.textColor = [UIColor themeOrange1];
}

- (void)refreshWithData:(id)data {
    [super refreshWithData:data];
    [self configTopLeftTagWithTagImages:data];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutTopLeftTagImageView];
}


@end
