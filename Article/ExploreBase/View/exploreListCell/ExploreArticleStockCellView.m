//
//  ExploreArticleStockCellView.m
//  Article
//
//  Created by 王双华 on 16/4/22.
//
//

#import "ExploreArticleStockCellView.h"
#import "SSThemed.h"
#import "StockData.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreOriginalData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreStockCellManager.h"
#import "TTDeviceHelper.h"
#import "TTRoute.h"

#define kSepLineHorizonGap          ([TTDeviceHelper isPadDevice] ? 19.5 : 15.)
#define kNameAndIDVerticalGap       ([TTDeviceHelper isPadDevice] ? 5 : 4)
#define kStatusAndTimeVerticalGap   ([TTDeviceHelper isPadDevice] ? 3 : 2)



@interface ExploreArticleStockCellView()
@property (nonatomic, strong) SSThemedLabel *stockNameLabel;
@property (nonatomic, strong) SSThemedLabel *stockIDLabel;
@property (nonatomic, strong) SSThemedView *leftSepLineView;
@property (nonatomic, strong) SSThemedImageView *stockStatusImageView;
@property (nonatomic, strong) SSThemedLabel *stockPriceLabel;
@property (nonatomic, strong) SSThemedLabel *changeAmountLabel;
@property (nonatomic, strong) SSThemedLabel *changeScaleLabel;
@property (nonatomic, strong) SSThemedView *rightSepLineView;
@property (nonatomic, strong) SSThemedLabel *tradingStatusLabel;
@property (nonatomic, strong) SSThemedLabel *lastUpdateTimeLabel;

@property (nonatomic, strong) NSNumber *stockStatus;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isCellDisplay;

