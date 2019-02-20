//
//  FHFloorPanTitleCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/20.
//

#import "FHFloorPanTitleCell.h"
@interface FHFloorPanTitleCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *pricingLabel;
@property (nonatomic, strong) UILabel *pricingPerSqm;
@property (nonatomic, strong) UIView *statusBGView;
@property (nonatomic, strong) UILabel *statusLabel;

@end
@implementation FHFloorPanTitleCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor themeBlue1];
        _nameLabel.font = [UIFont themeFontMedium:24];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(15);
            make.height.mas_equalTo(34);
        }];
        
        
        _pricingLabel = [UILabel new];
        _pricingLabel.textColor = [UIColor colorWithHexString:@"#f85959"];
        _pricingLabel.font = [UIFont themeFontMedium:16];
        [self.contentView addSubview:_pricingLabel];
        [_pricingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.equalTo(self.nameLabel.mas_bottom);
            make.bottom.mas_equalTo(-15);
            make.height.mas_equalTo(22);
        }];
        
        _pricingPerSqm = [UILabel new];
        _pricingPerSqm.textColor = [UIColor themeGray2];
        _pricingPerSqm.font = [UIFont themeFontMedium:14];
        [self.contentView addSubview:_pricingPerSqm];
        [_pricingPerSqm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pricingLabel.mas_right).offset(10);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(2);
            make.height.mas_equalTo(20);
        }];
        
        _statusBGView = [UIView new];
        _statusBGView.layer.cornerRadius = 2;
        [self.contentView addSubview:_statusBGView];
        [_statusBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_right).offset(6);
            make.centerY.equalTo(self.nameLabel.mas_centerY);
            make.height.mas_equalTo(15);
            make.width.mas_equalTo(26);
        }];
        
        
        _statusLabel = [UILabel new];
        _statusLabel.font = [UIFont themeFontRegular:10];
        [_statusBGView addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.statusBGView);
            make.height.mas_equalTo(10);
            make.width.mas_equalTo(20);
        }];
        
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHFloorPanTitleCellModel class]]) {
        FHFloorPanTitleCellModel *model = (FHFloorPanTitleCellModel *)data;
        self.nameLabel.text = model.title;
        self.pricingLabel.text = model.pricing;
        self.pricingPerSqm.text = model.pricingPerSqm;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation FHFloorPanTitleCellModel


@end
