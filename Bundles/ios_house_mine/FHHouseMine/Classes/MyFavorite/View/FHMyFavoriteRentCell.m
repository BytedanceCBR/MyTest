//
//  FHMyFavoriteRentCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/10/26.
//

#import "FHMyFavoriteRentCell.h"
#import "FHHouseListBaseItemModel.h"

@implementation FHMyFavoriteRentCell

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
