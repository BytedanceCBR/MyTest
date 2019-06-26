//
//  FHUGCBaseCell.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import "FHUGCBaseCell.h"

@implementation FHUGCBaseCell

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

@end

// FHUGCBaseCollectionCell
@implementation FHUGCBaseCollectionCell

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

