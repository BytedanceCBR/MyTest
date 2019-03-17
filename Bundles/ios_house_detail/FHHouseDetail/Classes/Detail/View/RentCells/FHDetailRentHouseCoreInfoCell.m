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
#import "UIColor+Theme.h"

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
        __block CGFloat width = ((UIScreen.mainScreen.bounds.size.width - 40) - (count - 1) * fixedSpace) / count;
        __block CGFloat leftOffset = 20.0;
        __block BOOL firstWordTooLong = NO;
        [model.coreInfo enumerateObjectsUsingBlock:^(FHDetailOldDataCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailRentHouseCoreInfoItemView *itemView = [[FHDetailRentHouseCoreInfoItemView alloc] init];
            [self.contentView addSubview:itemView];
            // 设置数据
            itemView.keyLabel.text = obj.value;
            itemView.valueLabel.text = obj.attr;
            CGSize size = [itemView.keyLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH, 40)];
            if (size.width + 20 > width && idx == 0) {
                // 第一个数据如果过长，展示完全
                width = size.width + 21;
                firstWordTooLong = YES;
            }
            if (firstWordTooLong) {
                itemView.keyLabel.font = [UIFont themeFontMedium:14];
                if (idx == 0) {
                    // 第一个数据重新计算
                    size = [itemView.keyLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH, 40)];
                    width = size.width + 21;
                }
            } else {
                itemView.keyLabel.font = [UIFont themeFontMedium:15];
            }
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self.contentView);
                make.width.mas_equalTo(width);
                make.left.mas_equalTo(self.contentView).offset(leftOffset);
            }];
            leftOffset += (width + fixedSpace);
            // 重新计算item width
            if (count - 1 - idx > 0 && idx == 0) {
                width = ((UIScreen.mainScreen.bounds.size.width - leftOffset - 20) - (count - 2 - idx) * fixedSpace) / (count - 1 - idx);
            }
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
    self.backgroundColor = [UIColor themeGray7];
    self.layer.cornerRadius = 4.0;
    
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _keyLabel.textColor = [UIColor themeRed1];
    _keyLabel.font = [UIFont themeFontMedium:15];
    [self addSubview:_keyLabel];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _valueLabel.textColor = [UIColor themeGray3];
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
