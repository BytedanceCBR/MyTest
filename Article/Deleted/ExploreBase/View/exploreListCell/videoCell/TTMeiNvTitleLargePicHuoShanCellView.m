//
//  TTMeiNvTitleLargePicHuoShanCellView.m
//  Article
//
//  Created by  xuzichao on 16/6/15.
//
//

#import "TTMeiNvTitleLargePicHuoShanCellView.h"
#import "TTImageView.h"
#import "TTRoute.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreArticleTitleLargePicCellView.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTImageView+TrafficSave.h"
#import "NetworkUtilities.h"
#import "HuoShan.h"
#import "LiveRoomPlayerViewController.h"
#import "TTUISettingHelper.h"
#import "TTArticleCellHelper.h"
#import "NSString-Extension.h"
#import "TTDeviceHelper.h"


#define kDurationRightPadding 5
#define kDurationBottomPadding 3
#define kBottomViewH 10

@interface TTMeiNvTitleLargePicHuoShanCellView()


@property(nonatomic,strong)TTImageView* pic;
@property(nonatomic, strong)SSThemedButton * playButton;
@property(nonatomic,strong) SSThemedLabel* countLabel;
@property (nonatomic, strong) UIView      *sepLineView;
@property (nonatomic, strong) UIView      *bottomView;

@end

@implementation TTMeiNvTitleLargePicHuoShanCellView
{
    LargePicViewType type;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.playButton.imageName = @"live_video_icon";
        [_playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.pic addSubview:_playButton];
        
        self.countLabel = [[SSThemedLabel alloc] init];
        self.countLabel.font = [UIFont systemFontOfSize:10.];
        self.countLabel.textColor = [UIColor tt_themedColorForKey:kColorFeedInfoLabel];
        [self addSubview:self.countLabel];
        [self bringSubviewToFront:self.countLabel];
        
        _sepLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
        [self addSubview:_sepLineView];
        
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        if ([TTDeviceHelper isPadDevice]) {
            _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        }
        [self addSubview:_bottomView];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    
    _playButton.userInteractionEnabled = YES;
    
    
    if (self.orderedData && self.orderedData.managedObjectContext) {
        HuoShan *huoshan = self.orderedData.huoShan;
        if (huoshan && huoshan.managedObjectContext) {
            [self updateCountLabel];
            [self updateTitleLabel];
            [self updatePic];
        }
        else {
            self.titleLabel.height = 0;
            self.countLabel.height = 0;
        }
    }
    
    //cellFlag 控制
//    if (![self.orderedData isShowHuoShanViewCount]) {
//        
//        self.countLabel.height = 0;
//        self.countLabel.hidden = YES;
//    }
    
    if (![self.orderedData isShowHuoShanTitle]) {
        
        self.titleLabel.height = 0;
        self.titleLabel.hidden = YES;
        self.countLabel.height = 0;
        self.countLabel.hidden = YES;
    }
    
    CGFloat containWidth = self.width - 1.5*kCellLeftPadding - kCellRightPadding - self.countLabel.width;
    if (!isEmptyString(self.titleLabel.text)) {

        NSInteger lineNumbers = [self.titleLabel.text tt_lineNumberWithMaxWidth:containWidth font:[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine firstLineIndent:0 alignment:NSTextAlignmentLeft];
        
        if (lineNumbers > 1) {
            self.countLabel.hidden = YES;
            [self.titleLabel sizeToFit:self.width - kCellLeftPadding - kCellRightPadding];
        }
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self updatePic];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    if ([TTDeviceHelper isPadDevice]) {
        _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
}

- (void)refreshUI
{
    CGFloat x = kCellLeftPadding;
    CGFloat y = kCellTopPadding;
    
    if (self.orderedData.huoShan.title) {
        self.titleLabel.origin = CGPointMake(x, y);
        y += self.titleLabel.height;
        
        self.countLabel.left = self.width - kCellRightPadding - self.countLabel.width;
        self.countLabel.centerY = kCellTopPadding + self.titleLabel.height/2;
    }
    
    
    [self layoutPic];
    
    y = self.pic.bottom + kCellBottomPaddingWithPic + [TTDeviceHelper ssOnePixel];
    
    
    [self layoutInfoBarSubViews];
    
    
    self.bottomLineView.hidden = YES;
    
    _playButton.frame = self.pic.bounds;
    
    _sepLineView.frame = CGRectMake(0, y, self.frame.size.width, [TTDeviceHelper ssOnePixel]);
    
    if ([TTDeviceHelper isPadDevice]) {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, 0);
    }
    else {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, kBottomViewH);
    }
    
    if ([self.orderedData nextCellHasTopPadding]) {
        _sepLineView.hidden = YES;
    } else {
        _sepLineView.hidden = NO;
    }
    
}

