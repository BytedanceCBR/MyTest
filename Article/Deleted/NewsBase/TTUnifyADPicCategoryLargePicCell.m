//
//  TTUnify1ADLargePicCell.m
//  Article
//
//  Created by yin on 16/10/12.
//
//

#import "TTUnifyADPicCategoryLargePicCell.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreOrderedData+TTAd.h"
#import "NSString-Extension.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceHelper.h"
#import "TTLayOutCellDataHelper.h"
#import "TTLabelTextHelper.h"

#define kAdLabelRightPadding [TTDeviceUIUtils tt_newPadding:15]
#define kAdLabelBottomPadding [TTDeviceUIUtils tt_newPadding:6]
#define kActionButtonRightPadding  [TTDeviceUIUtils tt_newPadding:6]
#define kActionButtonWith [TTDeviceUIUtils tt_newPadding:75]
#define kActionButtonHeight [TTDeviceUIUtils tt_newPadding:28]
#define kActionIconRightPadding [TTDeviceUIUtils tt_newPadding:3]
#define kAccessoryButtonRightPadding [TTDeviceUIUtils tt_newPadding:6.5]
#define kActionIconSize CGSizeMake(12, 12)
#define kSourceImageViewWidth 16
#define kAccessoryButtonWidth 30

#define kInfoViewSourceLabelLeftPadding [TTDeviceUIUtils tt_fontSize:4]
#define kActionButtonTitleFontSize [TTDeviceUIUtils tt_newFontSize:14.0]

#define kInfoViewMargin [TTDeviceUIUtils tt_fontSize:6]

@interface TTPicCategoryADInfoView : TTADInfoView

@end

@implementation TTPicCategoryADInfoView

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* label = [super sourceLabel];
    label.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
    return label;
}

- (SSThemedLabel*)commentLabel
{
    SSThemedLabel* label = [super commentLabel];
    label.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
    return label;
}

- (SSThemedLabel*)timeLabel
{
    SSThemedLabel* label = [super timeLabel];
    label.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
    return label;
}

/**
 信息栏控件布局  重写父类方法  父类隐藏sourceLabel 子类显示并重新布局其余控件
 */
- (void)layoutInfoView {
    
    CGFloat left = 0, margin = kInfoViewMargin;
    
    //layout sourceLabel
    NSString *source = [TTLayOutCellDataHelper getADSourceStringWithOrderedDada:self.orderedData];
    if (!isEmptyString(source)) {
        self.sourceLabel.text = source;
        self.sourceLabel.hidden = NO;
        [self.sourceLabel sizeToFit];
        self.sourceLabel.frame = CGRectMake(left, 0, self.sourceLabel.width, kInfoViewHeight());
        left += self.sourceLabel.width + kInfoViewSourceLabelLeftPadding;
    } else {
        self.sourceLabel.hidden = YES;
    }
    
    // layout commentLabel
    if (!self.commentLabel.hidden) {
        [self.commentLabel sizeToFit];
        self.commentLabel.frame = CGRectMake(left, 0, self.commentLabel.width, kInfoViewHeight());
        left += (self.commentLabel.width + margin);
    }
    
    // layout timeLabel
    if (!self.timeLabel.hidden) {
        [self.timeLabel sizeToFit];
        self.timeLabel.frame = CGRectMake(left, 0, self.timeLabel.width, kInfoViewHeight());
        left += (self.timeLabel.width + margin);
    }
}

@end

@interface TTUnifyADPicCategoryLargePicCell()

@property (nonatomic, strong) SSThemedView *bottomSeperatorView;
@property (nonatomic, strong) SSThemedLabel *adLabel;
//新的信息栏 父类信息栏隐藏了sourceLabel
@property (nonatomic, strong) TTPicCategoryADInfoView* adInformationView;

@end

@implementation TTUnifyADPicCategoryLargePicCell

/**
 更新数据界面
 
 - parameter data: data数据
 */
