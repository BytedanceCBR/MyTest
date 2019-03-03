//
//  FHDetailRentHouseCoreInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailRentHouseCoreInfoCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "UILabel+House.h"

@implementation FHDetailRentHouseCoreInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRentHouseCoreInfoModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailRentHouseCoreInfoModel *model = (FHDetailRentHouseCoreInfoModel *)data;
    NSInteger count = model.coreInfo.count;
    if (count > 0) {
        CGFloat fixedSpace = 4.0;
        CGFloat width = ((UIScreen.mainScreen.bounds.size.width - 40) - (count - 1) * fixedSpace) / count;
        __block CGFloat leftOffset = 20.0;
        [model.coreInfo enumerateObjectsUsingBlock:^(FHDetailOldDataCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailRentHouseCoreInfoItemView *itemView = [[FHDetailRentHouseCoreInfoItemView alloc] init];
            [self.contentView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self.contentView);
                make.width.mas_equalTo(width);
                make.left.mas_equalTo(self.contentView).offset(leftOffset);
            }];
            leftOffset += (width + fixedSpace);
            // 设置数据
            itemView.keyLabel.text = obj.value;
            itemView.valueLabel.text = obj.attr;
        }];
    }
    [self layoutIfNeeded];
}

@end

// FHDetailRentHouseCoreInfoItemView
@interface FHDetailRentHouseCoreInfoItemView ()

@end

@implementation FHDetailRentHouseCoreInfoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithHexString:@"#f7f8f9"];
    self.layer.cornerRadius = 4.0;
    
    _keyLabel = [UILabel createLabel:@"" textColor:@"#ff5b4c" fontSize:15];
    _keyLabel.font = [UIFont themeFontMedium:15];
    [self addSubview:_keyLabel];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"#a1aab3" fontSize:12];
    [self addSubview:_valueLabel];
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(12);
        make.height.mas_equalTo(25);
        make.right.mas_equalTo(self).offset(-10);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(self.keyLabel.mas_bottom);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self).offset(-10);
        make.bottom.mas_equalTo(self).offset(-12);
    }];
}

@end

// FHDetailRentHouseCoreInfoModel
@implementation FHDetailRentHouseCoreInfoModel


@end