//@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) StockData *stockData;
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation ExploreArticleStockCellView{
    CGFloat _cellHeight;
    CGFloat _cellTopPadding;
    CGFloat _cellBotPadding;
    CGFloat _sepLineHeight;
    CGFloat _priceAndAmountHorizonGap;
    CGFloat _amountAndScaleHorizonGap;
    CGFloat _stockNameLabelFontSize;
    CGFloat _stockIDLabelFontSize;
    CGFloat _stockPriceLabelFontSize;
    CGFloat _changeAmountLabelFontSize;
    CGFloat _changeScaleLabelFontSize;
    CGFloat _tradingStatusLabelFontSize;
    CGFloat _lastUpdateTimeLabelFontSize;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        StockData *stockData = orderedData.stockData;
        if (stockData) {
            if([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]){//4/4s/5/s
                return 58.f;
            }
            else if ([TTDeviceHelper isPadDevice]){//ipad
                return 88.f; // = 68 * 1.3
            }
            else{//6/6p/6s/6splus
                return 68.f;
            }
        }
    }
    return 0.f;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame{
    if([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]){//4/4s/5/s
        _cellTopPadding = 14;
        _cellBotPadding = 14;
        _sepLineHeight = 30;
        _priceAndAmountHorizonGap = 6;
        _amountAndScaleHorizonGap = 3;
        _stockNameLabelFontSize = 17.f;
        _stockIDLabelFontSize = 10.f;
        _stockPriceLabelFontSize = 17.f;
        _changeAmountLabelFontSize = 10.f;
        _changeScaleLabelFontSize = 10.f;
        _lastUpdateTimeLabelFontSize = 9.f;
        _tradingStatusLabelFontSize = 10.f;
        _cellHeight = _cellTopPadding + _sepLineHeight + _cellBotPadding;
    }
    else if ([TTDeviceHelper isPadDevice]){//ipad 尺寸是6/6p的1.3倍
        _cellTopPadding = 21;
        _cellBotPadding = 21;
        _sepLineHeight = 27;
        _priceAndAmountHorizonGap = 18;
        _amountAndScaleHorizonGap = 5;
        _stockNameLabelFontSize = 24.f;
        _stockIDLabelFontSize = 14.f;
        _stockPriceLabelFontSize = 24.f;
        _changeAmountLabelFontSize = 16.f;
        _changeScaleLabelFontSize = 16.f;
        _lastUpdateTimeLabelFontSize = 14.f;
        _tradingStatusLabelFontSize = 12.f;
        _cellHeight = _cellTopPadding + _sepLineHeight + _cellBotPadding;
    }
    else{//6/6p/6s/6splus
        _cellTopPadding = 16;
        _cellBotPadding = 16;
        _sepLineHeight = 36;
        if ([TTDeviceHelper is736Screen]) {
            _priceAndAmountHorizonGap = 20;
        }
        else{
            _priceAndAmountHorizonGap = 10;
        }
        _amountAndScaleHorizonGap = 4;
        _stockNameLabelFontSize = 19.f;
        _stockIDLabelFontSize = 12.f;
        _stockPriceLabelFontSize = 19.f;
        _changeAmountLabelFontSize = 14.f;
        _changeScaleLabelFontSize = 14.f;
        _lastUpdateTimeLabelFontSize = 12.f;
        _tradingStatusLabelFontSize = 10.f;
        _cellHeight = _cellTopPadding + _sepLineHeight + _cellBotPadding;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.stockNameLabel = [[SSThemedLabel alloc] init];
        _stockNameLabel.font = [UIFont systemFontOfSize:_stockNameLabelFontSize];
        _stockNameLabel.textColorThemeKey = kColorText1;
        [self addSubview:_stockNameLabel];
        
        self.stockIDLabel = [[SSThemedLabel alloc] init];
        _stockIDLabel.font = [UIFont systemFontOfSize:_stockIDLabelFontSize];
        _stockIDLabel.textColorThemeKey = kColorText1;
        [self addSubview:_stockIDLabel];
        
        self.leftSepLineView = [[SSThemedView alloc] init];
        _leftSepLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_leftSepLineView];
        
        self.stockStatusImageView = [[SSThemedImageView alloc] init];
        [self addSubview:_stockStatusImageView];
        
        self.stockPriceLabel = [[SSThemedLabel alloc] init];
        _stockPriceLabel.font = [UIFont systemFontOfSize:_stockPriceLabelFontSize];
        [self addSubview:_stockPriceLabel];
        
        self.changeAmountLabel = [[SSThemedLabel alloc] init];
        _changeAmountLabel.font = [UIFont systemFontOfSize:_changeAmountLabelFontSize];
        [self addSubview:_changeAmountLabel];
        
        self.changeScaleLabel = [[SSThemedLabel alloc] init];
        _changeScaleLabel.font = [UIFont systemFontOfSize:_changeScaleLabelFontSize];
        [self addSubview:_changeScaleLabel];
        
        self.rightSepLineView = [[SSThemedView alloc] init];
        _rightSepLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_rightSepLineView];
        
        self.tradingStatusLabel = [[SSThemedLabel alloc] init];
        _tradingStatusLabel.font = [UIFont systemFontOfSize:_tradingStatusLabelFontSize];
        _tradingStatusLabel.textColorThemeKey = kColorText1;
        [self addSubview:_tradingStatusLabel];
        
        self.lastUpdateTimeLabel = [[SSThemedLabel alloc] init];
        _lastUpdateTimeLabel.font = [UIFont systemFontOfSize:_lastUpdateTimeLabelFontSize];
        _lastUpdateTimeLabel.textColorThemeKey = kColorText1;
        [self addSubview:_lastUpdateTimeLabel];
        
        [self reloadThemeUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)refreshUI {
    // 左边部分
    CGFloat nameLabelWidth = _stockNameLabel.width;
    CGFloat nameLabelHeight = _stockNameLabel.height;
    
    CGFloat idLabelWidth = _stockIDLabel.width;
    CGFloat idLabelHeight = _stockIDLabel.height;
    
    CGFloat maxWidthOfNameLabelAndIDlabel = nameLabelWidth > idLabelWidth ? nameLabelWidth : idLabelWidth;
    CGFloat nameLabelTopPadding = (_cellHeight - nameLabelHeight - idLabelHeight - kNameAndIDVerticalGap) / 2;
    CGFloat leftSepLineViewOriginX = maxWidthOfNameLabelAndIDlabel + kSepLineHorizonGap + kCellLeftPadding;
    _stockNameLabel.centerX = leftSepLineViewOriginX / 2;
    _stockIDLabel.centerX = leftSepLineViewOriginX / 2;
    _stockNameLabel.top = nameLabelTopPadding;
    _stockIDLabel.top = nameLabelTopPadding + nameLabelHeight + kNameAndIDVerticalGap;
    _leftSepLineView.frame = CGRectMake(leftSepLineViewOriginX, _cellTopPadding, [TTDeviceHelper ssOnePixel], _sepLineHeight);
    
    //右边部分
    CGFloat statusLabelWidth = _tradingStatusLabel.width;
    CGFloat statusLabelHeight = _tradingStatusLabel.height;
    
    CGFloat timeLabelWidth = _lastUpdateTimeLabel.width;
    CGFloat timeLabelHeight = _lastUpdateTimeLabel.height;
    
    CGFloat maxWidthOfStatusLabelAndTimeLabel = statusLabelWidth > timeLabelWidth ? statusLabelWidth : timeLabelWidth;
    
    CGFloat statusLabelTopPadding = (_cellHeight - statusLabelHeight - timeLabelHeight - kStatusAndTimeVerticalGap) / 2;
    CGFloat rightSepLineViewOriginX = self.width - maxWidthOfStatusLabelAndTimeLabel - kCellRightPadding - kSepLineHorizonGap;
    _tradingStatusLabel.centerX = (rightSepLineViewOriginX + self.width) / 2;
    _lastUpdateTimeLabel.centerX = (rightSepLineViewOriginX + self.width) / 2;
    _tradingStatusLabel.top = statusLabelTopPadding;
    _lastUpdateTimeLabel.top = statusLabelTopPadding + statusLabelHeight + kStatusAndTimeVerticalGap;
    _rightSepLineView.frame = CGRectMake(rightSepLineViewOriginX - [TTDeviceHelper ssOnePixel], _cellTopPadding,[TTDeviceHelper ssOnePixel], _sepLineHeight);
    
    //中间部分
    if ([_stockStatus intValue] == 1) {//股票涨
        [_stockPriceLabel setTextColor:[UIColor tt_themedColorForKey:kColorText4]];
        [_changeAmountLabel setTextColor:[UIColor tt_themedColorForKey:kColorText4]];
        [_changeScaleLabel setTextColor:[UIColor tt_themedColorForKey:kColorText4]];
        _stockStatusImageView.imageName = @"finance_up";
    }
    else if([_stockStatus intValue] == 2){//股票跌
        [_stockPriceLabel setTextColor:[UIColor colorWithDayColorName:@"41BE70" nightColorName:@"397D52"]];
        [_changeAmountLabel setTextColor:[UIColor colorWithDayColorName:@"41BE70" nightColorName:@"397D52"]];
        [_changeScaleLabel setTextColor:[UIColor colorWithDayColorName:@"41BE70" nightColorName:@"397D52"]];
        _stockStatusImageView.imageName = @"finance_down";
    }
    [_stockStatusImageView sizeToFit];
    
    CGFloat stockStatusImageViewWidth = _stockStatusImageView.width;
    CGFloat stockPriceLabelWidth = _stockPriceLabel.width;
    CGFloat changeAmountLabelWidth = _changeAmountLabel.width;
    CGFloat changeScaleLabelWidth = _changeScaleLabel.width;
    
    CGFloat width = stockStatusImageViewWidth + stockPriceLabelWidth + _priceAndAmountHorizonGap + changeAmountLabelWidth + _amountAndScaleHorizonGap + changeScaleLabelWidth ;
    CGFloat stockStatusImageViewOriginX = leftSepLineViewOriginX + (rightSepLineViewOriginX - leftSepLineViewOriginX - [TTDeviceHelper ssOnePixel] - width) / 2;
    CGFloat centerY = self.height / 2;
    
    _stockStatusImageView.left = stockStatusImageViewOriginX;
    _stockStatusImageView.centerY = centerY;
    
    _stockPriceLabel.left = stockStatusImageViewOriginX + stockStatusImageViewWidth;
    _stockPriceLabel.centerY = centerY;
    
    _changeAmountLabel.left = stockStatusImageViewOriginX + stockStatusImageViewWidth + stockPriceLabelWidth + _priceAndAmountHorizonGap;
    _changeAmountLabel.centerY = centerY;
    
    
    _changeScaleLabel.left = stockStatusImageViewOriginX + stockStatusImageViewWidth + stockPriceLabelWidth + _priceAndAmountHorizonGap + changeAmountLabelWidth + _amountAndScaleHorizonGap;
    _changeScaleLabel.centerY = centerY;
    
    [self layoutBottomLine];
}

