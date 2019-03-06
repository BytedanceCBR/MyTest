//
//  ExploreLastReadCellView.m
//  Article
//
//  Created by 王双华 on 16/7/26.
//
//

#import "ExploreLastReadCellView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "LastRead.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"
//#import "WDLastReadCellData.h"
#import "SSCommonLogic.h"

#define kLastReadCellHeightForiPad           44
#define kLastReadCellHeightForiPhone6        40
#define kLastReadCellHeightForiPhone6Plus    40
#define kLastReadCellHeightForOthers         36

#define SecondsInOneMin     60
#define SecondsInOneHour    (60 * 60)
#define SecondsInOneDay     (24 * 60 * 60)

@interface ExploreLastReadCellView()
@property (nonatomic, strong) ExploreOrderedData *orderData;
@property (nonatomic, strong) UIButton *durationButton;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) SSThemedImageView *refreshIcon;
@property (nonatomic, strong) SSThemedView *backgroundView;

@property (nonatomic, copy)NSString *dateShowString;
@property (nonatomic, copy)NSString *dateSuffix;
@property (nonatomic, strong)NSNumber *showRefresh;
@property (nonatomic, strong)NSDate *lastDate;

@property (nonatomic, strong) CALayer *topBorderLayer;
@property (nonatomic, strong) CALayer *bottomBorderLayer;
@property (nonatomic, strong) CALayer *leftBorderLayer;
@property (nonatomic, strong) CALayer *rightBorderLayer;

@property (nonatomic, assign) BOOL showRefreshHistoryGuide;
@end

@implementation ExploreLastReadCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    
    if (![SSCommonLogic feedLastReadCellShowEnable] && ![SSCommonLogic showRefreshHistoryTip]) {
        return 0.f;
    }
    
//    if ([data isKindOfClass:[WDLastReadCellData class]]) {
//        WDLastReadCellData *model = (WDLastReadCellData *)data;
//        data = [ExploreOrderedData objectWithDictionary:[model toDictionary]];
//    }
    
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderData = (ExploreOrderedData *)data;
        if (orderData.nextCellType == ExploreOrderedDataCellTypeNull || orderData.preCellType == ExploreOrderedDataCellTypeNull) {
            return 0.f;
        }
        else{
            if ([TTDeviceHelper isPadDevice]){
                return kLastReadCellHeightForiPad;
            }
            else if ([TTDeviceHelper is736Screen]) {
                return kLastReadCellHeightForiPhone6Plus;
            }
            else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]){
                return kLastReadCellHeightForiPhone6;
            }
            else{
                return kLastReadCellHeightForOthers;
            }
        }
    }
    return 0.f;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _durationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_durationButton setBackgroundColor:[UIColor clearColor]];
        if ([TTDeviceHelper isPadDevice]) {
            _durationButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        }
        else if ([TTDeviceHelper is736Screen]) {
            _durationButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        }
        else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]){
            _durationButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        }
        else{
            _durationButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        }
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setBackgroundColor:[UIColor clearColor]];
        _refreshButton.titleLabel.font = _durationButton.titleLabel.font;
        
        _durationButton.userInteractionEnabled = NO;
        _refreshButton.userInteractionEnabled = NO;
        
        _refreshIcon = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        
        _topBorderLayer = [[CALayer alloc] init];
        _bottomBorderLayer = [[CALayer alloc] init];
        if ([TTDeviceHelper isPadDevice]) {
            _leftBorderLayer = [[CALayer alloc] init];
            _rightBorderLayer = [[CALayer alloc] init];
            [self.layer addSublayer:_leftBorderLayer];
            [self.layer addSublayer:_rightBorderLayer];
        }
        
        _backgroundView = [[SSThemedView alloc] init];
        
        [self addSubview:_backgroundView];
        [self addSubview:_durationButton];
        [self addSubview:_refreshButton];
        [self addSubview:_refreshIcon];
        
        [self sendSubviewToBack:_backgroundView];
        
        [self.layer addSublayer:_topBorderLayer];
        [self.layer addSublayer:_bottomBorderLayer];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self didLayoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self didLayoutSubviews];
}

