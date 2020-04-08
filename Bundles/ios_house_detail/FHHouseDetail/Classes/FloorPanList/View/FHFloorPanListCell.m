//
//  FHFloorPanListCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListCell.h"
#import "FHDetailNewModel.h"
#import "BDWebImage.h"

@interface FHFloorPanListCell ()
@property (nonatomic , strong) UIImageView *iconView;
@property (nonatomic , strong) UILabel *nameLabel;
@property (nonatomic , strong) UILabel *roomSpaceLabel;
@property (nonatomic , strong) UILabel *priceLabel;
@property (nonatomic , strong) UIButton *mapMaskBtn;
@property (nonatomic , strong) UIView *statusBGView;
@property (nonatomic , strong) UILabel *statusLabel;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UIView *topLine;
@property (nonatomic , strong) UIView *emptyView;
@end

@implementation FHFloorPanListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
       
        _emptyView = [[UIView alloc] init];
        [self.contentView addSubview:_emptyView];
        _emptyView.backgroundColor = [UIColor themeGray7];
        
        _containerView = [[UIView alloc] init];
        [self.contentView addSubview:_containerView];
        _containerView.backgroundColor = [UIColor whiteColor];
        
        _iconView = [UIImageView new];
        _iconView.image = [UIImage imageNamed:@"default_image"];
        _iconView.layer.borderColor = [UIColor themeGray6].CGColor;
        _iconView.layer.borderWidth = 0.5;
        _iconView.layer.cornerRadius = 4;
        _iconView.layer.masksToBounds = YES;
        [self.containerView addSubview:_iconView];
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont themeFontMedium:16];
        _nameLabel.textColor = [UIColor themeGray1];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.containerView addSubview:_nameLabel];

        _roomSpaceLabel = [UILabel new];
        _roomSpaceLabel.font = [UIFont themeFontRegular:12];
        _roomSpaceLabel.textColor = [UIColor themeGray3];
        _roomSpaceLabel.textAlignment = NSTextAlignmentLeft;
        [self.containerView addSubview:_roomSpaceLabel];

        _priceLabel = [UILabel new];
        _priceLabel.font = [UIFont themeFontMedium:14];
        _priceLabel.textColor = [UIColor themeOrange1];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        [self.containerView addSubview:_priceLabel];

    }
    return self;
}

- (void)refreshWithData:(id)data isFirst:(bool)isFirst isLast:(BOOL)isLast
{
    if (isFirst) {
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(20);
        }];
    }
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.emptyView.mas_bottom);
        make.height.mas_equalTo(106);
    }];
    [self initConstaints];
    [self refreshWithData:data];
}

-(void)initConstaints
{
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.top.mas_equalTo(23);
        make.width.mas_equalTo(53);
        make.height.mas_equalTo(61);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(95);
        make.top.mas_equalTo(32);
        make.right.mas_equalTo(22);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(22);
    }];
    
    [_roomSpaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(12);
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(16);
    }];

    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(12);
        make.top.equalTo(self.roomSpaceLabel.mas_bottom).offset(12);
        make.bottom.mas_equalTo(-10);
        make.height.mas_equalTo(20);
    }];
    
    
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
