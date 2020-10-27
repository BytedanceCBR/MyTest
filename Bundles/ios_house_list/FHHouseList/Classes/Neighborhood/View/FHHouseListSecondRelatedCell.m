//
//  FHHouseListRelatedCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/10/27.
//

#import "FHHouseListSecondRelatedCell.h"

@implementation FHHouseListSecondRelatedCell

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
