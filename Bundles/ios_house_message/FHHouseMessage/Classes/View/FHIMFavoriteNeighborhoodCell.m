//
//  FHIMFavoriteNeighborhoodCell.m
//  FHHouseMessage
//
//  Created by xubinbin on 2020/11/8.
//

#import "FHIMFavoriteNeighborhoodCell.h"

@implementation FHIMFavoriteNeighborhoodCell

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
    FHHouseNeighborDataItemsModel *model =cellModel.neighborModel;
    FHImageModel *imageModel = model.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    self.imageTagLabelBgView.hidden = YES;
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    self.tagLabel.text = model.displayStatsInfo;
    self.priceLabel.text = model.displayPrice;
    [self updateTitlesLayout:YES];
}

@end
