//
//  FHSystemMsgCell.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import "FHSystemMsgCell.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"

@interface FHSystemMsgCell()

@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIImageView *rightArror;

@end

@implementation FHSystemMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor themeGray7];
    
    self.dateView = [[UIView alloc] init];
    _dateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    _dateView.layer.cornerRadius = 4;
    _dateView.layer.masksToBounds = YES;
    [self.contentView addSubview:_dateView];
    
    self.dateLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor whiteColor]];
    [_dateView addSubview:_dateLabel];
    
    self.cardView = [[UIView alloc] init];
    _cardView.backgroundColor = [UIColor whiteColor];
    _cardView.layer.cornerRadius = 4;
    _cardView.layer.masksToBounds = YES;
    [self.contentView addSubview:_cardView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_cardView addSubview:_titleLabel];
    
    self.imgView = [[UIImageView alloc] init];
    _imgView.backgroundColor = [UIColor themeGray5];
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.layer.cornerRadius = 4;
    _imgView.layer.masksToBounds = YES;
    _imgView.layer.borderWidth = 0.5;
    _imgView.layer.borderColor = [[UIColor themeGray6] CGColor];
    [_cardView addSubview:_imgView];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    self.descLabel.textAlignment = NSTextAlignmentLeft;
    self.descLabel.numberOfLines = 0;
    [_cardView addSubview:_descLabel];
    
    self.lookDetailView = [[UIView alloc] init];
    [_cardView addSubview:_lookDetailView];
    
    self.topLineView = [[UIView alloc] init];
    _topLineView.backgroundColor = [UIColor themeGray6];
    [_lookDetailView addSubview:_topLineView];
    
    self.lookDetailLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    [_lookDetailView addSubview:_lookDetailLabel];
    
    self.rightArror = [[UIImageView alloc] init];
    _rightArror.image = [UIImage imageNamed:@"arrowicon-feed"];
    [_lookDetailView addSubview:_rightArror];
}

- (void)initConstraints {
    [self.dateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateView.mas_left).offset(10);
        make.right.mas_equalTo(self.dateView.mas_right).offset(-10);
        make.center.mas_equalTo(self.dateView);
    }];
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(self.dateView.mas_bottom).offset(14);
        make.bottom.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cardView).offset(20);
        make.right.mas_equalTo(self.cardView).offset(-20);
        make.top.mas_equalTo(self.cardView).offset(14);
    }];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cardView).offset(20);
        make.right.mas_equalTo(self.cardView).offset(-20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(14);
        make.height.equalTo(self.imgView.mas_width).multipliedBy(0.56);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cardView).offset(20);
        make.right.mas_equalTo(self.cardView).offset(-20);
        make.top.mas_equalTo(self.imgView.mas_bottom).offset(10);
    }];
    
    [self.lookDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cardView);
        make.right.mas_equalTo(self.cardView);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.cardView.mas_bottom);
    }];
    
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.lookDetailView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.lookDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lookDetailView).offset(20);
        make.right.mas_equalTo(self.rightArror.mas_left).offset(-15);
        make.centerY.mas_equalTo(self.lookDetailView);
    }];
    
    [self.rightArror mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.lookDetailView).offset(-20);
        make.centerY.mas_equalTo(self.lookDetailLabel.mas_centerY);
        make.width.height.mas_equalTo(18).priorityHigh();
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateImgViewConstraintsWithWidth:(CGFloat) width height:(CGFloat)height {
    CGFloat radio = height/width;
    
    [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cardView).offset(20);
        make.right.mas_equalTo(self.cardView).offset(-20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(14);
        make.height.equalTo(self.imgView.mas_width).multipliedBy(radio);
    }];
}

@end
