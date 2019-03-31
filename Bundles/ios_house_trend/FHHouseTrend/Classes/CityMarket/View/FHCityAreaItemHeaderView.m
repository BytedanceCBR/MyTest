//
//  FHCityAreaItemHeaderView.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityAreaItemHeaderView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "ReactiveObjC.h"

@interface FHCityAreaItemHeaderView ()
@property (nonatomic, strong) UIImageView* arrawView;
@end

@implementation FHCityAreaItemHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont themeFontSemibold:18];
    _nameLabel.textColor = [UIColor themeGray1];
    [self addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(30);
        make.height.mas_equalTo(25);
    }];

    self.openMore = [[UIButton alloc] init];
    NSString* text = @"查看全部";
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: text];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont themeFontRegular:14] range:NSMakeRange(0, text.length)];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, text.length)];

    [_openMore setAttributedTitle:attributedStr forState:UIControlStateNormal];
    _openMore.alpha = 0.6;
    [self addSubview:_openMore];
    [_openMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-34);
        make.centerY.mas_equalTo(self.nameLabel);
        make.height.mas_equalTo(22);
    }];

    self.arrawView = [[UIImageView alloc] init];
    _arrawView.image = [UIImage imageNamed:@"arrowicon-detail-gray"];
    [self addSubview:_arrawView];
    [_arrawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.with.mas_equalTo(14);
        make.centerY.mas_equalTo(_openMore);
        make.left.mas_equalTo(_openMore.mas_right);
    }];

    self.headerNameLabel = [[UILabel alloc] init];
    _headerNameLabel.font = [UIFont themeFontRegular:14];
    _headerNameLabel.textColor = [UIColor themeGray3];
    _headerNameLabel.text = @"小区名称";
    [self addSubview:_headerNameLabel];
    [_headerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(15);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-3);
    }];

    self.headerPriceLabel = [[UILabel alloc] init];
    _headerPriceLabel.font = [UIFont themeFontRegular:14];
    _headerPriceLabel.textColor = [UIColor themeGray3];
    _headerPriceLabel.text = @"均价";
    [self addSubview:_headerPriceLabel];
    [_headerPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(188);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(15);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-3);
    }];

    self.headerCountLabel = [[UILabel alloc] init];
    _headerCountLabel.font = [UIFont themeFontRegular:14];
    _headerCountLabel.textColor = [UIColor themeGray3];
    _headerCountLabel.text = @"在售套数";
    [self addSubview:_headerCountLabel];
    [_headerCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-27);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(15);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-3);
    }];

    UIView* lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor themeGray6];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self);
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
 
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
