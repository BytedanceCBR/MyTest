//
//  TTArticleCardCellViewHeaderView.m
//  Article
//
//  Created by 王双华 on 16/4/21.
//
//

#import "TTArticleCardCellViewHeaderView.h"
#import "SSThemed.h"
#import "TTImageView.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreAvatarView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Card+CoreDataClass.h"
#import "TTThreadRateView.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "TTArticleSearchManager.h"
#import "TTSearchHomeSugModel.h"
#import "TTRoute.h"
#import "TTTintThemeButton.h"


#define kLeftPadding                15
#define kAvatarViewWidth            18
#define kAvatarViewHeight           18
#define kTitleLabelRightPadding     6
#define kTeamScoreLabelHorizonGap   3
#define kIconViewWidth              24
#define kIconViewHeight             24
#define kIconRightPadding           6
#define kIconTopPadding             8
#define kTitleLabelFontSize         16
#define kSubTitileFontSize          12
#define kScoreLabelFontSize         12
#define kTeamScoreLabelFontSize     16
#define kMoviewScoreLabelLeftPadding    3
#define kMinRightPadding            50
#define kScoreStarViewWidth         72
#define kScoreStarViewHeight        12
#define kMoviewScoreLabelWidth      18
#define kScoreVSLabelWidth          28

@interface TTArticleCardCellViewHeaderView ()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSString *iconDayUrl;
@property (nonatomic, strong) NSString *iconNightUrl;
@property (nonatomic, strong) NSString *weatherDayUrl;
@property (nonatomic, strong) NSString *weatherNightUrl;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *subTitleLabel;
@property (nonatomic, strong) TTImageView *iconView;
@property (nonatomic, strong) SSThemedLabel *movieScoreLabel;
@property (nonatomic, strong) TTImageView *homeTeamAvatarView;
@property (nonatomic, strong) TTImageView *visitTeamAvatarView;
@property (nonatomic, strong) SSThemedLabel *scoreVSLabel;
@property (nonatomic, strong) TTImageView *imageView;
@property (nonatomic, strong) TTThreadRateView *scoreStarView;
@property (nonatomic, strong) SSThemedView *sepLineView;

@property (nonatomic, strong) TTImageView *titleView;

@property (nonatomic, strong) SSThemedLabel *titleLabelForCannotTip;
@property (nonatomic, strong) SSThemedLabel *subTitleLabelForCannnotTip;

@property (nonatomic, strong) TTImageView   *weatherIconView;
@property (nonatomic, strong) SSThemedLabel *weatherInfoLabel;

@end

@implementation TTArticleCardCellViewHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
    if (isDayMode) {
        [self.titleView setImageWithURLString:_iconDayUrl];
        [self.weatherIconView setImageWithURLString:_weatherDayUrl];
    }
    else {
        [self.titleView setImageWithURLString:_iconNightUrl];
        [self.weatherIconView setImageWithURLString:_weatherNightUrl];
    }
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.hidden = YES;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.textColorThemeKey = kColorText3;
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.font = [UIFont systemFontOfSize:kSubTitileFontSize];
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        _subTitleLabel.hidden = YES;
        [self addSubview:_subTitleLabel];
    }
    return _subTitleLabel;
}

- (SSThemedLabel *)titleLabelForCannotTip{
    if(!_titleLabelForCannotTip){
        _titleLabelForCannotTip = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabelForCannotTip.font = [UIFont systemFontOfSize:10];
        _titleLabelForCannotTip.textColorThemeKey = kColorText7;
        _titleLabelForCannotTip.backgroundColorThemeKey = kColorBackground7;
        _titleLabelForCannotTip.textAlignment = NSTextAlignmentCenter;
        _titleLabelForCannotTip.hidden = YES;
        _titleLabelForCannotTip.numberOfLines = 1;
        [self addSubview:_titleLabelForCannotTip];
    }
    return _titleLabelForCannotTip;
}

- (SSThemedLabel *)subTitleLabelForCannnotTip{
    if(!_subTitleLabelForCannnotTip){
        _subTitleLabelForCannnotTip = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _subTitleLabelForCannnotTip.font = [UIFont systemFontOfSize:12];
        _subTitleLabelForCannnotTip.textColorThemeKey = kColorText3;
        _subTitleLabelForCannnotTip.backgroundColor = [UIColor clearColor];
        _subTitleLabelForCannnotTip.textAlignment = NSTextAlignmentLeft;
        _subTitleLabelForCannnotTip.hidden = YES;
        _subTitleLabelForCannnotTip.lineBreakMode = NSLineBreakByTruncatingTail;
        _subTitleLabelForCannnotTip.numberOfLines = 1;
        [self addSubview:_subTitleLabelForCannnotTip];
    }
    return _subTitleLabelForCannnotTip;
}

