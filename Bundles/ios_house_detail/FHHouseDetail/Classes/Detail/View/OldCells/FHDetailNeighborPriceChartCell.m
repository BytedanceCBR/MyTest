//
//  FHDetailNeighborPriceChartCell.m
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailNeighborPriceChartCell.h"

@interface FHDetailNeighborPriceChartCell ()

@end

@implementation FHDetailNeighborPriceChartCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    
}

- (void)refreshWithData:(id)data
{
//    if ([data isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
//        _allItems = [NSArray arrayWithArray:((FHDetailNewDataFloorpanListModel *)data).list];
//    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
