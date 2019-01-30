//
//  FHDetailBaseCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHDetailBaseCell.h"

@implementation FHDetailBaseCell

+ (Class)cellViewClass
{
    return [FHDetailBaseCell class];
}

+ (NSString *)cellIdentifier {
    return @"FHDetailBaseCell";
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width {
    return 0;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    // sub implements.........
}

@end
