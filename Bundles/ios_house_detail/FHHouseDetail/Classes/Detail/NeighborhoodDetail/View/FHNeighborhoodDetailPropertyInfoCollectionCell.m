//
//  FHNeighborhoodDetailPropertyInfoCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/12.
//

#import "FHNeighborhoodDetailPropertyInfoCollectionCell.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"

static CGFloat const kFHPropertyItemInfoHeight = 30.0f;

@interface FHNeighborhoodDetailPropertyInfoCollectionCell ()

@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;


@end

@implementation FHNeighborhoodDetailPropertyInfoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        _keyLabel.textColor = [UIColor themeGray3];
        [self addSubview:_keyLabel];
        [_keyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_keyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        _valueLabel.textColor = [UIColor themeGray1];
        _valueLabel.font = [UIFont themeFontMedium:14];
        [self addSubview:_valueLabel];
        _valueLabel.textAlignment = NSTextAlignmentLeft;
        // 布局
        [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(5);
            make.height.mas_equalTo(20);
            make.width.mas_offset(56);
            make.bottom.mas_equalTo(self).offset(-5);
        }];
        
        [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.keyLabel.mas_right).offset(10);
            make.top.mas_equalTo(5);
            make.height.mas_equalTo(20);
            make.right.mas_equalTo(-5);
            make.bottom.mas_equalTo(self.keyLabel);
        }];
        
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHHouseBaseInfoModel class]]) {
        return;
    }
    self.currentData = data;
    FHHouseBaseInfoModel *model = (FHHouseBaseInfoModel *)data;
    self.keyLabel.text = model.attr;
    self.valueLabel.text = model.value;
}

@end
