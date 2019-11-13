//
//  FHHouseListNoHouseCell.m
//  FHHouseList
//
//  Created by 春晖 on 2019/8/8.
//

#import "FHHouseListNoHouseCell.h"

@implementation FHHouseListNoHouseCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _errorView = [[FHErrorView alloc]initWithFrame:self.bounds];
        _errorView.autoresizingMask  = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_errorView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
        [self.contentView addSubview:_errorView];
        
    }
    return self;
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

@implementation FHHouseListNoHouseCellModel



@end
