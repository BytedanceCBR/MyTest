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
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHCommutePOIHeaderView ()

@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIImageView *iconImageView;
@property(nonatomic , strong) UILabel *locationLabel;
@property(nonatomic , strong) UIView *bottomLine;
@property(nonatomic , strong) UIButton *refreshButton;
@property(nonatomic , strong) UIActivityIndicatorView *loadingView;

@property(nonatomic , strong) UIView *notInCityBgView;
@property(nonatomic , strong) UILabel *notInCityLabel;

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
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTitleTap:)];
        [_locationLabel addGestureRecognizer:tapGesture];
        _locationLabel.userInteractionEnabled = YES;
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor themeGray6];

        img = ICON_FONT_IMG(18, @"\U0000e6ac", [UIColor themeGray3]);//refresh_gray
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setImage:img forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
        
        _loadingView = [[UIActivityIndicatorView alloc] init];
        _loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//        _refreshButton.hidden = YES;
        
        _notInCityBgView = [[UIView alloc] init];
        _notInCityBgView.backgroundColor = [UIColor whiteColor];
        
        _notInCityLabel = [[UILabel alloc]init];
        NSString *cityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
        _notInCityLabel.text = [NSString stringWithFormat:@"当前位置不在「%@」市内，请直接搜索或返回首页更改城市",cityName];
        _notInCityLabel.textColor = [UIColor themeGray3];
        _notInCityLabel.font = [UIFont themeFontRegular:12];
        _notInCityLabel.numberOfLines = 0;
        
        [_notInCityBgView addSubview:_notInCityLabel];
        _notInCityBgView.hidden = YES;
        
        [self addSubview:_tipLabel];
        [self addSubview:_iconImageView];
        [self addSubview:_locationLabel];
        [self addSubview:_refreshButton];
        [self addSubview:_loadingView];
        [self addSubview:_bottomLine];
        [self addSubview:_notInCityBgView];
        
        [self initConstraints];
    }
    return self;
    
}

-(void)initConstraints
{
 
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN_NEW);
        make.right.mas_lessThanOrEqualTo(-HOR_MARGIN_NEW).priorityLow();
        make.bottom.mas_equalTo(self.mas_centerY).offset(-4);
    }];
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN_NEW);
        make.centerY.mas_equalTo(self.locationLabel);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(2);
        make.top.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(-50).priorityLow();//一直显示刷新
        make.height.mas_equalTo(20);
    }];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left. mas_equalTo(HOR_MARGIN_NEW);
        make.right.mas_equalTo(-HOR_MARGIN_NEW).priorityLow();
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(ONE_PIXEL);
    }];
    
    [_refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-HOR_MARGIN_NEW).priorityLow();
        make.centerY.mas_equalTo(_locationLabel);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.refreshButton);
    }];
    
    [_notInCityBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [_notInCityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN_NEW);
        make.right.mas_equalTo(-HOR_MARGIN_NEW).priorityLow();
        make.top.mas_equalTo(20);
        make.bottom.mas_lessThanOrEqualTo(self.notInCityBgView);
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

-(void)refreshAction
{
    if (_refreshBlock) {
        _refreshBlock();
    }
}

-(void)setShowNotInCityTip:(BOOL)showNotInCityTip
{
    _notInCityBgView.hidden = !showNotInCityTip;
    CGRect frame = self.frame;
    frame.size.height = showNotInCityTip?57:76;
    self.frame = frame;
}

-(BOOL)showNotInCityTip
{
    return !_notInCityBgView.hidden;
}

//-(void)setShowRefresh:(BOOL)showRefresh
//{
//    if (_refreshButton.hidden == showRefresh) {
//        _refreshButton.hidden = !showRefresh;
//        [_locationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(self).offset(showRefresh?-40:-HOR_MARGIN_NEW);
//        }];
//    }    
//}
//
//-(BOOL)showRefresh
//{
//    return !_refreshButton.hidden;
//}

-(void)setLoading:(BOOL)loading
{
    _loading = loading;
    if (loading) {
        [_loadingView startAnimating];
    }else{
        [_loadingView stopAnimating];
    }
    self.refreshButton.hidden = loading;
}

-(void)onTitleTap:(id)sender
{
    if (_locationTapBlock) {
        _locationTapBlock();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
