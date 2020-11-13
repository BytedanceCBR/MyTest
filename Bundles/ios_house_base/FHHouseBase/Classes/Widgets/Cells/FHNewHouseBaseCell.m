//
//  FHNewHouseBaseCell.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/22.
//

#import "FHNewHouseBaseCell.h"
#import "FHSearchHouseModel.h"
#import "FHCommonDefines.h"

@implementation FHNewHouseBaseCell

+ (UIImage *)placeholderImage {
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"house_cell_placeholder"];
    });
    return placeholderImage;
}

+ (CGFloat)heightForData:(id)data
{
    if ([data isKindOfClass:[JSONModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)data;
        if (itemModel.advantageDescription.text) {
            return 130;
        }
    }
    return 118;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
}

@end