#pragma mark - shouldRefresh
- (BOOL)shouldRefresh{
    return YES;
}

#pragma mark - refreshData
- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
        self.stockData =  self.orderedData.stockData;
        self.stockData.shouldStopUpdate = NO;
        if (!self.stockData.shouldReloadCell) {// 第一次刷出数据
            self.lastUpdateTime = [NSDate date];
            self.stockData.shouldReloadCell = YES;
        }
        self.refreshInterval = [self.stockData.refreshInterval doubleValue];
        [self updateStockCellWithStockData:_stockData];
    } else {
        self.orderedData = nil;
    }
    
    _isCellDisplay = YES;
    
    wrapperTrackEventWithCustomKeys(@"native_stock", @"show", nil, nil, @{@"stock_id": [NSString stringWithFormat:@"%@", _stockData.stockID]});
    
    [self refreshStockData];
}

- (void)refreshStockData {
    if (_isLoading) {
        return;
    }
    
    if (self.stockData == nil) {
        return;
    }
    
    if (self.lastUpdateTime && self.refreshInterval && fabs([self.lastUpdateTime timeIntervalSinceNow]) < self.refreshInterval){//这次刷新时间与上次刷新时间间隔小与下发的时间间隔
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.refreshInterval - fabs([self.lastUpdateTime timeIntervalSinceNow]) target:self selector:@selector(refreshStockData) userInfo:nil repeats:NO];
        return ; 
    }
    
    _isLoading = YES;
    
    [[ExploreStockCellManager sharedManager] startGetDataFromStockData:_stockData completion:^(StockData *stockData, NSDictionary *data, NSError *error) {
        if (self.stockData.uniqueID == stockData.uniqueID) {
            if (!error) {
                
                self.lastUpdateTime = [NSDate date];
    
                self.refreshInterval = [stockData.refreshInterval doubleValue];
                
                if (!stockData.shouldStopUpdate) {//如果上次刷新的时间跟这个刷新的时间相同，则停止定时刷新
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.refreshInterval target:self selector:@selector(refreshStockData) userInfo:nil repeats:NO];
                }
                else{
                    if (self.timer) {
                        [self.timer invalidate];
                        self.timer = nil;
                    }
                }
            }
            [self updateStockCellWithStockData:_stockData];
            _isLoading = NO;
        }
    }];
}

