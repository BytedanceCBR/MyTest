//
//  FHDetectiveItemView.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/7/2.
//

#import "FHDetectiveItemView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHDetailOldModel.h"
#import <TTBaseLib/UIImageAdditions.h>
#import <FHHouseBase/FHUtils.h>
#import <TTBaseLib/UIViewAdditions.h>

@interface FHDetectiveItemView ()

@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) UIView *leftView;
@property(nonatomic , strong) UIView *rightView;
@property(nonatomic , strong) UIImageView *icon;
@property(nonatomic , strong) UIImageView *tipImageView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *stateLabel;
@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIView *bottomLine;

@end

@implementation FHDetectiveItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        _leftView = [[UIView alloc] init];
        [_contentView addSubview:_leftView];
        
        _rightView = [[UIView alloc] init];
        [_contentView addSubview:_rightView];
        
        _icon = [[UIImageView alloc] init];
        _icon.layer.cornerRadius = 20;
        _icon.layer.masksToBounds = YES;
        _tipImageView = [[UIImageView alloc] init];
        _titleLabel = [self labelWithFont:[UIFont themeFontMedium:14] color:[UIColor themeGray1]];
        _stateLabel = [self labelWithFont:[UIFont themeFontRegular:12] color:[UIColor themeGray2]];
        _tipLabel = [self labelWithFont:[UIFont themeFontRegular:12] color:[UIColor themeGray3]];
        _tipLabel.numberOfLines = 0;
        _bottomLine = [[UIView alloc]init];
        _bottomLine.backgroundColor = [UIColor themeGray6];
        
        [_leftView addSubview:_icon];
        [_leftView addSubview:_stateLabel];
        
        [_rightView addSubview:_titleLabel];
        [_rightView addSubview:_tipImageView];
        [_rightView addSubview:_tipLabel];
        [self.contentView addSubview:_bottomLine];

        [self initConstraints];
    }
    return self;
}

- (UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    
    return label;
}

- (void)updateWithModel:(FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel *)model
{
    if (model.icon.length > 0) {
        [self.icon bd_setImageWithURL:[NSURL URLWithString:model.icon] placeholder:[FHUtils createImageWithColor:[UIColor themeGray7]]];
    }else {
        self.icon.image = [FHUtils createImageWithColor:[UIColor themeGray7]];
    }
    BOOL ok = model.status.integerValue == 0;
    self.tipImageView.image = [UIImage imageNamed: ok?@"detail_check_ok":@"detail_check_failed"];
    
    self.stateLabel.text  = model.title;
    self.titleLabel.text = model.subTitle;
    self.tipLabel.text = model.explainContent;
    CGFloat height = [FHDetectiveItemView heightForTile:model.title tip:model.explainContent];
    [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)showBottomLine:(BOOL)isShow
{
    self.bottomLine.hidden = !isShow;
}

- (void)initConstraints
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(84);
        make.height.mas_equalTo(40 + 17 + 4);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftView.mas_right);
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0);
    }];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.stateLabel);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(0);
    }];
    [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.centerY.mas_equalTo(self.titleLabel);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(4);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(17);
        make.bottom.mas_equalTo(0);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(25);
        make.right.mas_equalTo(-15);
    }];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

+ (CGFloat)heightForTile:(NSString *)title tip:(NSString *)tip
{
    CGFloat height = 25;
    CGFloat width = [[UIScreen mainScreen]bounds].size.width - 2 * 20 - 84 - 15;
    UIFont *font = [UIFont themeFontRegular:12];
    height += [tip boundingRectWithSize:CGSizeMake(width, INT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height;
    
    height = ceil(height);
    
    return height;
}

@end
