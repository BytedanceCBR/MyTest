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
    return [self class];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self cellViewClass]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)refreshWithData:(id)data {
    // sub implements.........
}

// element_show 的时候 element_type，返回为空不上报
- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"";
}

@end

// FHDetailBaseCollectionCell
@implementation FHDetailBaseCollectionCell

+ (Class)cellViewClass
{
    return [self class];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self cellViewClass]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    // sub implements.........
}

@end
