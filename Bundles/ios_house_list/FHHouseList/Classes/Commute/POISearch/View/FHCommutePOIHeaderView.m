//
//  FHCommutePOIHeaderView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import "FHCommutePOIHeaderView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <Masonry/Masonry.h>

@interface FHCommutePOIHeaderView ()

@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIImageView *iconImageView;
@property(nonatomic , strong) UILabel *locationLabel;
@property(nonatomic , strong) UIView *bottomLine;

@end

@implementation FHCommutePOIHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont themeFontRegular:12];
        _tipLabel.textColor = [UIColor themeGray3];
        _tipLabel.text = @"当前定位";
        
        UIImage *img = SYS_IMG(@"location_light");
        _iconImageView = [[UIImageView alloc]initWithImage:img];
        
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.font = [UIFont themeFontRegular:14];
        _locationLabel.textColor = [UIColor themeGray1];
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor themeGray6];

        [self addSubview:_tipLabel];
        [self addSubview:_iconImageView];
        [self addSubview:_locationLabel];
        [self addSubview:_bottomLine];

        [self initConstraints];
    }
    return self;
    
}

-(void)initConstraints
{
 
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.right.mas_lessThanOrEqualTo(-HOR_MARGIN);
        make.bottom.mas_equalTo(self.mas_centerY).offset(-4);
    }];
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.centerY.mas_equalTo(self.locationLabel);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(2);
        make.top.mas_equalTo(self.mas_centerY);
        make.right.mas_lessThanOrEqualTo(-HOR_MARGIN);
        make.height.mas_equalTo(20);
    }];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left. mas_equalTo(HOR_MARGIN);
        make.right.mas_equalTo(-HOR_MARGIN);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(ONE_PIXEL);
    }];
}

-(void)setLocation:(NSString *)location
{
    _locationLabel.text = location;
}

-(NSString *)location
{
    return _locationLabel.text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
