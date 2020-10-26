//
//  FHHouseBaseUsuallyCell.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/26.
//

#import "FHHouseBaseUsuallyCell.h"
#import "FHHouseListBaseItemModel.h"

@implementation FHHouseBaseUsuallyCell

@synthesize mainImageView = _mainImageView, mainTitleLabel = _mainTitleLabel, pricePerSqmLabel = _pricePerSqmLabel, priceLabel = _priceLabel, tagLabel = _tagLabel;

- (void)initUI {
    [self.contentView addSubview:self.houseMainImageBackView];
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainImageView);
        make.left.top.equalTo(self.mainImageView);
        make.bottom.equalTo(self.mainImageView).offset(-1);
        make.right.equalTo(self.mainImageView).offset(-1);
    }];
    [self.contentView addSubview:self.mainImageView];
    [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(85, 64));
    }];
    [self.contentView addSubview:self.houseVideoImageView];
    self.houseVideoImageView.hidden = YES;
    [self.houseVideoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImageView).offset(12);
        make.bottom.equalTo(self.mainImageView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
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
        make.top.equalTo(self.mainImageView).offset(-2);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.contentView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(2);
    }];
    [self.contentView addSubview:self.pricePerSqmLabel];
    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(self.subTitleLabel.mas_right).offset(10);
        make.top.equalTo(self.subTitleLabel);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.pricePerSqmLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.pricePerSqmLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainTitleLabel);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(7);
    }];
    [self.contentView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pricePerSqmLabel.mas_right);
        make.top.equalTo(self.pricePerSqmLabel.mas_bottom).offset(4);
    }];
}

- (void)refreshWithData:(id)data {
    self.currentData = data;
    if([data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
        FHImageModel *imageModel = model.houseImage.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
        self.mainTitleLabel.text = model.title;
        self.subTitleLabel.text = model.displaySubtitle;
        if (model.originPrice) {
            self.pricePerSqmLabel.attributedText = [self originPriceAttr:model.originPrice];
        }else{
            self.pricePerSqmLabel.attributedText = [[NSMutableAttributedString alloc]initWithString:model.displayPricePerSqm attributes:@{}];
        }
        self.priceLabel.text = model.displayPrice;
        self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
        if (model.reasonTags.count>0) {
            self.tagLabel.attributedText = model.recommendReasonStr;
        }else {
            self.tagLabel.attributedText = model.tagString;
        }
        [self updateContentWithModel:model];
        if (model.vrInfo.hasVr) {
            self.houseVideoImageView.hidden = YES;
            self.vrLoadingView.hidden = NO;
            [self.vrLoadingView play];
        }else {
            self.vrLoadingView.hidden = YES;
            [self.vrLoadingView stop];
        }
    };
}

- (void)updateContentWithModel:(FHHouseListBaseItemModel *)model {
    switch (model.houseType) {
        case FHHouseTypeRentHouse:
            self.tagLabel.text = model.addrData;
            self.tagLabel.font = [UIFont themeFontRegular:12];
            [self.tagLabel setTextColor:[UIColor themeGray2]];
            break;
        case FHHouseTypeNeighborhood:
            self.tagLabel.text = model.salesInfo;
            self.tagLabel.font = [UIFont themeFontRegular:12];
            [self.tagLabel setTextColor:[UIColor themeGray2]];
        case FHHouseTypeNewHouse:

        default:
            break;
    }
    
}

- (NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, originPrice.length)];
    return attri;
}

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] init];
        _mainImageView.layer.cornerRadius = 4;
        _mainImageView.layer.masksToBounds = YES;
    }
    return _mainImageView;
}

- (UILabel *)mainTitleLabel {
    if (!_mainTitleLabel) {
        _mainTitleLabel = [[UILabel alloc] init];
        _mainTitleLabel.font = [UIFont themeFontSemibold:18];
        _mainTitleLabel.textColor = [UIColor themeGray1];
    }
    return _mainTitleLabel;
}

- (UILabel *)pricePerSqmLabel {
    if (!_pricePerSqmLabel) {
        _pricePerSqmLabel = [[UILabel alloc] init];
        _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
        _pricePerSqmLabel.textColor = [UIColor themeGray1];
    }
    return _pricePerSqmLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont themeFontSemibold:16];
        _priceLabel.textColor = [UIColor themeOrange1];
    }
    return _priceLabel;
}

- (YYLabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[YYLabel alloc] init];
        _tagLabel.font = [UIFont themeFontRegular:12];
        _tagLabel.textColor = [UIColor themeOrange1];
    }
    return _tagLabel;
}

@end
