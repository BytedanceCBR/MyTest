//
//  FHListBaseCell.m
//  FHHouseList
//
//  Created by 张静 on 2019/11/11.
//

#import "FHListBaseCell.h"

@implementation FHListBaseCell

- (void)refreshWithData:(id)data
{
    
}

+ (CGFloat)heightForData:(id)data
{
    return 0;
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
