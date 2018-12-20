//
//  FHHouseRentRoomFacilityCell.m
//  FHHouseRent
//
//  Created by leo on 2018/11/20.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHHouseRentRoomFacilityCell.h"
#import "FHSpringboardView.h"
#import <Masonry/Masonry.h>

@implementation FHHouseRentRoomFacilityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setupUI {
    self.facilityItemView = [[FHRowsView alloc] initWithRowCount:5];
    [self addSubview:_facilityItemView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
