//
//  FHHomeSearchPanelView.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import "FHHomeSearchPanelView.h"
#import "UIColor+Theme.h"
#import "TTThemeConst.h"
#import "UIFont+House.h"
#import "FHEnvContext.h"
@interface FHHomeSearchPanelView()
{
    BOOL isHighlighted;
    NSTimer *timer;
}
@property(nonatomic, strong) UIButton * changeCountryBtn;
@property(nonatomic, strong) UIButton * searchBtn;
@property(nonatomic, strong) UIImageView * triangleImage;
@property(nonatomic, strong) UIView * verticalLineView;
@property(nonatomic, strong) UIView * searchIconBackView;
@property(nonatomic, strong) UIView * searchIcon;
@property(nonatomic, strong) UILabel * categoryPlaceholderLabel;
@property(nonatomic, strong) UILabel * categoryLabel1;
@property(nonatomic, strong) UILabel * categoryLabel2;
@property(nonatomic, strong) UIView * categoryBgView;
@property(nonatomic, assign) NSUInteger searchTitleIndex;
 
@end


@implementation FHHomeSearchPanelView

- (instancetype)initWithFrame:(CGRect)frame withHighlight:(BOOL)highlighted
{
    if (self = [super initWithFrame:frame]) {
        isHighlighted = highlighted;
        [self setPanelStyle];
        [self setupCountryLabel];
        [self setupVerticalLine];
        [self setSearchArea];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        isHighlighted = NO;
        [self setPanelStyle];
        [self setupCountryLabel];
        [self setupVerticalLine];
        [self setSearchArea];
    }
    
    return self;
}

- (void)setPanelStyle
{
    if (isHighlighted) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithHexString:kFHColorClearBlue].CGColor;
    self.layer.masksToBounds = true;
    self.layer.cornerRadius = 4;
}

- (void)setupCountryLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont themeFontSemibold:14];
    label.textColor = [UIColor colorWithHexString:@"#081f33"];
    label.numberOfLines = 1;
    if ([[FHEnvContext getCurrentSelectCityIdFromLocal] isKindOfClass:[NSString class]])
    {
        label.text = [FHEnvContext getCurrentSelectCityIdFromLocal];
    }else
    {
        label.text = @"深圳";
    }
    self.countryLabel = label;
    [self addSubview:self.countryLabel];
    
    [self.countryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(28);
    }];
    
    [self.countryLabel sizeToFit];
    
    self.triangleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-triangle-open"]];
    [self addSubview:self.triangleImage];
    
    
    [self.triangleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.countryLabel).offset(8);
        make.centerY.equalTo(self);
        make.height.width.mas_equalTo(10);
    }];
    
}

- (void)setupVerticalLine
{
    self.verticalLineView = [UIView new];
    self.verticalLineView.backgroundColor = [UIColor colorWithHexString:@"#dae0e6"];
    [self addSubview:self.verticalLineView];
    
    [self.verticalLineView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.triangleImage.mas_right).offset(11);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(15);
    }];

    
    self.changeCountryBtn = [UIButton new];
    [self addSubview:self.changeCountryBtn];
    
    [self.changeCountryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.left.equalTo(self);
        make.right.equalTo(self.verticalLineView.mas_left);
    }];
}

