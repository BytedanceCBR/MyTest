//
//  FHHouseListRentRelatedCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/27.
//

#import "FHHouseListRentRelatedCell.h"
#import "FHHouseListBaseItemModel.h"

@implementation FHHouseListRentRelatedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    [super refreshWithData:data];
    if([data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
        self.tagLabel.text = model.addrData;
        self.tagLabel.font = [UIFont themeFontRegular:12];
        [self.tagLabel setTextColor:[UIColor themeGray2]];
    }
}

@end