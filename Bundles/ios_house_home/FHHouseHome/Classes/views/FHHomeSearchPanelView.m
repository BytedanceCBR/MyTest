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
#import "ReactiveObjC.h"
#import "FHHouseType.h"
#import "TTRoute.h"
#import "FHHouseBridgeManager.h"
#import "FHUserTracker.h"

@interface FHHomeSearchPanelView()
{
    BOOL isHighlighted;
    NSTimer *timer;
}
@property(nonatomic, strong) UIImageView * bgView;
@property(nonatomic, strong) UIImageView * triangleImage;
@property(nonatomic, strong) UIView * verticalLineView;
@property(nonatomic, strong) UIImageView * searchIcon;
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
    
    UIImage *oldImage = [UIImage imageNamed:@"home_search_bg"];
    UIImage *newImage = [oldImage stretchableImageWithLeftCapWidth:oldImage.size.width * 0.5 topCapHeight:oldImage.size.height * 0.5];
    self.bgView = [[UIImageView alloc] initWithImage:newImage];
    self.bgView.contentMode = UIViewContentModeScaleToFill;
    self.bgView.layer.masksToBounds = YES;
    [self addSubview:self.bgView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);

    }];
}

- (void)setupCountryLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont themeFontSemibold:14];
    label.textColor = [UIColor themeGray1];
    label.numberOfLines = 1;
    label.text = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    self.countryLabel = label;
    [self addSubview:self.countryLabel];
    
    [self.countryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(label.text.length * 14);
    }];
    
    [self.countryLabel sizeToFit];
    
    self.triangleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-triangle-open"]];
    [self addSubview:self.triangleImage];
    
    
    [self.triangleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.countryLabel.mas_right).offset(8);
        make.centerY.equalTo(self);
        make.height.width.mas_equalTo(10);
    }];
}

- (void)updateCountryLabelLayout:(NSString *)labelText
{
    [self.countryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(labelText.length * 14);
    }];
}

- (void)setupVerticalLine
{
    self.verticalLineView = [UIView new];
    self.verticalLineView.backgroundColor = [UIColor colorWithHexString:@"#dae0e6"];
    [self addSubview:self.verticalLineView];
    
    [self.verticalLineView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.triangleImage.mas_right).offset(11);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(15);
    }];

    
    self.changeCountryBtn = [UIButton new];
     [[self.changeCountryBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       
    }];
     
    [self addSubview:self.changeCountryBtn];
    
    [self.changeCountryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.left.equalTo(self);
        make.right.equalTo(self.verticalLineView.mas_left);
    }];
}

- (void)setSearchArea
{
    self.searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_icon_search"]];
    [self addSubview:self.searchIcon];

    [self.searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.verticalLineView.mas_right).offset(10);
        make.centerY.mas_equalTo(self.verticalLineView);
        make.width.height.mas_equalTo(20);
    }];

    self.categoryPlaceholderLabel = [UILabel new];
    self.categoryPlaceholderLabel.font = [UIFont themeFontRegular:14];
    self.categoryPlaceholderLabel.textColor = [UIColor themeGray3];
    self.categoryPlaceholderLabel.text = [UIScreen mainScreen].bounds.size.width < 375 ? @"输入小区/商圈/地铁" : @"请输入小区/商圈/地铁";

    [self addSubview:self.categoryPlaceholderLabel];

    [self.categoryPlaceholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIcon.mas_right);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-2);
    }];

    self.categoryBgView = [UIView new];
    self.categoryBgView.clipsToBounds = true;
    self.categoryBgView.hidden = true;
    [self addSubview:self.categoryBgView];


    [self.categoryBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIcon.mas_right);
        make.height.mas_equalTo(38);
        make.right.mas_equalTo(self).offset(-2);
        make.centerY.mas_equalTo(self);
    }];


    self.categoryLabel1 = [UILabel new];
    self.categoryLabel1.font = [UIFont themeFontRegular:14];
    self.categoryLabel1.textColor = [UIColor themeGray1];
    self.categoryLabel1.text = @"";


    [self.categoryBgView addSubview:self.categoryLabel1];

    [self.categoryLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryBgView).offset(9);
        make.left.right.centerY.equalTo(self.categoryBgView);
        make.height.mas_equalTo(20);
    }];


    self.categoryLabel2 = [UILabel new];
    self.categoryLabel2.font = [UIFont themeFontRegular:14];
    self.categoryLabel2.textColor = [UIColor themeGray1];
    self.categoryLabel2.text = @"";

    [self.categoryBgView addSubview:self.categoryLabel2];

    [self.categoryLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryBgView).offset(35);
        make.left.right.equalTo(self.categoryBgView);
        make.height.mas_equalTo(20);
    }];

    self.searchBtn = [UIButton new];
    [self addSubview:self.searchBtn];
    [self.searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.verticalLineView.mas_right);
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)searchBtnClick
{
    SETTRACERKV(UT_ORIGIN_FROM,@"maintab_search");
    NSString *rollText = @"be_null";
    if (self.searchTitleIndex >= 0 && self.searchTitleIndex < self.searchTitles.count) {
        rollText = self.searchTitles[self.searchTitleIndex];
    }
    [self recordClickHouseSearch:rollText];
    NSMutableDictionary *tracerParams = [NSMutableDictionary new];
    tracerParams[@"enter_type"] = @"click";
    tracerParams[@"element_from"] = @"maintab_search";
    tracerParams[@"enter_from"] = @"maintab";
    tracerParams[@"origin_from"] = @"maintab_search";
    
    NSMutableDictionary *infos = [NSMutableDictionary new];
    infos[@"house_type"] = @(FHHouseTypeSecondHandHouse);
    infos[@"tracer"] = tracerParams;
    infos[@"from_home"] = @(1);
    if (self.searchTitleIndex >= 0 && self.searchTitleIndex < self.rollDatas.count) {
        FHHomeRollDataDataModel *model = self.rollDatas[self.searchTitleIndex];
        NSMutableDictionary *homePageRollData = [NSMutableDictionary new];
        homePageRollData[@"text"] = model.text ?: @"";
        homePageRollData[@"guess_search_id"] = model.guessSearchId ?: @"";
        homePageRollData[@"house_type"] = model.houseType ?: @"";
        homePageRollData[@"open_url"] = model.openUrl ?: @"";
        infos[@"homepage_roll_data"] = homePageRollData;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://house_search"] userInfo:userInfo];

}

- (void)recordClickHouseSearch:(NSString *)rollText {
    NSMutableDictionary *tracerDic = [NSMutableDictionary new];
    tracerDic[@"hot_word"] = rollText;
    tracerDic[@"page_type"] = @"maintab";
    tracerDic[@"origin_search_id"] = @"be_null";
    tracerDic[@"origin_from"] = @"maintab_search";
    
    [FHUserTracker writeEvent:@"click_house_search" params:tracerDic];
}

- (void)setUpRollScreenTimer
{
   if (timer)
   {
       [timer invalidate];
       timer = nil;
   }
    
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

- (void)setSearchTitles:(NSMutableArray<NSString *> *)searchTitles
{
    _searchTitles = searchTitles;

    if (kIsNSArray(_searchTitles)) {
        self.searchTitleIndex = 0;
        if (_searchTitles.count  > 0) {
            [self setUpRollScreenTimer];
            self.categoryBgView.hidden = NO;
            self.categoryPlaceholderLabel.hidden = YES;
            [self updateTitleText];
        } else {
            self.categoryBgView.hidden = YES;
            self.categoryPlaceholderLabel.hidden = NO;
        }
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