- (void)updateStockCellWithStockData:(StockData *)stockData {
    [_stockNameLabel setText:stockData.stockName];
    [_stockNameLabel sizeToFit];
    
    [_stockIDLabel setText:stockData.stockID];
    [_stockIDLabel sizeToFit];
    
    _stockStatus = stockData.stockStatus;
    
    [_stockPriceLabel setText:stockData.stockPrice];
    [_stockPriceLabel sizeToFit];
    
    [_changeAmountLabel setText:stockData.changeAmount];
    [_changeAmountLabel sizeToFit];
    
    [_changeScaleLabel setText:stockData.changeScale];
    [_changeScaleLabel sizeToFit];
    
    [_tradingStatusLabel setText:stockData.tradingStatus];
    [_tradingStatusLabel sizeToFit];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *lastUpdateTime = [NSDate dateWithTimeIntervalSince1970:[stockData.lastUpdateTime doubleValue]];
    [_lastUpdateTimeLabel setText:[dateFormatter stringFromDate:lastUpdateTime]];
    [_lastUpdateTimeLabel sizeToFit];
    
    [self refreshUI];
    [self reloadThemeUI];
}

- (void)didEndDisplaying {
    [self.timer invalidate];
    self.timer = nil;
    _isCellDisplay = NO;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (_isCellDisplay) {
        [self refreshStockData];
    }
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    StockData *stock = self.orderedData.stockData;
    if(stock != nil){
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:stock.schemaUrl]];
    }
}

@end