- (TTImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[TTImageView alloc] initWithFrame:CGRectMake(kLeftPadding, kIconTopPadding, kIconViewWidth, kIconViewHeight)];
        _iconView.enableNightCover = NO;
        _iconView.backgroundColor = [UIColor clearColor];
        _iconView.hidden = YES;
        [self addSubview:_iconView];
    }
    return _iconView;
}

- (TTImageView *)titleView
{
    if (!_titleView) {
        _titleView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _titleView.enableNightCover = NO;
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.hidden = YES;
        _titleView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_titleView];
    }
    return _titleView;
}

- (TTThreadRateView *)scoreStarView
{
    if(!_scoreStarView){
        _scoreStarView = [[TTThreadRateView alloc] initWithFrame:CGRectMake(0, 0, kScoreStarViewWidth, kScoreStarViewHeight)];
        _scoreStarView.hidden = YES;
        [self addSubview:_scoreStarView];
    }
    return _scoreStarView;
}

- (SSThemedLabel *)movieScoreLabel
{
    if (!_movieScoreLabel) {
        _movieScoreLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _movieScoreLabel.textColors = SSThemedColors(@"ffc345", @"927435");
        _movieScoreLabel.backgroundColor = [UIColor clearColor];
        _movieScoreLabel.textAlignment = NSTextAlignmentLeft;
        _movieScoreLabel.font = [UIFont systemFontOfSize:kSubTitileFontSize];
        _movieScoreLabel.hidden = YES;
        [self addSubview:_movieScoreLabel];
    }
    return _movieScoreLabel;
}

- (TTImageView *)homeTeamAvatarView
{
    if (!_homeTeamAvatarView){
        _homeTeamAvatarView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kAvatarViewWidth, kAvatarViewHeight)];
        _homeTeamAvatarView.borderColorThemeKey = kColorLine1;
        _homeTeamAvatarView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _homeTeamAvatarView.backgroundColor = [UIColor clearColor];
        _homeTeamAvatarView.layer.cornerRadius = kAvatarViewWidth / 2.0;
        _homeTeamAvatarView.hidden = YES;
        [self addSubview:_homeTeamAvatarView];
    }
    return _homeTeamAvatarView;
}

- (TTImageView *)visitTeamAvatarView
{
    if (!_visitTeamAvatarView){
        _visitTeamAvatarView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kAvatarViewWidth, kAvatarViewHeight)];
        _visitTeamAvatarView.borderColorThemeKey = kColorLine1;
        _visitTeamAvatarView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _visitTeamAvatarView.backgroundColor = [UIColor clearColor];
        _visitTeamAvatarView.layer.cornerRadius = kAvatarViewWidth / 2.0;
        _visitTeamAvatarView.hidden = YES;
        [self addSubview:_visitTeamAvatarView];
    }
    return _visitTeamAvatarView;
}

- (SSThemedLabel *)scoreVSLabel
{
    if (!_scoreVSLabel){
        _scoreVSLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _scoreVSLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _scoreVSLabel.textColorThemeKey = kColorText1;
        _scoreVSLabel.textAlignment = NSTextAlignmentLeft;
        _scoreVSLabel.hidden = YES;
        [self addSubview:_scoreVSLabel];
    }
    return _scoreVSLabel;
}

- (TTImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[TTImageView alloc] initWithFrame:CGRectMake(kLeftPadding, 0, 0, 0)];//会重新设置宽度和高度
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.hidden = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (SSThemedView *)sepLineView
{
    if (!_sepLineView){
        _sepLineView = [[SSThemedView alloc] initWithFrame:CGRectMake(kLeftPadding, 0, 0, [TTDeviceHelper ssOnePixel])];
        _sepLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_sepLineView];
    }
    return _sepLineView;
}

