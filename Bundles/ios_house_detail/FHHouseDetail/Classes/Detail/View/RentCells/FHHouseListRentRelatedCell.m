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
        self.tagInformation.text = model.addrData;
        self.tagInformation.font = [UIFont themeFontRegular:12];
        [self.tagInformation setTextColor:[UIColor themeGray2]];
    }
}

@end
