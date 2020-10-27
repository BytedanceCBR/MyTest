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

- (void)refreshWithData:(id)data {
    [super refreshWithData:data];
}

@end
