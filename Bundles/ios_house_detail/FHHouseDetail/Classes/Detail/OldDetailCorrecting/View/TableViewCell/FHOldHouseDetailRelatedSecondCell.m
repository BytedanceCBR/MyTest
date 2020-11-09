//
//  FHOldHouseDetailRelatedSecondCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/11/9.
//

#import "FHOldHouseDetailRelatedSecondCell.h"
#import "FHSingleImageInfoCellModel.h"

@implementation FHOldHouseDetailRelatedSecondCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [super initUI];
    self.contentView.backgroundColor = [UIColor themeGray7];
    self.houseCellBackView.hidden = NO;
    [self.houseCellBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
    [self.mainImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.left.mas_equalTo(26);
    }];
    self.houseMainImageBackView.backgroundColor = [UIColor whiteColor];
    [self.houseMainImageBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainImageView).offset(3);
        make.left.mas_equalTo(self.mainImageView).offset(3);
        make.right.mas_equalTo(self.mainImageView).offset(-3);
        make.bottom.mas_equalTo(self.mainImageView).offset(-3);
    }];
    [self.contentView addSubview:self.topLeftTagImageView];
    [self.topLeftTagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.mainImageView);
        make.size.mas_equalTo(CGSizeMake(48, 18));
    }];
    [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40);
    }];
    [self.pricePerSqmLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-23);
    }];
    [self.contentView addSubview:self.tagTitleLabel];
    [self.tagTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.mainTitleLabel.mas_right).offset(2);
        make.height.mas_equalTo(16);
        make.top.mas_equalTo(self.mainTitleLabel).offset(1.5);
    }];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSingleImageInfoCellModel class]]) {
        return;
    }
    FHSingleImageInfoCellModel *cellModel  = (FHSingleImageInfoCellModel *)data;
    FHSearchHouseDataItemsModel *model  = cellModel.secondModel;
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text =model.displaySubtitle;
    NSAttributedString * attributeStrings =  [FHSingleImageInfoCellModel tagsStringSmallImageWithTagList:model.tags];
    self.tagLabel.attributedText =  attributeStrings;
    self.priceLabel.text = model.displayPrice;
    FHImageModel *imageModel = model.houseImage.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    self.priceLabel.font = [UIFont themeFontSemibold:[UIDevice btd_isScreenWidthLarge320] ? 16 : 15];
    self.pricePerSqmLabel.textColor = [UIColor themeGray1];
    self.pricePerSqmLabel.font = [UIFont themeFontRegular:12];
    if (model.originPrice) {
        self.pricePerSqmLabel.attributedText = [self originPriceAttr:model.originPrice];
    }else{
        self.pricePerSqmLabel.attributedText = [[NSAttributedString alloc]initWithString:(model.displayPricePerSqm.length>0?model.displayPricePerSqm:@"") attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
    }
    //企业担保标签
    [self configTopLeftTagWithTagImages:model.tagImage];
    CGSize titleSize = [self.mainTitleLabel sizeThatFits:CGSizeMake(100, 22)];
    if (model.houseTitleTag.text.length > 0) {
        self.tagTitleLabel.hidden = NO;
        self.tagTitleLabel.text = model.houseTitleTag.text;
        self.tagTitleLabel.backgroundColor = [UIColor colorWithHexString:model.houseTitleTag.backgroundColor];
        self.tagTitleLabel.textColor = [UIColor colorWithHexString:model.houseTitleTag.textColor];
        [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(titleSize.width + 3);
        }];
        //修改两字标签
        CGFloat width = model.houseTitleTag.text.length > 1 ? 28 : 16;
        [self.tagTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
     } else {
          self.tagTitleLabel.hidden = YES;
    }
}

@end
