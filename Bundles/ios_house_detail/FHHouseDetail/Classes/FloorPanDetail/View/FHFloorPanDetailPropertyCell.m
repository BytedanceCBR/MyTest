//
//  FHFloorPanDetailPropertyCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/20.
//

#import "FHFloorPanDetailPropertyCell.h"
#import "FHDetailFloorPanDetailInfoModel.h"

@interface FHFloorPanDetailPropertyCell ()
@property (nonatomic,strong) UIView *topLineView;
@property (nonatomic,strong) UIView *wrapperView;
@property (nonatomic,strong) UIView *bottomMaskView;

@end

@implementation FHFloorPanDetailPropertyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {

        _topLineView = [UIView new];
        _topLineView.backgroundColor = [UIColor themeGray6];
        [self.contentView addSubview:_topLineView];
        _topLineView.alpha = 0.7;
        [_topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.height.mas_equalTo(0.5);
        }];
        
        _wrapperView = [UIView new];
        [self.contentView addSubview:_wrapperView];
        [_wrapperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(6);
            make.bottom.equalTo(self.contentView).offset(-20);
            make.left.right.equalTo(self.contentView);
        }];
        
        
        _bottomMaskView = [UIView new];
        [self.contentView addSubview:_bottomMaskView];
        [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(6);
            make.left.right.bottom.equalTo(self.contentView);
        }];
        
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHFloorPanDetailPropertyCellModel class]]) {
        FHFloorPanDetailPropertyCellModel *model = (FHFloorPanDetailPropertyCellModel *)data;
        UIView *previouseView = nil;
        for (NSInteger i = 0; i < [model.baseInfo count]; i++) {
            UIView *itemContenView = [UIView new];
            
            FHDetailFloorPanDetailInfoDataBaseInfoModel *itemModel = model.baseInfo[i];
            UILabel *nameLabel = [UILabel new];
            nameLabel.font = [UIFont themeFontRegular:15];
            nameLabel.textColor = [UIColor themeGray2];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.numberOfLines = 0;
            nameLabel.text = itemModel.attr;
            [itemContenView addSubview:nameLabel];
            
            
            [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(15);
                make.top.mas_equalTo(0);
            }];
            
            
            UILabel *valueLabel = [UILabel new];
            valueLabel.font = [UIFont themeFontRegular:15];
            valueLabel.textColor = [UIColor themeGray1];
            valueLabel.textAlignment = NSTextAlignmentLeft;
            valueLabel.numberOfLines = 0;
            valueLabel.text = itemModel.value;
            [itemContenView addSubview:valueLabel];
            
            [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(nameLabel.mas_right).offset(10);
                make.top.equalTo(nameLabel);
                make.bottom.equalTo(itemContenView).offset(-7);
            }];
            
            [self.contentView addSubview:itemContenView];
            [itemContenView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (previouseView) {
                    if (i % 2 == 1) {
                        make.top.equalTo(previouseView);
                    }else
                    {
                        make.top.equalTo(previouseView.mas_bottom).offset(3);
                    }
                }else
                {
                    make.top.equalTo(self.contentView).offset(14);
                }
                if (i == [model.baseInfo count] - 1) {
                    make.bottom.equalTo(self.contentView).offset(-10);
                }
                make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width / 2.0f);
                if (i % 2 == 0) {
                    make.left.equalTo(self.contentView);
                    make.right.equalTo(self.contentView.mas_centerX);
                }else
                {
                    make.left.equalTo(self.contentView.mas_centerX);
                    make.right.equalTo(self.contentView);
                }
            }];
             if (i % 2 == 0) {
                 previouseView = itemContenView;
             }
        }
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

@implementation FHFloorPanDetailPropertyCellModel

@end