- (void)playButtonClicked
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(self.orderedData.huoShan.uniqueID) forKey:@"id"];
    [params setValue:@"click_image_ppmm" forKey:@"refer"];
    LiveRoomPlayerViewController *huoShanVC = [[LiveRoomPlayerViewController alloc] initFromPushService:params];
    UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: self];
    [topMost pushViewController:huoShanVC animated:YES];
    
    //入口需要发送统计
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        wrapperTrackEventWithCustomKeys(@"go_detail", @"click_image_ppmm", self.orderedData.huoShan.liveId.stringValue, nil, @{@"room_id":self.orderedData.huoShan.liveId,@"user_id":[self.orderedData.huoShan.userInfo objectForKey:@"user_id"]});
    }
    
    //log3.0 doubleSending
    NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:4];
    [logv3Dic setValue:self.orderedData.huoShan.liveId.stringValue forKey:@"room_id"];
    [logv3Dic setValue:[self.orderedData.huoShan.userInfo objectForKey:@"user_id"] forKey:@"user_id"];
    [logv3Dic setValue:@"click_image_ppmm" forKey:@"enter_from"];
    [logv3Dic setValue:self.orderedData.logPb forKey:@"log_pb"];
    [TTTrackerWrapper eventV3:@"go_detail" params:logv3Dic isDoubleSending:YES];
}


- (void)didEndDisplaying
{
    
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    
}

- (void)layoutInfoBarSubViews
{
    if (self.infoBarView) {
        [self.infoBarView removeFromSuperview];
    }
    
}

- (void)updateTitleLabel
{
    if (self.titleLabel)
    {
        [self updateContentColor];
        
        if (!isEmptyString(self.orderedData.huoShan.title)) {
            BOOL isBoldFont = [TTDeviceHelper isPadDevice];
            self.titleLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] : [UIFont tt_fontOfSize:kCellTitleLabelFontSize];
            self.titleLabel.lineHeight = kCellTitleLineHeight;
            self.titleLabel.text = self.orderedData.huoShan.title;
        } else {
            self.titleLabel.text = nil;
        }
    }
    
    CGFloat containWidth = self.width - 1.5*kCellLeftPadding - kCellRightPadding - self.countLabel.width;
    [self.titleLabel sizeToFit:containWidth];
    
}


- (void)updateCountLabel
{
    if (self.countLabel)
    {
        BOOL isBoldFont = [TTDeviceHelper isPadDevice];
        self.countLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:cellInfoLabelFontSize()] : [UIFont tt_fontOfSize:cellInfoLabelFontSize()];
        
        if (self.orderedData.huoShan.viewCount.floatValue > 0) {
            self.countLabel.text = [NSString stringWithFormat:@"%@人在看",self.orderedData.huoShan.viewCount];
        }
        else {
            self.countLabel.text = @"0人在看";
        }
        
        [self.countLabel sizeToFit];
    }
}

- (TTImageView *)pic
{
    if (!_pic) {
        _pic = [[TTImageView alloc] initWithFrame:CGRectZero];
        _pic.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _pic.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _pic.borderColorThemeKey = kCellGroupPicBorderColor;
        [self addSubview:_pic];
    }
    return _pic;
}

