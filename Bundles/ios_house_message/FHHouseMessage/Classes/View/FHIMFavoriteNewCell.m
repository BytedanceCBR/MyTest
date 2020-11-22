//
//  FHIMFavoriteNewCell.m
//  FHHouseMessage
//
//  Created by xubinbin on 2020/11/5.
//

#import "FHIMFavoriteNewCell.h"
#import "FHSingleImageInfoCellModel.h"

@implementation FHIMFavoriteNewCell

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
    FHNewHouseItemModel *model = cellModel.houseModel;
    FHImageModel *imageModel = model.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displayDescription;
    self.tagLabel.attributedText = cellModel.tagsAttrStr;
    self.priceLabel.text = model.displayPricePerSqm;
    [self updateTitlesLayout:self.cellModel.tagsAttrStr.length > 0];
}

@end
