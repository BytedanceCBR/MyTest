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

@interface FHDetectiveItemView ()

@property(nonatomic , strong) UIView *contentView;
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
        
        _icon = [[UIImageView alloc] init];
        _icon.layer.cornerRadius = 20;
        _icon.layer.masksToBounds = YES;
        _tipImageView = [[UIImageView alloc] init];
        _titleLabel = [self labelWithFont:[UIFont themeFontMedium:14] color:[UIColor themeGray1]];
        _stateLabel = [self labelWithFont:[UIFont themeFontRegular:12] color:[UIColor themeGray2]];
        _tipLabel = [self labelWithFont:[UIFont themeFontRegular:12] color:[UIColor themeGray3]];
        _tipLabel.numberOfLines = 0;
        _tipLabel.preferredMaxLayoutWidth = [[UIScreen mainScreen]bounds].size.width - 2 * 20 - 20 - 40 - 24 - 15;
        _bottomLine = [[UIView alloc]init];
        _bottomLine.backgroundColor = [UIColor themeGray6];
        
        [self.contentView addSubview:_icon];
        [self.contentView addSubview:_tipImageView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_stateLabel];
        [self.contentView addSubview:_tipLabel];
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
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(15);
    }];
    [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.centerY.mas_equalTo(self.titleLabel);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.icon.mas_right).offset(24);
        make.height.mas_equalTo(16);
    }];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(4);
        make.left.mas_equalTo(self.icon);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
        make.right.mas_equalTo(-20);
//        make.bottom.mas_equalTo(self.contentView);
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
    CGFloat height = 40;
    CGFloat width = [[UIScreen mainScreen]bounds].size.width - 2 * 20 - 20 - 40 - 24 - 15;
    UIFont *font = [UIFont themeFontRegular:12];
    height += [title boundingRectWithSize:CGSizeMake(width, INT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.height;
    
    height = ceil(height) + 15;
    
    return height;
}

@end