- (void)refreshWithData:(id)data {
    NSParameterAssert(data != nil);
    if (![data isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    
    self.orderedData = orderedData;
    self.picView.style = TTArticlePicViewStyleLarge;
    [self updateTitleViewWithAction:YES];
    [self updatePicView];
    [self updateAdLabel];
    [self updateADInfoView];
    [self updateActionBtn];
    [self updateBottomLineView];
}

/**
 更新UI界面
 */
- (void)refreshUI {
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    CGFloat containWidth = [TTDeviceHelper isPadDevice] ? self.cellView.width - kCellLeftPadding - kCellRightPadding:self.cellView.width;
    CGFloat x = [TTDeviceHelper isPadDevice]?kCellLeftPadding:0;
    CGFloat y = 0;
   
    // 布局图片(视频)控件
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:adModel.imageModel picStyle:TTArticlePicViewStyleLarge width:containWidth];
    self.picView.picView1.layer.borderWidth = 0;
    self.picView.frame = CGRectMake(x, y, picSize.width, picSize.height);
    y = y + picSize.height;
    
    // 布局标题控件
    x = kCellLeftPadding;
    if (![TTDeviceHelper isPadDevice]) {
        containWidth = containWidth - kPaddingLeft() - kPaddingRight();
    }
    
    NSString *title = [TTLayOutCellDataHelper getTitleStyle2WithOrderedData:self.orderedData];
    y = y + kCellGroupPicTopPadding;
    
    if (!isEmptyString(title)) {
        CGFloat titleFontSize = [TTDeviceHelper isPadDevice] ? kCellTitleLabelFontSize : kTitleViewFontSize();
        CGFloat titleHeight = [TTLabelTextHelper heightOfText:title fontSize:titleFontSize forWidth:containWidth forLineHeight:kTitleViewLineHeight() constraintToMaxNumberOfLines:kTitleViewLineNumber()];
        self.titleView.frame = CGRectMake(x, y, containWidth, titleHeight);
        y += titleHeight;
    }
    
    y = [self layoutIpad:y];
    
    self.adLabel.right = self.picView.right - kAdLabelRightPadding;
    self.adLabel.bottom = self.picView.bottom - kAdLabelBottomPadding;
    // 布局信息栏控件
    y += cellInfoBarTopPadding();
    CGSize infoSize = [TTArticleCellHelper getInfoSize:containWidth];
    self.adInformationView.frame = CGRectMake(x, y, infoSize.width, infoSize.height);
    self.adInformationView.typeIconView.hidden = YES;
    self.accessoryButton.right = self.adInformationView.right + kAccessoryButtonRightPadding;
    self.accessoryButton.centerY = self.adInformationView.centerY;
    
    self.bottomLineView.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], containWidth, [TTDeviceHelper ssOnePixel]);
    self.bottomLineView.centerX = self.cellView.width / 2;
    
    self.actionButton.right = self.accessoryButton.left - kActionButtonRightPadding;
    self.actionButton.centerY = self.accessoryButton.centerY;

    [self layoutInfoViewSubviews];
    if (![TTDeviceHelper isPadDevice]) {
        self.bottomSeperatorView.frame = CGRectMake(-1, self.height - kCellSeprateViewHeight(), self.cellView.width + 2, kCellSeprateViewHeight());
    }
}

#pragma mark --重新布局子类特有控件

//覆盖父类方法
- (void)updateADInfoView
{
    if (self.orderedData) {
        [self.adInformationView updateInfoView:self.orderedData];
    }
}

- (void)layoutInfoViewSubviews
{
    SSThemedLabel* sourceLabel = self.adInformationView.sourceLabel;
    SSThemedLabel* commentLabel = self.adInformationView.commentLabel;
    SSThemedLabel* timeLabel = self.adInformationView.timeLabel;
    
    CGFloat containWidth = [TTDeviceHelper isPadDevice]? self.cellView.width - kCellLeftPadding - kCellRightPadding:self.cellView.width;
    if (![TTDeviceHelper isPadDevice]) {
        containWidth = containWidth - kCellLeftPadding - kCellRightPadding;
    }
    CGSize infoSize = [TTArticleCellHelper getInfoSize:containWidth];
    
    containWidth = infoSize.width - kSourceImageViewWidth - kInfoViewSourceLabelLeftPadding - kAccessoryButtonWidth - kActionButtonWith - kActionIconSize.width;
    
    sourceLabel.width = sourceLabel.width < containWidth? sourceLabel.width:containWidth;
    containWidth = containWidth - sourceLabel.width;
    containWidth = containWidth>kInfoViewMargin? (containWidth - kInfoViewMargin):0;
    
    commentLabel.width = commentLabel.width < containWidth? commentLabel.width:containWidth;
    containWidth = containWidth - commentLabel.width;
    containWidth = containWidth> kInfoViewMargin?(containWidth- kInfoViewMargin):0;
    
    timeLabel.width = timeLabel.width < containWidth? timeLabel.width: containWidth;
    
}

//ipad上title在上,picView在下  iphone上title在下,picView在上
- (NSInteger)layoutIpad:(NSInteger)bottom
{
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat y = kCellTopPadding;
        self.titleView.top = y;
        y += self.titleView.height + kCellGroupPicTopPadding;
        self.picView.top = y;
        y += self.picView.height;
        return y;
    }
    return bottom;
}

/** 更新下载按钮 */
- (void)updateActionBtn {
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    //更新actionButton
    if (self.orderedData) {
        self.actionButton.actionModel = self.orderedData;
    }
    
    //更新actionIcon
    if (self.orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        [self.actionButton setIconImageNamed:@"download_ad_picture"];
        self.actionButton.hidden = NO;
    } else if (adModel && adModel.adType == ExploreActionTypeApp) {
        [self.actionButton setIconImageNamed:@"download_ad_picture"];
        self.actionButton.hidden = NO;
    } else if (adModel && adModel.adType == ExploreActionTypeAction) {
        [self.actionButton setIconImageNamed:@"cellphone_ad_picture"];
        self.actionButton.hidden = NO;
    } else if (adModel && adModel.adType == ExploreActionTypeCounsel) {
        [self.actionButton setIconImageNamed:@"counsel_ad_picture"];
        self.actionButton.hidden = NO;
    } else if (adModel && adModel.adType == ExploreActionTypeForm) {
        [self.actionButton setIconImageNamed:nil];
        self.actionButton.hidden = NO;
    } else {
        [self.actionButton setIconImageNamed:nil];
        self.actionButton.hidden = YES;
    }
    
    CGFloat actionButtonTitleWidth = [adModel.actionButtonTitle tt_sizeWithMaxWidth:CGFLOAT_MAX font:[UIFont systemFontOfSize:kActionButtonTitleFontSize]].width;
    CGFloat actionButtonWidth = actionButtonTitleWidth + 5 + kActionIconSize.width;
    self.actionButton.width = MAX(actionButtonWidth, kActionButtonWith);
    [self adjustButtonSpace:self.actionButton space:5.0f];
}