- (void)didLayoutSubviews
{
    [self.durationButton setTitle:self.dateShowString forState:UIControlStateNormal];
    [self.durationButton sizeToFit];
    
    [self.refreshButton setTitle:self.dateSuffix forState:UIControlStateNormal];
    [self.refreshButton sizeToFit];
    
    _refreshIcon.imageName = @"refresh_lasttime_textpage";
    [self.refreshIcon sizeToFit];
    
    self.backgroundView.frame = self.bounds;
    
    if ([self.showRefresh boolValue] || self.showRefreshHistoryGuide) {
        if (self.showRefreshHistoryGuide) {
            [self.durationButton setTitleColor:SSGetThemedColorWithKey(kFHColorRed3) forState:UIControlStateNormal];
            [self.refreshButton setTitleColor:SSGetThemedColorWithKey(kFHColorRed3) forState:UIControlStateNormal];
            _refreshButton.hidden = NO;
            CGFloat imageGap = 2;
            CGFloat textWholeWidth = self.refreshButton.width + imageGap + self.refreshIcon.width;
            self.durationButton.frame = CGRectZero;
            self.refreshButton.frame = CGRectMake((self.width - textWholeWidth)/2, (self.height - self.refreshButton.height)/2, self.refreshButton.width, self.refreshButton.height);
            self.refreshIcon.frame = CGRectMake(self.refreshButton.right + imageGap, (self.height - self.refreshIcon.height)/2, self.refreshIcon.width, self.refreshIcon.height);
            self.refreshButton.hidden = NO;
            self.refreshIcon.hidden = NO;
            
            _refreshIcon.imageName = @"refresh_lasttime_textpage";
            self.backgroundView.backgroundColor = SSGetThemedColorWithKey(kFHColorPaleGrey);
        } else {
            [self.durationButton setTitleColor:SSGetThemedColorWithKey(kFHColorRed3) forState:UIControlStateNormal];
            [self.refreshButton setTitleColor:SSGetThemedColorWithKey(kFHColorRed3) forState:UIControlStateNormal];
            _refreshButton.hidden = NO;
            CGFloat labelGap = 10;
            CGFloat imageGap = 4;
            CGFloat textWholeWidth = self.durationButton.width + labelGap + self.refreshButton.width + imageGap + self.refreshIcon.width;
            self.durationButton.frame = CGRectMake((self.width - textWholeWidth)/2, (self.height - self.durationButton.height)/2, self.durationButton.width, self.durationButton.height);
            self.refreshButton.frame = CGRectMake(self.durationButton.right + labelGap, (self.height - self.refreshButton.height)/2, self.refreshButton.width, self.refreshButton.height);
            self.refreshIcon.frame = CGRectMake(self.refreshButton.right + imageGap, (self.height - self.refreshIcon.height)/2, self.refreshIcon.width, self.refreshIcon.height);
            self.refreshButton.hidden = NO;
            self.refreshIcon.hidden = NO;
            
            _refreshIcon.imageName = @"refresh_lasttime_textpage";
            self.backgroundView.backgroundColor = SSGetThemedColorWithKey(kFHColorPaleGrey);
        }
    }
    else {
        [self.durationButton setTitleColor:SSGetThemedColorWithKey(kFHColorRed3) forState:UIControlStateNormal];
        _refreshButton.hidden = YES;
        self.durationButton.center = CGPointMake(self.width/2, self.height/2);
        self.refreshButton.hidden = YES;
        self.refreshIcon.hidden = YES;
        self.backgroundView.backgroundColor = SSGetThemedColorWithKey(kFHColorPaleGrey);
    }
    
    self.topBorderLayer.frame = CGRectMake(0, 0, self.bounds.size.width, [TTDeviceHelper ssOnePixel]);
    self.topBorderLayer.backgroundColor = [SSGetThemedColorWithKey(kFHColorSilver2) CGColor];
    
    self.bottomBorderLayer.frame = CGRectMake(0, self.bounds.size.height - [TTDeviceHelper ssOnePixel], self.bounds.size.width, [TTDeviceHelper ssOnePixel]);
    
    if ([TTDeviceHelper isPadDevice]) {
        self.topBorderLayer.backgroundColor = [SSGetThemedColorWithKey(kFHColorSilver2) CGColor];
        self.topBorderLayer.frame = CGRectMake(0, 0, self.bounds.size.width, [TTDeviceHelper ssOnePixel]);
        
        self.bottomBorderLayer.frame = CGRectMake(0, self.bounds.size.height - [TTDeviceHelper ssOnePixel], self.bounds.size.width, [TTDeviceHelper ssOnePixel]);
        self.leftBorderLayer.frame = CGRectMake(0, [TTDeviceHelper ssOnePixel], [TTDeviceHelper ssOnePixel], self.bounds.size.height - [TTDeviceHelper ssOnePixel]);
        self.leftBorderLayer.backgroundColor = [self.topBorderLayer backgroundColor];
        
        self.rightBorderLayer.frame = CGRectMake(self.bounds.size.width - [TTDeviceHelper ssOnePixel], [TTDeviceHelper ssOnePixel] , [TTDeviceHelper ssOnePixel], self.bounds.size.height - [TTDeviceHelper ssOnePixel]);
        self.rightBorderLayer.backgroundColor = [self.topBorderLayer backgroundColor];
    }
    self.bottomBorderLayer.backgroundColor = [self.topBorderLayer backgroundColor];
    
    self.backgroundColor = SSGetThemedColorWithKey(kFHColorPaleGrey);
}

- (void)refreshWithData:(id)data {
    
    if ([SSCommonLogic feedRefreshClearAllEnable] && [SSCommonLogic showRefreshHistoryTip]) {
        self.showRefreshHistoryGuide = YES;
    } else {
        self.showRefreshHistoryGuide = NO;
    }
    
//    if ([data isKindOfClass:[WDLastReadCellData class]]) {
//        WDLastReadCellData *model = (WDLastReadCellData *)data;
//        data = [ExploreOrderedData objectWithDictionary:[model toDictionary]];
//        self.showRefreshHistoryGuide = NO;
//    }
    
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderData = data;
    } else {
        self.orderData = nil;
        return;
    }
    
    LastRead *lastRead = (LastRead *)self.orderData.originalData;
    if (!lastRead) {
        return;
    }
    else{
        if (self.showRefreshHistoryGuide) {
            self.dateShowString = @"";
            self.dateSuffix = @"浏览过的内容在这看";
        } else {
            self.showRefresh = lastRead.showRefresh;
            self.lastDate = lastRead.lastDate;
            self.dateSuffix = @"点击刷新";
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.lastDate];
            
            if (interval < 10 * SecondsInOneMin) {
                self.dateShowString = @"刚刚看到这里";
            }
            else if (interval < SecondsInOneHour) {
                self.dateShowString = [NSString stringWithFormat:@"%d分钟前看到这里", (int)interval / SecondsInOneMin];
            }
            else if (interval < SecondsInOneDay) {
                self.dateShowString = [NSString stringWithFormat:@"%d小时前看到这里", (int)interval / SecondsInOneHour];
            }
            else {
                self.dateShowString = @"以下为24小时前的文章";
                self.dateSuffix = @"点击查看更新";
            }
        }
    }
    [self didLayoutSubviews];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3Highlighted);
    }
    else {
        self.backgroundView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
    }
}
@end