- (void)updatePic
{
    HuoShan *huoShan = self.orderedData.huoShan;
    type = LargePicViewTypeNormal;
    NSDictionary *imageInfo = [NSDictionary dictionary];
    imageInfo = huoShan.nhdImageInfo;
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
    self.pic.backgroundColor = [UIColor tt_themedColorForKey:kCellGroupPicBackgroundColor];
    
    [self.pic setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
    
    if (type == LargePicViewTypeNormal) {
        _pic.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    } else {
        _pic.layer.borderWidth = 0;
    }
}

- (void)layoutPic
{
    // 根据图片实际宽高设置其在cell中的高度
    BOOL isPad = [TTDeviceHelper isPadDevice];
    CGFloat galleryWidth = isPad  ? [ExploreCellHelper largeImageWidth:self.width] : self.width;
    CGFloat galleryLeftPadding = isPad ? kCellLeftPadding : 0;
    
    
    float imageHeight = (type == LargePicViewTypeGallary || !self.pic.model) ? galleryWidth * 9.f / 16.f : ([ExploreCellHelper heightForImageWidth:self.pic.model.width height:self.pic.model.height constraintWidth:[ExploreCellHelper largeImageWidth:self.width]]);
    CGFloat leftPadding = type == LargePicViewTypeGallary ? galleryLeftPadding : kCellLeftPadding;
    CGFloat picWidth = type == LargePicViewTypeGallary ? galleryWidth : [ExploreCellHelper largeImageWidth:self.width];
    
    self.pic.frame = CGRectMake(leftPadding, self.titleLabel.bottom + kCellGroupPicTopPadding, picWidth, imageHeight);
}

- (NSDictionary *)extraValueDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@(self.orderedData.huoShan.uniqueID) forKey:@"item_id"];
    [dic setObject:self.orderedData.categoryID forKey:@"category_id"];
    if ([self getRefer]) {
        [dic setObject:[NSNumber numberWithUnsignedInteger:[self getRefer]] forKey:@"location"];
    }
    [dic setObject:@1 forKey:@"gtype"];
    return dic;
}


+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        HuoShan *huoShan = orderedData.huoShan;
        LargePicViewType type = LargePicViewTypeNormal;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (![TTDeviceHelper isPadDevice] && type == LargePicViewTypeGallary &&
                ([orderedData nextCellHasTopPadding])) {
                cacheH -= (kBottomViewH + [TTDeviceHelper ssOnePixel]);
            }
            return cacheH;
        }
        
        CGFloat containWidth = width - kCellLeftPadding - kCellRightPadding ;
        
        CGFloat titleHeight = 0;

        if (huoShan.title) {
            titleHeight = [huoShan.title tt_sizeWithMaxWidth:containWidth font:[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine].height;
        }
        
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:huoShan.nhdImageInfo];
        // 根据图片实际宽高设置其在cell中的高度
        BOOL isPad = [TTDeviceHelper isPadDevice];
        
        BOOL isNotGallaryChannel = (orderedData.gallaryStyle == 1);
        CGFloat galleryWidth = (isPad || isNotGallaryChannel) ? [ExploreCellHelper largeImageWidth:width] : width;
        
        float imageHeight = type == LargePicViewTypeGallary ? galleryWidth * 9.f/16.f : [ExploreCellHelper heightForImageWidth:model.width height:model.height constraintWidth:[ExploreCellHelper largeImageWidth:width]];
        
        //标题、大图
        CGFloat height = kCellTopPadding + kCellBottomPaddingWithPic + titleHeight + imageHeight + kCellGroupPicTopPadding;
        
        height = ceilf(height);
        
        if ([TTDeviceHelper isPadDevice]) {
            height +=  [TTDeviceHelper ssOnePixel];
        }
        else {
            height +=  kBottomViewH + [TTDeviceHelper ssOnePixel];
        }
        
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        if (![TTDeviceHelper isPadDevice] && type == LargePicViewTypeGallary && [orderedData nextCellHasTopPadding]) {
            height -= kCellBottomLineHeight;
        }
        
        return height;
    }
    
    return 0.f;
}

@end
