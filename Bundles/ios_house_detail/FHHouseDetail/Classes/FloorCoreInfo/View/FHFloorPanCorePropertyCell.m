//
//  FHDetailNewHouseNewsCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHFloorPanCorePropertyCell.h"
#import <TTRoute.h>

@interface FHFloorPanCorePropertyCell ()

@end

@implementation FHFloorPanCorePropertyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)maskButtonClick:(UIButton *)button {
   
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHFloorPanCorePropertyCellModel class]]) {
        FHFloorPanCorePropertyCellModel *model = (FHFloorPanCorePropertyCellModel *)data;
        UIView *previouseView = nil;
        for (NSInteger i = 0; i < [model.list count]; i++) {
            UIView *itemContenView = [UIView new];
          
            FHFloorPanCorePropertyCellItemModel *itemModel = model.list[i];
            UILabel *nameLabel = [UILabel new];
            nameLabel.font = [UIFont themeFontRegular:15];
            nameLabel.textColor = [UIColor themeGray3];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.numberOfLines = 0;
            nameLabel.text = itemModel.propertyName;
            [itemContenView addSubview:nameLabel];
            
            [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(15);
                make.width.mas_equalTo(60);
                make.top.mas_equalTo(0);
                make.height.mas_equalTo(21);
            }];
            
            UILabel *valueLabel = [UILabel new];
            valueLabel.font = [UIFont themeFontRegular:15];
            valueLabel.textColor = [UIColor themeGray1];
            valueLabel.textAlignment = NSTextAlignmentLeft;
            valueLabel.numberOfLines = 0;
            valueLabel.text = itemModel.propertyValue;
            [itemContenView addSubview:valueLabel];
            
            [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(nameLabel.mas_right).offset(30);
                make.top.equalTo(nameLabel);
                make.right.equalTo(itemContenView).offset(-15);
                make.bottom.equalTo(itemContenView).offset(-7);
            }];
            
            [self.contentView addSubview:itemContenView];
            [itemContenView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (previouseView) {
                    make.top.equalTo(previouseView.mas_bottom).offset(10);
                }else
                {
                    make.top.equalTo(self.contentView).offset(18);
                }
                if (i == [model.list count] - 1) {
                    make.bottom.equalTo(self.contentView).offset(-10);
                }
                make.left.right.equalTo(self.contentView);
            }];
            
            previouseView = itemContenView;
        }
    }

}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
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

@implementation FHFloorPanCorePropertyCellItemModel

@end

@implementation FHFloorPanCorePropertyCellModel

@end
