//
//  FHMyFavoriteNewCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/10/28.
//

#import "FHMyFavoriteNewCell.h"

@implementation FHMyFavoriteNewCell

@synthesize pricePerSqmLabel = _pricePerSqmLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.contentView addSubview:self.houseMainImageBackView];
    [self.contentView addSubview:self.mainImageView];
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainImageView);
        make.left.top.equalTo(self.mainImageView);
        make.size.mas_equalTo(CGSizeMake(107, 81));
    }];
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self.contentView);
         make.left.equalTo(self.contentView).offset(15);
         make.size.mas_equalTo(CGSizeMake(106, 80));
    }];
    [self.contentView addSubview:self.vrLoadingView];
    [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImageView).offset(12);
        make.bottom.equalTo(self.mainImageView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.contentView addSubview:self.mainTitleLabel];
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImageView.mas_right).offset(12);
        make.top.equalTo(self.mainImageView);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(20);
    }];
    [self.contentView addSubview:self.pricePerSqmLabel];
    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.mainTitleLabel.mas_bottom);
    }];
    [self.contentView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.top.equalTo(self.pricePerSqmLabel.mas_bottom);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.contentView addSubview:self.tagInformation];
    [self.tagInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(5);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}

- (void)refreshWithData:(id)data {
    [super refreshWithData:data];
}

- (UILabel *)pricePerSqmLabel {
    if (!_pricePerSqmLabel) {
        _pricePerSqmLabel = [[UILabel alloc] init];
        _pricePerSqmLabel.font = [UIFont themeFontMedium:16];
        _pricePerSqmLabel.textColor = [UIColor themeOrange1];
    }
    return _pricePerSqmLabel;
}

@end
