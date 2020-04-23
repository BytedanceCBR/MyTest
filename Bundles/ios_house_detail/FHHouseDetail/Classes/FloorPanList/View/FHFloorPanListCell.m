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
@property (nonatomic , strong) UIView *topLine;
@property (nonatomic , strong) UIView *emptyView;
@property (nonatomic , strong) UIView *cellBackView;
@end

@implementation FHFloorPanListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.cellBackView];
        
        _topLine = [[UIView alloc] init];
        [self.contentView addSubview:_topLine];
        _topLine.backgroundColor =  RGB(0xe7, 0xe7, 0xe7);
        
        _iconView = [UIImageView new];
        _iconView.image = [UIImage imageNamed:@"default_image"];
        _iconView.layer.borderColor = RGB(0xed, 0xed, 0xed).CGColor;
        _iconView.layer.borderWidth = 1;
        _iconView.layer.cornerRadius = 8;
        _iconView.layer.masksToBounds = YES;
        [self.contentView addSubview:_iconView];
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont themeFontMedium:16];
        _nameLabel.textColor = RGB(0x4a, 0x4a, 0x4a);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_nameLabel];

        _roomSpaceLabel = [UILabel new];
        _roomSpaceLabel.font = [UIFont themeFontRegular:12];
        _roomSpaceLabel.textColor = [UIColor themeGray3];
        _roomSpaceLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_roomSpaceLabel];

        _priceLabel = [UILabel new];
        _priceLabel.font = [UIFont themeFontSemibold:16];
        _priceLabel.textColor = [UIColor themeOrange1];
        _priceLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_priceLabel];
        
        [self initConstaints];

    }
    return self;
}

- (UIView *)cellBackView
{
    if (!_cellBackView) {
        UIView *cellBackView = [[UIView alloc] init];
        cellBackView.backgroundColor = [UIColor whiteColor];
         cellBackView.hidden = YES;
        _cellBackView = cellBackView;
    }
    return _cellBackView;
}

-(CAShapeLayer *)maskLayer:(UIRectCorner)rectCorner
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-30, 106) byRoundingCorners:rectCorner cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-30, 106);
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

- (void)refreshWithData:(bool)isFirst andLast:(BOOL)isLast
{
    self.cellBackView.hidden = NO;
    if (isFirst && isLast) {
        self.cellBackView.layer.mask = [self maskLayer:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight];
    } else if (isFirst) {
        self.cellBackView.layer.mask = [self maskLayer:UIRectCornerTopLeft | UIRectCornerTopRight];
    } else if (isLast) {
         self.cellBackView.layer.mask = [self maskLayer:UIRectCornerBottomLeft | UIRectCornerBottomRight];
    } else {
        self.cellBackView.layer.mask = nil;
    }
    if (isFirst) {
        self.topLine.hidden = YES;
    } else {
        self.topLine.hidden = NO;
    }
}

-(void)initConstaints
{
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.mas_equalTo(34);
        make.right.mas_equalTo(-34);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.cellBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
    
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(31);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(66);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconView.mas_right).offset(13);
        make.top.mas_equalTo(32);
        make.height.mas_equalTo(19);
    }];
    
    [_roomSpaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(8);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(14);
    }];

    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-31);
        make.top.mas_equalTo(32);
        make.height.mas_equalTo(19);
    }];
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        FHDetailNewDataFloorpanListListModel *model = (FHDetailNewDataFloorpanListListModel*)data;
        self.nameLabel.text = model.title;
        if ([model.squaremeter isKindOfClass:[NSString class]]) {
            if (model.squaremeter.length > 0) {
                NSString *roomSpace = [NSString stringWithFormat:@"建面 %@",model.squaremeter];
                if (model.facingDirection.length > 0) {
                    self.roomSpaceLabel.text = [NSString stringWithFormat:@"%@ | %@", roomSpace, model.facingDirection];
                } else {
                    self.roomSpaceLabel.text = roomSpace;
                }
            } else if (model.facingDirection.length > 0) {
                self.roomSpaceLabel.text = model.facingDirection;
            } else {
                self.roomSpaceLabel.text = @"";
            }
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