- (void)adjustButtonSpace:(UIButton *)button space:(CGFloat)spacing {
    CGFloat insetAmount = spacing / 2.0;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount);
    button.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
}

- (void)updateAdLabel
{
    self.adLabel.text = !isEmptyString([self.orderedData displayLabel])?[self.orderedData displayLabel]: NSLocalizedString(@"广告", @"广告");
}

#pragma mark --添加子类特有控件

- (TTLabel *)titleView {
    TTLabel* label = [super titleView];
    //title的font适配ipad、iphone
    BOOL isBoldFont = [TTDeviceHelper isPadDevice];
    label.font = isBoldFont ? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] : [UIFont tt_fontOfSize:kCellTitleLabelFontSize];
    return label;
}

/** 广告信息栏控件 */
- (TTPicCategoryADInfoView *)adInformationView {
    if (_adInformationView == nil) {
        _adInformationView = [[TTPicCategoryADInfoView alloc] init];
        [self.cellView addSubview:_adInformationView];
    }
    return _adInformationView;
}


- (ExploreActionButton*)actionButton
{
    ExploreActionButton* button = [super actionButton];
    button.backgroundColor = [UIColor clearColor];
    button.backgroundColorThemeKey = nil;
    button.layer.borderWidth = 0;
    button.titleLabel.font = [UIFont systemFontOfSize:kActionButtonTitleFontSize];
    return button;
}

- (SSThemedLabel *)adLabel
{
    if (!_adLabel) {
        _adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _adLabel.textAlignment = NSTextAlignmentCenter;
        _adLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10.f]];
        _adLabel.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:26.f], [TTDeviceUIUtils tt_newPadding:14.f]);
        _adLabel.layer.cornerRadius = 3.f;
        _adLabel.clipsToBounds = YES;
        _adLabel.textColorThemeKey = kColorText12;
        _adLabel.backgroundColorThemeKey = kColorBackground15;
        [self.cellView addSubview:_adLabel];
    }
    return _adLabel;
}

- (SSThemedView*)bottomSeperatorView
{
    if (!_bottomSeperatorView) {
        _bottomSeperatorView = [SSThemedView new];
        _bottomSeperatorView.backgroundColorThemeKey = kCellBottomLineBackgroundColor;
        _bottomSeperatorView.borderColorThemeKey = kCellBottomLineColor;
        _bottomSeperatorView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self.cellView addSubview:_bottomSeperatorView];
    }
    return _bottomSeperatorView;
}

/**
 计算数据对应Cell高度
 
 - parameter data:      data数据
 - parameter cellWidth: Cell宽度
 - parameter listType:  列表类型
 
 - returns: 数据对应Cell高度
 */
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)cellWidth listType:(ExploreOrderedDataListType)cellType {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if (orderedData) {
        id<TTAdFeedModel> adModel = orderedData.adModel;

        CGFloat height = 0;
        CGFloat width = cellWidth;
        // 计算图片(视频)控件
        CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:adModel.imageModel picStyle:TTArticlePicViewStyleLarge width:width];
        height += picSize.height;
        
        // 计算title上边距
        height = height + kCellGroupPicTopPadding;
        width = cellWidth - kPaddingLeft() - kPaddingRight();
        // 计算标题控件
        NSString *title = [TTLayOutCellDataHelper getTitleStyle2WithOrderedData:orderedData];
        
        if (!isEmptyString(title)) {
            CGFloat titleFontSize = [TTDeviceHelper isPadDevice]? kCellTitleLabelFontSize : kTitleViewFontSize();
            CGFloat titleHeight = [TTLabelTextHelper heightOfText:title fontSize:titleFontSize forWidth:width forLineHeight:kTitleViewLineHeight() constraintToMaxNumberOfLines:kTitleViewLineNumber()];
            height += titleHeight;
        }
        CGSize infoSize = [TTArticleCellHelper getInfoSize:width];
        // 计算信息栏控件
        height += (cellInfoBarTopPadding() + infoSize.height);
        height += kCellBottomPaddingWithPic;
        //计算底部空白区域即灰条高度
        if (![orderedData nextCellHasTopPadding]) {
            if (![TTDeviceHelper isPadDevice]) {
                height += kCellSeprateViewHeight();
            }
            height += [TTDeviceHelper ssOnePixel];
        }
        
        return height;
    }
    return 0;
}

@end