- (TTImageView *)weatherIconView {
    if (!_weatherIconView) {
        _weatherIconView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _weatherIconView.contentMode = UIViewContentModeScaleAspectFit;
        _weatherIconView.userInteractionEnabled = YES;
        _weatherIconView.backgroundColor = [UIColor clearColor];
        _weatherIconView.enableNightCover = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onWeatherIconClick)];
        [_weatherIconView addGestureRecognizer:tap];
        [self addSubview:_weatherIconView];
        _weatherIconView.hidden = YES;
    }
    return _weatherIconView;
}

- (SSThemedLabel *)weatherInfoLabel {
    if (!_weatherInfoLabel) {
        _weatherInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _weatherInfoLabel.textColorThemeKey = kColorText1;
        _weatherInfoLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onWeatherIconClick)];
        [_weatherInfoLabel addGestureRecognizer:tap];
        [self addSubview:_weatherInfoLabel];
        _weatherInfoLabel.hidden = YES;
    }
    return _weatherInfoLabel;
}

- (void)refreshUIWithModel:(ExploreOrderedData *)orderedData {
    self.titleLabel.hidden = YES;
    self.subTitleLabel.hidden = YES;
    self.iconView.hidden = YES;
    self.movieScoreLabel.hidden = YES;
    self.homeTeamAvatarView.hidden = YES;
    self.visitTeamAvatarView.hidden = YES;
    self.scoreVSLabel.hidden = YES;
    self.imageView.hidden = YES;
    self.scoreStarView.hidden = YES;
    self.sepLineView.hidden = NO;
    self.weatherIconView.hidden = YES;
    self.weatherInfoLabel.hidden = YES;
    self.titleLabelForCannotTip.hidden = YES;
    self.subTitleLabelForCannnotTip.hidden = YES;
    self.titleView.hidden = YES;
    
    
    Card *card = orderedData.card;
    
    switch ([card.cardType intValue]) {
        case 1:
            [self refreshUIForTypeDefaultWithModel:card];
            break;
        case 2:
            [self refreshUIForTypeMovieScoreWithModel:card];
            break;
        case 3:
            [self refreshUIForTypeMatchWithModel:card];
            break;
        case 4:
            [self refreshUIForTypeImageWithModel:card];
            break;
        case 5:
            [self refreshUIForTypeCannotTipWithModel:card];
            break;
        case 6: //热点要闻 header view
            [self refreshUIForTypeHotNewsWithModel:card];
        default:
            break;
    }
    self.sepLineView.frame = CGRectMake(kLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - 2 * kLeftPadding, [TTDeviceHelper ssOnePixel]);
}
//默认样式
- (void)refreshUIForTypeDefaultWithModel:(Card *)model{
    if (!isEmptyString(model.cardDayIcon) && !isEmptyString(model.cardNightIcon)) {
        //图加主标题
        self.iconDayUrl = [NSString stringWithString:model.cardDayIcon];
        self.iconNightUrl = [NSString stringWithString:model.cardNightIcon];
        BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
        if (self.iconDayUrl && isDayMode) {
            [self.iconView setImageWithURLString:_iconDayUrl];
        }
        else if (self.iconNightUrl && !isDayMode){
            [self.iconView setImageWithURLString:_iconNightUrl];
        }
        self.iconView.hidden = NO;
        
        [self.titleLabel setText:model.cardTitle];
        CGSize size = [_titleLabel sizeThatFits:CGSizeZero];
        CGFloat maxWidth = self.width - kLeftPadding - kIconViewWidth - kIconRightPadding - kMinRightPadding;
        _titleLabel.frame = CGRectMake(kLeftPadding  + kIconViewWidth + kIconRightPadding, (self.height - size.height) / 2, maxWidth, size.height);
        _titleLabel.hidden = NO;
    }
    else{
        //主标题加次标题
        [self.titleLabel setText:model.titlePrefix];
        CGSize size = [_titleLabel sizeThatFits:CGSizeZero];
        CGFloat maxWidth = self.width - kLeftPadding - kMinRightPadding;
        if (!isEmptyString(model.cardTitle)) {
            _titleLabel.frame = CGRectMake(kLeftPadding, (self.height - size.height) / 2, size.width, size.height);
        }
        else{
            _titleLabel.frame = CGRectMake(kLeftPadding, (self.height - size.height) / 2, maxWidth, size.height);
        }
        _titleLabel.hidden = NO;
        
        if (!isEmptyString(model.titlePrefix) && !isEmptyString(model.cardTitle)){
            [self.subTitleLabel setText:model.cardTitle];
            CGSize subSize = [_subTitleLabel sizeThatFits:CGSizeZero];
            CGFloat subMaxWidth = self.width - _titleLabel.right - kTitleLabelRightPadding - kMinRightPadding;
            _subTitleLabel.frame = CGRectMake(_titleLabel.right + kTitleLabelRightPadding, (self.height - subSize.height) / 2, subMaxWidth, subSize.height);
            _subTitleLabel.hidden = NO;
        }
    }
}
//电影样式
- (void)refreshUIForTypeMovieScoreWithModel:(Card *)model{
    [self.titleLabel setText:model.cardTitle];
    CGSize size = [_titleLabel sizeThatFits:CGSizeZero];
    CGFloat maxWidth = self.width - kLeftPadding - kTitleLabelRightPadding - kScoreStarViewWidth - kMoviewScoreLabelLeftPadding - kMoviewScoreLabelWidth - kMinRightPadding;
    maxWidth = MIN(maxWidth, size.width);
    _titleLabel.frame = CGRectMake(kLeftPadding, (self.height - size.height) / 2, maxWidth, size.height);
    _titleLabel.hidden = NO;
    
    float score = model.headInfoModel.score;
    score = MAX((MIN(score, 10)),0);
    [self.scoreStarView setRate:roundf(score)];
    _scoreStarView.left = _titleLabel.right + kTitleLabelRightPadding;
    _scoreStarView.centerY = _titleLabel.centerY;
    _scoreStarView.hidden = NO;
    
    [self.movieScoreLabel setText:[NSString stringWithFormat:@"%.1f",score]];
    [_movieScoreLabel sizeToFit];
    _movieScoreLabel.left = _scoreStarView.right + kTeamScoreLabelHorizonGap;
    _movieScoreLabel.centerY = _titleLabel.centerY;
    _movieScoreLabel.hidden = NO;
}
//战报样式
- (void)refreshUIForTypeMatchWithModel:(Card *)model{
    [self.titleLabel setText:model.cardTitle];
    CGSize size = [_titleLabel sizeThatFits:CGSizeZero];
    CGFloat maxWidth = self.width - kLeftPadding - kTitleLabelRightPadding - 2 * kAvatarViewWidth - 2 * kTeamScoreLabelHorizonGap - kScoreVSLabelWidth - kMinRightPadding;
    maxWidth = MIN(maxWidth, size.width);
    _titleLabel.frame = CGRectMake(kLeftPadding, (self.height - size.height) / 2, maxWidth, size.height);
    _titleLabel.hidden = NO;
    
    [self.homeTeamAvatarView setImageWithURLString:model.headInfoModel.team1IconUrl];
    _homeTeamAvatarView.left = _titleLabel.right + kTitleLabelRightPadding;
    _homeTeamAvatarView.centerY = _titleLabel.centerY;
    _homeTeamAvatarView.hidden = NO;
    
    [self.scoreVSLabel setText:[NSString stringWithFormat:@"%d : %d", model.headInfoModel.team1Score , model.headInfoModel.team2Score]];
    [_scoreVSLabel sizeToFit];
    _scoreVSLabel.left = _homeTeamAvatarView.right + kTeamScoreLabelHorizonGap;
    _scoreVSLabel.centerY = _titleLabel.centerY;
    _scoreVSLabel.hidden = NO;
    
    [self.visitTeamAvatarView setImageWithURLString:model.headInfoModel.team2IconUrl];
    _visitTeamAvatarView.left = _scoreVSLabel.right + kTeamScoreLabelHorizonGap;
    _visitTeamAvatarView.centerY = _titleLabel.centerY;
    _visitTeamAvatarView.hidden = NO;
}
//大图样式
- (void)refreshUIForTypeImageWithModel:(Card *)model{
    _imageView.height = self.height;
    __weak TTImageView *weakImageView = self.imageView;
    __weak typeof(self) wself = self;
    [self.imageView setImageWithURLString:model.headInfoModel.imageUrl placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
        __strong typeof(wself) self = wself;
        if (image.size.height > 0){
            CGFloat imageWidth = image.size.width * weakImageView.height / image.size.height ;
            imageWidth = ceilf(imageWidth);
            CGFloat maxWidth = self.width - 15 - 50;
            imageWidth = MIN(imageWidth, maxWidth);
            weakImageView.width = imageWidth;
            weakImageView.hidden = NO;
        }
    } failure:nil];
}
//5.7需求 如果后端同时传头部的主副标题，但没有落地url时
- (void)refreshUIForTypeCannotTipWithModel:(Card *)model{
    //主标题加次标题
    
    [self.titleLabelForCannotTip setText:model.titlePrefix];
    [_titleLabelForCannotTip sizeToFit];
    
    _titleLabelForCannotTip.top = 14;
    _titleLabelForCannotTip.left = kLeftPadding;
    _titleLabelForCannotTip.height = 16;
    _titleLabelForCannotTip.width = _titleLabelForCannotTip.width + 6;
    _titleLabelForCannotTip.hidden = NO;
    
    [self.subTitleLabelForCannnotTip setText:model.cardTitle];
    [_subTitleLabelForCannnotTip sizeToFit];
    CGFloat subMaxWidth = self.width - _titleLabelForCannotTip.right - 5 - kMinRightPadding;
    _subTitleLabelForCannnotTip.width = MIN(subMaxWidth, _subTitleLabelForCannnotTip.width);
    _subTitleLabelForCannnotTip.left = _titleLabelForCannotTip.right + 5;
    _subTitleLabelForCannnotTip.centerY = _titleLabelForCannotTip.centerY;
    _subTitleLabelForCannnotTip.hidden = NO;
    
    self.sepLineView.hidden = YES;
}
//6.5.8 需求 热点要闻卡片样式
- (void)refreshUIForTypeHotNewsWithModel:(Card *)model {
    
    self.titleView.hidden = NO;
    self.titleView.size = CGSizeMake(71.f, 19.f);
    self.titleView.left = 15;
    self.titleView.centerY = self.height * 0.5 + 4;
    self.sepLineView.hidden = YES;
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [self.titleView setImageWithURLString:model.cardDayIcon];
    } else {
        [self.titleView setImageWithURLString:model.cardNightIcon];
    }
    self.iconDayUrl = model.cardDayIcon;
    self.iconNightUrl = model.cardNightIcon;
    
    NSDictionary *weather = model.headInfoData;
    self.weatherDayUrl = [weather tt_stringValueForKey:@"day_weather_icon"];
    self.weatherNightUrl = [weather tt_stringValueForKey:@"night_weather_icon"];
    NSString *weather_icon;
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        weather_icon = self.weatherDayUrl;
    } else {
        weather_icon = self.weatherNightUrl;
    }
    
    NSString *weather_info = [weather tt_stringValueForKey:@"weather_info"];
    if (!isEmptyString(weather_icon) && !isEmptyString(weather_info)) {
        self.weatherIconView.hidden = NO;
        self.weatherInfoLabel.hidden = NO;
        self.weatherIconView.frame = CGRectMake(self.titleView.right + 7.5, 0, 23.f, 23.f);
        self.weatherIconView.bottom = self.titleView.bottom;
        [self.weatherIconView setImageWithURLString:weather_icon];
        
        self.weatherInfoLabel.text = weather_info;
        self.weatherInfoLabel.font = [UIFont systemFontOfSize:[self weatherInfoFontSize]];
        [self.weatherInfoLabel sizeToFit];
        self.weatherInfoLabel.left = self.weatherIconView.right;
        self.weatherInfoLabel.centerY = self.weatherIconView.centerY;
    }
}

- (void)setTarget:(id)target selector:(SEL)selector {
    _target = target;
    _selector = selector;
}


#pragma mark - actions
- (void)onWeatherIconClick {
    TTSearchWeatherModel *model = [TTArticleSearchManager cachedWeatherModel];
    if (!model || isEmptyString(model.city_name) || isEmptyString(model.current_condition)) { return; }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *keyword = [NSString stringWithFormat:@"%@天气", model.city_name];
    [params setValue:@"weather_click" forKey:@"click"];
    [params setValue:model.current_condition forKey:@"type"];
    [TTTrackerWrapper eventV3:@"feed_search_weather" params:params];
    NSString *keywordEscape = [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *openURL = [NSString stringWithFormat:@"sslocal://search?keyword=%@", keywordEscape];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openURL]];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognize {
    if (_target && [_target respondsToSelector:_selector])  {
        NSMethodSignature *signature = [_target methodSignatureForSelector:_selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:_target];
        [invocation setSelector:_selector];
        [invocation invoke];
    }
}


#pragma mark - privates
- (CGFloat)weatherInfoFontSize {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 13.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 12.f;
    } else {
        fontSize = 10.f;
    }
    return fontSize;
}

@end

