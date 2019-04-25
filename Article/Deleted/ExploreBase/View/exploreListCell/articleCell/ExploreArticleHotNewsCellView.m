//
//  ExploreArticleHotNewsCellView.m
//  Article
//
//  Created by Sunhaiyuan on 2018/1/29.
//

#import "ExploreArticleHotNewsCellView.h"
#import "ExploreOriginalData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTUISettingHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceHelper.h"
#import "NSString-Extension.h"

@interface ExploreArticleHotNewsCellView()
@property (nonatomic, strong) TTImageView   *sourceIconImageView;
@property (nonatomic, strong) UIView        *circleView;
@property (nonatomic, strong) UIView        *greyView;
@end

@implementation ExploreArticleHotNewsCellView {
    CAShapeLayer *_circleLayer;
    CAShapeLayer *_greyLayer;
}
#pragma mark - init UI
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name: TTThemeManagerThemeModeChangedNotification object:nil];
        [self addSubview:self.sourceIconImageView];
        [self addSubview:self.circleView];
        [self addSubview:self.greyView];
        [self.circleView.layer addSublayer: [self circleLayer]];
        [self.greyView.layer addSublayer:[self greyLayer]];
    }
    return self;
}

- (UIView *)circleView {
    if (!_circleView) {
        _circleView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _circleView;
}

- (UIView *)greyView {
    if (!_greyView) {
        _greyView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _greyView;
}

- (CAShapeLayer *)circleLayer {

    if (!_circleLayer) {
        _circleLayer = [[CAShapeLayer alloc] init];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(2.5, 2.5) radius:2.5 startAngle:0 endAngle:180.f clockwise:YES];
        _circleLayer.path = path.CGPath;
    }
    return _circleLayer;
}

- (CAShapeLayer *)greyLayer {
    if (!_greyLayer) {
        _greyLayer = [[CAShapeLayer alloc] init];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(9.f, 9.f) radius:9.f startAngle:0 endAngle:180.f clockwise:YES];
        _greyLayer.path = path.CGPath;
    }
    return _greyLayer;
}

- (TTImageView *)sourceIconImageView {
    if (!_sourceIconImageView) {
        _sourceIconImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _sourceIconImageView.dayModeCoverHexString = @"00000026";
        [self addSubview:_sourceIconImageView];
    }
    return _sourceIconImageView;
}

- (NSString *)avatarSourceWithArticle:(Article *)article {
    NSDictionary *mediaInfo = article.mediaInfo;
    NSDictionary *userInfo = article.userInfo;
    
    if (!isEmptyString([mediaInfo tt_stringValueForKey:@"avatar_url"])) {
        return [mediaInfo tt_stringValueForKey:@"avatar_url"];
    } else if (!isEmptyString(article.sourceAvatar)) {
        return article.sourceAvatar;
    } else {
        return [userInfo tt_stringValueForKey:@"avatar_url"];
    }
}


+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    CGFloat height = 0;
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        CGFloat containerWidth = 0;
        
        if (!orderedData || !orderedData.article || isEmptyString(orderedData.article.title)) { return 0; }
        
        if ([orderedData isHotNewsCellWithRedDot]) {
            //小红点
            containerWidth = width - 35.f - cellRightPadding();
        } else if ([orderedData isHotNewsCellWithAvatar]){
            //source_avatar
            containerWidth = width - 43.f - cellRightPadding();
        } else {
            return height;
        }
        
        CGFloat titleHeight = [orderedData.article.title tt_sizeWithMaxWidth:containerWidth font:[TTDeviceHelper isPadDevice]? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] :[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine].height;
        //13.f padding to top and bottom
        height = 26.f + titleHeight;
    }
    return height;
}


#pragma mark - refresh UI
- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if (self.orderedData && self.orderedData.managedObjectContext) {
        Article *article = self.orderedData.article;
        if (article && article.managedObjectContext) {
            [self updateTitleLabel];
        } else {
            self.typeLabel.height = 0;
            self.titleLabel.height = 0;
        }
    }
}

- (void)refreshUI {
    CGFloat x = 0;
    Article *article = self.orderedData.article;
    [self hideTimeLabel];
    self.sourceLabel.hidden = YES;
    self.typeLabel.hidden = YES;
    self.logoIcon.hidden = YES;
    self.abstractLabel.hidden = YES;
    self.infoBarView.hidden = YES;
    self.circleView.hidden = YES;
    self.sourceIconImageView.hidden = YES;
    self.greyView.hidden = YES;

    if (self.showRedDot) {
        //展示小红点
        self.circleView.hidden = NO;
        [self updateCircleView];
        self.circleView.frame = CGRectMake(20.f, 0, 5.f, 5.f);
        self.circleView.centerY = self.height * 0.5;
        x = 35.f;
    } else {
        if (!isEmptyString([self avatarSourceWithArticle:article])) {
            //展示头像
            self.sourceIconImageView.hidden = NO;
            [self.sourceIconImageView setImageWithURLString:[self avatarSourceWithArticle:article]];
            self.sourceIconImageView.frame = CGRectMake(0, 0, 18.f, 18.f);
            self.sourceIconImageView.left = cellLeftPadding();
            self.sourceIconImageView.layer.cornerRadius = 9.f;
            self.sourceIconImageView.clipsToBounds = YES;
        } else {
            //展示灰色块
            self.greyView.hidden = NO;
            self.greyView.frame = CGRectMake(0, 0, 18.f, 18.f);
            self.greyView.left = cellLeftPadding();
            [self updateGreyView];
        }
        x = 43.f;
    }
    
    self.titleLabel.frame = CGRectMake(x, 0, self.width - cellRightPadding() - x, kCellTitleLineHeight);
    self.titleLabel.text = article.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.centerY = self.height * 0.5;
    self.titleLabel.width = self.width - cellRightPadding() - x;
    self.bottomLineView.frame = CGRectMake(kCellLeftPadding, self.frame.size.height-[TTDeviceHelper ssOnePixel], self.frame.size.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
    
    if (!self.circleView.hidden) {
        self.circleView.centerY = 13.f + [self labelHeightForOneRowWithContainerWidth:self.titleLabel.width] * 0.5;
    }
    
    if (!self.sourceIconImageView.hidden) {
        self.sourceIconImageView.centerY = 13.f + [self labelHeightForOneRowWithContainerWidth:self.titleLabel.width] * 0.5;
    }
    
    if (!self.greyView.hidden) {
        self.greyView.centerY = 13.f + [self labelHeightForOneRowWithContainerWidth:self.titleLabel.width] * 0.5;
    }
}

#pragma mark - privates
- (CGFloat)labelHeightForOneRowWithContainerWidth:(CGFloat)containerWidth {
    NSString *string = @"单行测试";
    return [string tt_sizeWithMaxWidth:containerWidth font:[TTDeviceHelper isPadDevice]? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] :[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine].height;
}

- (void)updateCircleView {
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        _circleLayer.fillColor = [UIColor colorWithHexString:@"f85959"].CGColor;
    } else {
        _circleLayer.fillColor = [UIColor colorWithHexString:@"935656"].CGColor;
    }
}

- (void)updateGreyView {
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        _greyLayer.fillColor = [UIColor colorWithHexString:@"e8e8e8"].CGColor;
    } else {
        _greyLayer.fillColor = [UIColor colorWithHexString:@"464646"].CGColor;
    }
}



#pragma mark - notifications
- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.titleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.titleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    [self updateCircleView];
    [self updateGreyView];
    
}

@end
