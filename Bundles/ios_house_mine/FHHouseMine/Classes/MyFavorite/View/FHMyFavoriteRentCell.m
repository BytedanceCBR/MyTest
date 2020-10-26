//
//  FHMyFavoriteRentCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/10/26.
//

#import "FHMyFavoriteRentCell.h"

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
}

@end
