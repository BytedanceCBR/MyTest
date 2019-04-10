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
    NSTimer *timer;
}
@property(nonatomic, strong) UIImageView * bgView;
@property(nonatomic, strong) UILabel * categoryPlaceholderLabel;
@property(nonatomic, strong) UILabel * categoryLabel1;
@property(nonatomic, strong) UILabel * categoryLabel2;
@property(nonatomic, strong) UIView * categoryBgView;
@property(nonatomic, assign) NSUInteger searchTitleIndex;
 
@end


@implementation FHHomeSearchPanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupCityButton];
        [self setSearchArea];
    }
    
    return self;
}

- (void)updateCountryLabelLayout:(NSString *)labelText
{
    self.countryLabel.text = labelText;
    [self.countryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelText.length * 14);
    }];
    
    [self.countryLabel sizeToFit];
}

- (void)setupCityButton
{
    UIButton *citySwichButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.changeCountryBtn = citySwichButton;
    [self addSubview:citySwichButton];
    citySwichButton.layer.cornerRadius = 20;
    citySwichButton.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1f].CGColor;
    citySwichButton.layer.shadowOffset = CGSizeMake(0.f, 2.f);
    citySwichButton.layer.shadowRadius = 6.f;
    citySwichButton.layer.shadowOpacity = 1.f;
    [citySwichButton.titleLabel setFont:[UIFont themeFontRegular:14]];
    citySwichButton.backgroundColor = [UIColor whiteColor];
    NSString *text = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    [citySwichButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.mas_bottom).offset(-12);
    }];
    
    UIImageView *imageButtonLeftIcon = [UIImageView new];
    [citySwichButton addSubview:imageButtonLeftIcon];
    [imageButtonLeftIcon setImage:[UIImage imageNamed:@"combined-shape-1"]];
    [imageButtonLeftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(citySwichButton).offset(14);
        make.height.mas_equalTo(18);
        make.centerY.equalTo(citySwichButton);
        make.width.mas_equalTo(18);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont themeFontRegular:14];
    label.textColor = [UIColor themeGray1];
    label.numberOfLines = 1;
    label.text = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    self.countryLabel = label;
    [self addSubview:self.countryLabel];
    
    [self.countryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imageButtonLeftIcon.mas_right).offset(2);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(label.text.length * 14);
        make.right.mas_equalTo(citySwichButton.mas_right).offset(-14);
    }];
    
    [self.countryLabel sizeToFit];
}

- (void)setSearchArea
{
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchBtn = searchButton;
    [self addSubview:searchButton];
    [self.searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    searchButton.layer.cornerRadius = 20;
    searchButton.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1f].CGColor;
    searchButton.layer.shadowOffset = CGSizeMake(0.f, 2.f);
    searchButton.layer.shadowRadius = 6.f;
    searchButton.layer.shadowOpacity = 1.f;
    [searchButton.titleLabel setFont:[UIFont themeFontRegular:14]];
    searchButton.backgroundColor = [UIColor whiteColor];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.changeCountryBtn.mas_right).offset(10);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.mas_bottom).offset(-12);
        make.right.mas_equalTo(self).offset(-20);
    }];
    
    UIImageView *imageButtonLeftIcon = [UIImageView new];
    [searchButton addSubview:imageButtonLeftIcon];
    [imageButtonLeftIcon setImage:[UIImage imageNamed:@"search-name"]];
    [imageButtonLeftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchButton).offset(14);
        make.height.mas_equalTo(16);
        make.centerY.equalTo(searchButton);
        make.width.mas_equalTo(16);
    }];
    
    
    self.categoryPlaceholderLabel = [UILabel new];
    self.categoryPlaceholderLabel.font = [UIFont themeFontRegular:14];
    self.categoryPlaceholderLabel.textColor = [UIColor themeGray3];
    self.categoryPlaceholderLabel.text = [UIScreen mainScreen].bounds.size.width < 375 ? @"输入小区/商圈/地铁" : @"请输入小区/商圈/地铁";
    
    [self addSubview:self.categoryPlaceholderLabel];
    
    [self.categoryPlaceholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imageButtonLeftIcon.mas_right).offset(2);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-2);
    }];
    
    self.categoryBgView = [UIView new];
    self.categoryBgView.clipsToBounds = true;
    self.categoryBgView.hidden = true;
    [self addSubview:self.categoryBgView];
    self.categoryBgView.userInteractionEnabled = NO;
    
    
    [self.categoryBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imageButtonLeftIcon.mas_right).offset(2);
        make.height.mas_equalTo(38);
        make.right.mas_equalTo(self.searchBtn.mas_right).offset(0);
        make.centerY.mas_equalTo(self);
    }];
    
    
    self.categoryLabel1 = [UILabel new];
    self.categoryLabel1.font = [UIFont themeFontRegular:14];
    self.categoryLabel1.textColor = [UIColor themeGray3];
    self.categoryLabel1.text = @"";
    
    
    [self.categoryBgView addSubview:self.categoryLabel1];
    
    [self.categoryLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryBgView).offset(9);
        make.left.centerY.equalTo(self.categoryBgView);
        make.height.mas_equalTo(20);
        make.right.equalTo(self.categoryBgView).offset(-6);
    }];
    
    
    self.categoryLabel2 = [UILabel new];
    self.categoryLabel2.font = [UIFont themeFontRegular:14];
    self.categoryLabel2.textColor = [UIColor themeGray3];
    self.categoryLabel2.text = @"";
    
    [self.categoryBgView addSubview:self.categoryLabel2];
    
    [self.categoryLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryBgView).offset(35);
        make.left.equalTo(self.categoryBgView);
        make.height.mas_equalTo(20);
        make.right.equalTo(self.categoryBgView).offset(-6);
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
        if (model.detail.count > 0) {
            FHHomeRollDataDataDetailModel *detailModel = model.detail[0];
            NSMutableDictionary *homePageRollData = [NSMutableDictionary new];
            homePageRollData[@"text"] = detailModel.text ?: @"";
            homePageRollData[@"guess_search_id"] = detailModel.guessSearchId ?: @"";
            homePageRollData[@"house_type"] = detailModel.houseType ?: @"";
            homePageRollData[@"open_url"] = detailModel.openUrl ?: @"";
            infos[@"homepage_roll_data"] = homePageRollData;
            // 猜你想搜前3个词：guessYouWantWords
            NSMutableArray *guessYouWantWords = [NSMutableArray new]; // 数组里面3个字典
            [model.detail enumerateObjectsUsingBlock:^(FHHomeRollDataDataDetailModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *temp = [NSMutableDictionary new];
                temp[@"text"] = obj.text ?: @"";
                temp[@"guess_search_id"] = obj.guessSearchId ?: @"";
                temp[@"house_type"] = obj.houseType ?: @"";
                temp[@"open_url"] = obj.openUrl ?: @"";
                [guessYouWantWords addObject:temp];
            }];
            if (guessYouWantWords.count > 0) {
                infos[@"guess_you_want_words"] = guessYouWantWords;
            }
        }
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
    if (kIsNSArray(searchTitles)) {
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
    } else {
        self.categoryBgView.hidden = YES;
        self.categoryPlaceholderLabel.hidden = NO;
    }
}

@end
