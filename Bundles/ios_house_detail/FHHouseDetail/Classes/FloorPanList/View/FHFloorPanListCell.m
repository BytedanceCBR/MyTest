//
//  FHFloorPanListCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListCell.h"
#import "FHDetailNewModel.h"
#import <BDWebImage.h>

@interface FHFloorPanListCell ()
@property (nonatomic , strong) UIImageView *iconView;
@property (nonatomic , strong) UILabel *nameLabel;
@property (nonatomic , strong) UILabel *roomSpaceLabel;
@property (nonatomic , strong) UILabel *priceLabel;
@property (nonatomic , strong) UIButton *mapMaskBtn;
@property (nonatomic , strong) UIView *statusBGView;
@property (nonatomic , strong) UILabel *statusLabel;
@end

@implementation FHFloorPanListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _iconView = [UIImageView new];
        _iconView.image = [UIImage imageNamed:@"default_image"];
        _iconView.layer.borderColor = [UIColor themeGray6].CGColor;
        _iconView.layer.borderWidth = 0.5;
        _iconView.layer.cornerRadius = 4;
        _iconView.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_iconView];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.bottom.equalTo(self.contentView).offset(-10);
            make.top.equalTo(self.contentView).offset(10);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(75);
        }];
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont themeFontMedium:16];
        _nameLabel.textColor = [UIColor themeGray1];
        _nameLabel.textAlignment = NSTextAlignmentLeft;

        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(12);
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(22);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(22);
        }];

        _roomSpaceLabel = [UILabel new];
        _roomSpaceLabel.font = [UIFont themeFontRegular:12];
        _roomSpaceLabel.textColor = [UIColor themeGray3];
        _roomSpaceLabel.textAlignment = NSTextAlignmentLeft;

        [self.contentView addSubview:_roomSpaceLabel];

        [_roomSpaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(12);
            make.top.equalTo(self.nameLabel.mas_bottom);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(16);
        }];


        _priceLabel = [UILabel new];
        _priceLabel.font = [UIFont themeFontMedium:14];
        _priceLabel.textColor = [UIColor themeRed1];
        _priceLabel.textAlignment = NSTextAlignmentLeft;

        [self.contentView addSubview:_priceLabel];

        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(12);
            make.top.equalTo(self.roomSpaceLabel.mas_bottom).offset(12);
            make.bottom.mas_equalTo(-10);
            make.height.mas_equalTo(20);
        }];


        _statusBGView = [UIView new];
        _statusBGView.layer.cornerRadius = 2;
        _statusBGView.layer.masksToBounds = YES;

        [self.contentView addSubview:_statusBGView];
        [_statusBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_right).offset(5);
            make.centerY.equalTo(self.priceLabel);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(26);
            make.height.mas_equalTo(15);
        }];

        _statusLabel = [UILabel new];
        _statusLabel.font = [UIFont themeFontRegular:10];
        _statusLabel.textColor = [UIColor themeGray1];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        [_statusBGView addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.statusBGView);
            make.height.mas_equalTo(11);
            make.width.mas_equalTo(20);
        }];

    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        FHDetailNewDataFloorpanListListModel *model = (FHDetailNewDataFloorpanListListModel*)data;
        self.nameLabel.text = model.title;
        if ([model.squaremeter isKindOfClass:[NSString class]]) {
            self.roomSpaceLabel.text = [NSString stringWithFormat:@"建面 %@",model.squaremeter];
        }else
        {
            self.roomSpaceLabel.text = @"";
        }
        
        self.priceLabel.text = model.pricingPerSqm;
        
        if ([model.images.firstObject isKindOfClass:[FHDetailNewDataFloorpanListListImagesModel class]]) {
            FHDetailNewDataFloorpanListListImagesModel *imageModel = (FHDetailNewDataFloorpanListListImagesModel *)model.images.firstObject;
            if (imageModel.url) {
                NSURL *urlImage = [NSURL URLWithString:imageModel.url];
                if ([urlImage isKindOfClass:[NSURL class]]) {
                    [self.iconView bd_setImageWithURL:urlImage placeholder:[UIImage imageNamed:@"default_image"]];
                }else
                {
                    _iconView.image = [UIImage imageNamed:@"default_image"];
                }
            }
        }
        
        if (!model.saleStatus) {
            self.statusLabel.text = @"";
            self.statusBGView.backgroundColor = [UIColor clearColor];
            return;
        }

        self.statusLabel.text = model.saleStatus.content;
        if ([model.saleStatus.textColor isKindOfClass:[NSString class]]) {
            self.statusLabel.textColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",model.saleStatus.textColor]];
        }else
        {
            self.statusLabel.textColor = [UIColor whiteColor];
        }

        if ([model.saleStatus.backgroundColor isKindOfClass:[NSString class]]) {
            self.statusLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",model.saleStatus.backgroundColor]];
            _statusBGView.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",model.saleStatus.backgroundColor]];

        }else
        {
            self.statusLabel.backgroundColor = [UIColor whiteColor];
            _statusBGView.backgroundColor = [UIColor whiteColor];
        }
        
        if (model.index == 0) {
            [_iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(20);
                make.bottom.equalTo(self.contentView).offset(-10);
                make.top.equalTo(self.contentView).offset(20);
                make.width.mas_equalTo(100);
                make.height.mas_equalTo(75);
            }];
            
            [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.iconView.mas_right).offset(12);
                make.top.mas_equalTo(20);
                make.right.mas_equalTo(22);
                make.width.mas_equalTo(100);
                make.height.mas_equalTo(22);
            }];
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