- (void)setSearchArea
{
    
    self.searchIconBackView = [UIView new];
    self.searchIconBackView.backgroundColor =  [UIColor colorWithHexString:kFHColorClearBlue];
    [self addSubview:self.searchIconBackView];
    
    
    [self.searchIconBackView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.height.equalTo(self);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width / 375);
    }];
    
    self.searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-icon-search"]];
    [self.searchIconBackView addSubview:self.searchIcon];
    
    
    [self.searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
        make.width.height.mas_equalTo(16);
    }];
    
    
    self.categoryPlaceholderLabel = [UILabel new];
    self.categoryPlaceholderLabel.font = [UIFont themeFontRegular:14];
    self.categoryPlaceholderLabel.textColor =  [UIColor colorWithHexString:@"#8a9299"];
    self.categoryPlaceholderLabel.text = [UIScreen mainScreen].bounds.size.width < 375 ? @"输入小区/商圈/地铁" : @"请输入小区/商圈/地铁";
    
    [self addSubview:self.categoryPlaceholderLabel];
    
    
    [self.categoryPlaceholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.verticalLineView.mas_right);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self);
        make.right.equalTo(self.searchIconBackView.mas_left).offset(-2);
    }];

    self.categoryBgView = [UIView new];
    self.categoryBgView.clipsToBounds = true;
    self.categoryBgView.hidden = true;
    [self addSubview:self.categoryBgView];
    
    
    [self.categoryBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.verticalLineView.mas_right).offset(10);
        make.height.mas_equalTo(38);
        make.right.equalTo(self.searchIconBackView.mas_left).offset(-2);
        make.centerY.equalTo(self);
    }];
    
    
    self.categoryLabel1 = [UILabel new];
    self.categoryLabel1.font = [UIFont themeFontRegular:14];
    self.categoryLabel1.textColor = [UIColor colorWithHexString:@"#081f33"];
    self.categoryLabel1.text = @"";
  
    
    [self.categoryBgView addSubview:self.categoryLabel1];
    
    [self.categoryLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.left.right.centerY.equalTo(self);
        make.height.mas_equalTo(20);
    }];
    
    
    self.categoryLabel2 = [UILabel new];
    self.categoryLabel2.font = [UIFont themeFontRegular:14];
    self.categoryLabel2.textColor = [UIColor colorWithHexString:@"#081f33"];
    self.categoryLabel2.text = @"";
    
    [self.categoryBgView addSubview:self.categoryLabel2];
    
    [self.categoryLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(29);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(20);
    }];
    
    self.searchBtn = [UIButton new];
    [self addSubview:self.searchBtn];
    
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.verticalLineView.mas_right);
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)setUpTimer
{
   timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(animateTitle) userInfo:nil repeats:YES];
}

- (void)animateTitle
{
    if (self.categoryBgView.isHidden) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.categoryLabel1.alpha = 0;
        self.categoryLabel2.alpha = 1;
        [self.categoryLabel1 setFrame:CGRectMake(self.categoryLabel1.frame.origin.x, -11, self.categoryLabel1.frame.size.width, self.categoryLabel1.frame.size.height)];
        [self.categoryLabel2 setFrame:CGRectMake(self.categoryLabel2.frame.origin.x, 9, self.categoryLabel2.frame.size.width, self.categoryLabel2.frame.size.height)];
    } completion:^(BOOL finished) {
        self.categoryLabel1.alpha = 1;
        self.categoryLabel2.alpha = 0;
        
        [self.categoryLabel1 setFrame:CGRectMake(self.categoryLabel1.frame.origin.x,9, self.categoryLabel1.frame.size.width, self.categoryLabel1.frame.size.height)];
        [self.categoryLabel2 setFrame:CGRectMake(self.categoryLabel2.frame.origin.x, 29, self.categoryLabel2.frame.size.width, self.categoryLabel2.frame.size.height)];
        
        [self nextTitleIndex];
        [self updateTitleText];
    }];
}

- (void)nextTitleIndex
{
    if (_searchTitleIndex >= 0 && _searchTitles.count > 0 && _searchTitleIndex < _searchTitles.count) {
        self.searchTitleIndex = (_searchTitleIndex + 1) % _searchTitles.count;
    }
}

- (void)updateTitleText
{
    if (_searchTitleIndex >= 0 && _searchTitles.count > 0 && _searchTitleIndex < _searchTitles.count) {
        self.categoryLabel1.text = _searchTitles[_searchTitleIndex];
        NSInteger tempIndex = (_searchTitleIndex + 1) % _searchTitles.count;
        self.categoryLabel2.text = _searchTitles[tempIndex];
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
