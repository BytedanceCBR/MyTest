//
//  FHDetailNewHouseNewsCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHFloorPanCorePropertyCell.h"
#import "TTRoute.h"
#import "UIColor+Theme.h"

@interface FHFloorPanCorePropertyCell ()

@property (nonatomic , strong) UIView *containerView;

@end

@implementation FHFloorPanCorePropertyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor themeGray7];
        [self.contentView addSubview:self.containerView];
        [self initConstraints];
    }
    return self;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 10;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

-(void)initConstraints
{
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
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
            itemContenView.backgroundColor = [UIColor clearColor];
            FHFloorPanCorePropertyCellItemModel *itemModel = model.list[i];
            UILabel *nameLabel = [UILabel new];
            nameLabel.font = [UIFont themeFontRegular:14];
            nameLabel.textColor = RGB(0xae, 0xad, 0xad);;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.numberOfLines = 0;
            nameLabel.text = itemModel.propertyName;
            [itemContenView addSubview:nameLabel];
            
            [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(31);
                make.width.mas_equalTo(70);
                make.top.mas_equalTo(0);
                make.height.mas_equalTo(20);
            }];
            
            UILabel *valueLabel = [UILabel new];
            valueLabel.font = [UIFont themeFontMedium:14];
            valueLabel.textColor = [UIColor themeGray2];
            valueLabel.textAlignment = NSTextAlignmentLeft;
            valueLabel.numberOfLines = 0;
            valueLabel.text = itemModel.propertyValue;
            [itemContenView addSubview:valueLabel];
            
            [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(nameLabel.mas_right).offset(16);
                make.top.equalTo(nameLabel);
                make.right.equalTo(itemContenView).offset(-15);
                make.bottom.equalTo(itemContenView);
                //make.height.mas_equalTo(16);
            }];
            
            [self.contentView addSubview:itemContenView];
            
            [itemContenView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (previouseView) {
                    make.top.equalTo(previouseView.mas_bottom).offset(14);
                }else
                {
                    make.top.equalTo(self.contentView).offset(27);
                }
                if (i == [model.list count] - 1) {
                    make.bottom.equalTo(self.contentView).offset(-27);
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
    [self.contentView addSubview:self.containerView];
    [self initConstraints];
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
