//
//  FHIMFavoriteSecondCell.m
//  FHHouseMessage
//
//  Created by xubinbin on 2020/11/8.
//

#import "FHIMFavoriteSecondCell.h"

@implementation FHIMFavoriteSecondCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [super initUI];
    [self.leftInfoView addSubview:self.houseVideoImageView];
    [self.houseVideoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(42);
        make.width.height.mas_equalTo(30);
    }];
    [self.priceBgView addSubview:self.originPriceLabel];
    [self.priceBgView addSubview:self.pricePerSqmLabel];
    [self.originPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.priceLabel.mas_right).offset(6);
        make.top.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.priceLabel.mas_right).offset(10);
        make.top.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    [self.rightInfoView addSubview:self.recReasonView];
    [self.recReasonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceBgView.mas_bottom).offset(4);
        make.height.mas_equalTo(16);
    }];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSingleImageInfoCellModel class]]) {
        return;
    }
    FHSingleImageInfoCellModel *cellModel = (FHSingleImageInfoCellModel *)data;
    self.cellModel = cellModel;
    FHSearchHouseDataItemsModel *model = cellModel.secondModel;
    self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
    FHImageModel *imageModel = model.houseImage.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTagLabel.text = model.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    } else {
        self.imageTagLabelBgView.hidden = YES;
    }
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    NSAttributedString * attributeString = self.cellModel.tagsAttrStr;
    self.tagLabel.attributedText =  attributeString;
    self.priceLabel.text = model.displayPrice;
    self.pricePerSqmLabel.text = model.displayPricePerSqm;
    BOOL originPriceEnable = self.cellModel.originPriceAttrStr.string.length > 0;
    self.originPriceLabel.hidden = !originPriceEnable;
    if (model.recommendReasons.count > 0) {
        self.recReasonView.hidden = NO;
        [self.recReasonView setReasons:model.recommendReasons];
    } else {
        self.recReasonView.hidden = YES;
    }
    [self updateTitlesLayout:self.cellModel.tagsAttrStr.length > 0];
}

@end
