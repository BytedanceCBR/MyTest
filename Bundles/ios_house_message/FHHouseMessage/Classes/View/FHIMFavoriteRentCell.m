//
//  FHIMFavoriteRentCell.m
//  FHHouseMessage
//
//  Created by xubinbin on 2020/11/8.
//

#import "FHIMFavoriteRentCell.h"

@implementation FHIMFavoriteRentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSingleImageInfoCellModel class]]) {
        return;
    }
    FHSingleImageInfoCellModel *cellModel = (FHSingleImageInfoCellModel *)data;
    self.cellModel = cellModel;
    FHHouseRentDataItemsModel *model = cellModel.rentModel;
    self.mainTitleLabel.text = model.title;
    self.subTitleLabel.text = model.subtitle;
    self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
    self.priceLabel.text = model.pricing;
    FHImageModel *imageModel = [model.houseImage firstObject];
    [self updateMainImageWithUrl:imageModel.url];
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTagLabel.text = model.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    } else {
        self.imageTagLabelBgView.hidden = YES;
    }
    [self updateTitlesLayout:self.cellModel.tagsAttrStr.length > 0];
}

@end
