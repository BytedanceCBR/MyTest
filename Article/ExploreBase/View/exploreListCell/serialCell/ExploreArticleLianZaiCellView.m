//
//  ExploreArticleLianZaiCellView.m
//  Article
//
//  Created by 邱鑫玥 on 16/7/13.
//
//

#import "ExploreArticleLianZaiCellView.h"
#import "TTImageView+TrafficSave.h"
#import "TTUISettingHelper.h"
#import "LianZai.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTLabelTextHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTDeviceHelper.h"
#import "NewsUserSettingManager.h"
#import "ExploreCellHelper.h"
#import "TTArticleCellHelper.h"
#import "SSTTTAttributedLabel.h"
#import "TTRoute.h"
#import "UIImageView+BDTSource.h"

#define kLianZaiCellDescriptionLabelMaxLine 2
#define kCellLianZaiTitleLabelMaxLine 2
//为了在...后面留五个字的空白
#define kArrowStr @"...透明的字"

static inline CGFloat cellPicTopPaddingWithLianZai() {
    if ([TTDeviceHelper isPadDevice]) {
        return 21.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 14.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    } else {
        return 16.f;
    }
}

//描述字段的字体
static inline CGFloat lianzaiCellDescriLabelFontSize(){
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 18.f;
        return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:YES];
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 14.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 14.f;
    } else {
        fontSize = 12.f;
    }
    return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:NO];
}

//展示更多的字体
static inline CGFloat lianzaiCellShowMoreLabelFontSize(){
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 18.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 16.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 16.f;
    } else {
        fontSize = 14.f;
    }
    return fontSize;
}
//描述字段的行高
static inline CGFloat lianzaiCellDescriLabelLineHeight(){
    return ceil(lianzaiCellDescriLabelFontSize() * 1.4);
}

//图片宽度
static inline CGFloat lianzaiCellPicWidth(){
    if ([TTDeviceHelper isPadDevice]) {
        return 113.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 97.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 87.f;
    } else {
        return 75.f;
    }
}

//图片在右时，图片和左边label的间距
static inline CGFloat lianzaiCellLeftPaddingToPic(){
    if ([TTDeviceHelper isPadDevice]) {
        return 26.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 20.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 20.f;
    } else {
        return 23.f;
    }
}


//图片在左时，图片和右边label的间距
static inline CGFloat lianzaiCellRightPaddingToPic(){
    if ([TTDeviceHelper isPadDevice]) {
        return 22.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 16.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    } else {
        return 12.f;
    }
}

//显示摘要Label时候标题下面的间距
static inline CGFloat lianzaiCellBottomPaddingToTitleForDescriLabel(){
    CGFloat padding = 0;
    if ([TTDeviceHelper isPadDevice]) {
        padding = 10.f;
    } else if ([TTDeviceHelper is736Screen]) {
        padding = 6.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        padding = 7.f;
    } else {
        padding = 6.f;
    }
    
    return padding;
}

// 摘要和展示更多之间的间距
static inline CGFloat lianzaiCellDescriLabelAndShowMoreInterval(){
    CGFloat padding = 0;
    if([TTDeviceHelper isPadDevice]){
        padding = 24.f;
    }else if ([TTDeviceHelper is736Screen]) {
        padding = 18.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        padding = 8.f;
    } else {
        padding = 7.f;
    }
    return padding;
}

static inline CGFloat lianzaiCellShowMoreIconLeftPaddingForShowMoreLabel(){
    CGFloat padding = 0;
    if([TTDeviceHelper isPadDevice]){
        padding = 6.f;
    }else if ([TTDeviceHelper is736Screen]) {
        padding = 6.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        padding = 4.f;
    } else {
        padding = 4.f;
    }
    return padding;
}

@interface ExploreArticleLianZaiCellView()

@property (nonatomic, strong) TTImageView   *coverImageView;
@property (nonatomic, strong) SSThemedLabel *lianzaiTitleLabel;
@property (nonatomic, strong) SSTTTAttributedLabel *descriLabel;
@property (nonatomic, strong) SSThemedLabel *showMoreLabel;
@property (nonatomic, strong) SSThemedImageView *showMoreImageView;
@property (nonatomic, strong) SSThemedView *topRect;
@property (nonatomic, strong) SSThemedView *bottomRect;
@end

@implementation ExploreArticleLianZaiCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        LianZai *lianzai = orderedData.lianZai;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheHeight = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheHeight > 0) {
            if ([orderedData preCellHasBottomPadding]) {
                cacheHeight -= kCellSeprateViewHeight();
            }
            if ([orderedData nextCellHasTopPadding]) {
                cacheHeight -= kCellSeprateViewHeight();
            }
            return cacheHeight;
        }
        
        CGFloat containWidth = width - kCellLeftPadding - kCellRightPadding;
        CGFloat picWidth = lianzaiCellPicWidth();
        //图片高度
        CGFloat picHeight = ceil(picWidth * 4 / 3);
        
        //文字高度
        CGFloat wordheight = 0;
        //serial_style ＝ 1 表示图在右，其它表示图在左
        BOOL isPicOnRight = [lianzai.serialStyle intValue] == 1;
        CGFloat titleWidth = 0;
        if (isPicOnRight) {
            /* 图片在右时 */
            titleWidth = containWidth - lianzaiCellLeftPaddingToPic() - picWidth;
        }
        else{
            /* 图片在左时 */
            titleWidth = containWidth - lianzaiCellRightPaddingToPic() - picWidth;
        }

        //文字与图片顶部对齐
        wordheight -= ceil((kCellTitleLineHeight - [UIFont systemFontOfSize:kCellTitleLabelFontSize].lineHeight + kCellTitleLineHeight - [UIFont systemFontOfSize:kCellTitleLabelFontSize].pointSize) / 2.0);
        
        CGFloat titleLabelHeight = [TTLabelTextHelper heightOfText:lianzai.title fontSize:kCellTitleLabelFontSize forWidth:titleWidth forLineHeight:kCellTitleLineHeight constraintToMaxNumberOfLines:kCellLianZaiTitleLabelMaxLine firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        wordheight += titleLabelHeight + lianzaiCellBottomPaddingToTitleForDescriLabel();
        
        float descriLabelHeight = [TTLabelTextHelper heightOfText:lianzai.abstract fontSize:lianzaiCellDescriLabelFontSize() forWidth:titleWidth forLineHeight:lianzaiCellDescriLabelLineHeight() constraintToMaxNumberOfLines:kLianZaiCellDescriptionLabelMaxLine firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        wordheight += descriLabelHeight + lianzaiCellDescriLabelAndShowMoreInterval();
   
        // 计算标题控件
        wordheight += lianzaiCellShowMoreLabelFontSize();
        
        CGFloat height = wordheight > picHeight? wordheight : picHeight;
        height += 2 * cellPicTopPaddingWithLianZai();//cell内上下留白
        height += 2 * kCellSeprateViewHeight();//上下分割线
        
        // 缓存高度
        height = ceilf(height);
        
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        if ([orderedData preCellHasBottomPadding]) {
            height -= kCellSeprateViewHeight();
        }
        if ([orderedData nextCellHasTopPadding]) {
            height -= kCellSeprateViewHeight();
        }
        
        return height;

    }
    
    return 0.f;
}

/** 顶部分割面 */
- (SSThemedView *)topRect {
    if (!_topRect) {
        _topRect = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCellSeprateViewHeight())];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }
    return _topRect;
}

/** 底部分割线 */
- (SSThemedView *)bottomRect {
    if (!_bottomRect) {
        _bottomRect = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCellSeprateViewHeight())];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }
    return _bottomRect;
}


- (TTImageView *)coverImageView{
    if(!_coverImageView){
        _coverImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _coverImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _coverImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel] ;
        _coverImageView.borderColorThemeKey = kColorLine1;
        [self addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (SSThemedLabel *)lianzaiTitleLabel{
    if(!_lianzaiTitleLabel){
        _lianzaiTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _lianzaiTitleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
        _lianzaiTitleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
        _lianzaiTitleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _lianzaiTitleLabel.numberOfLines = kCellLianZaiTitleLabelMaxLine;
        _lianzaiTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _lianzaiTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_lianzaiTitleLabel];
    }
    return _lianzaiTitleLabel;
}

- (SSTTTAttributedLabel *)descriLabel{
    if(!_descriLabel){
        _descriLabel = [[SSTTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _descriLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
        _descriLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _descriLabel.textAlignment = NSTextAlignmentLeft;
        _descriLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _descriLabel.numberOfLines = kLianZaiCellDescriptionLabelMaxLine;
        _descriLabel.font = [UIFont systemFontOfSize:lianzaiCellDescriLabelFontSize()];
        NSDictionary * dict1 = @{NSFontAttributeName : [UIFont systemFontOfSize:lianzaiCellDescriLabelFontSize()],
                                 NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText3]};
        NSDictionary * dict2 = @{NSFontAttributeName : [UIFont systemFontOfSize:lianzaiCellDescriLabelFontSize()],
                                 NSForegroundColorAttributeName : [UIColor clearColor]};
        NSMutableAttributedString *trunStr = [[NSMutableAttributedString alloc] initWithString:kArrowStr];
        if (trunStr.length > 4) {
            [trunStr addAttributes:dict1 range:NSMakeRange(0, trunStr.length - 4)];
            [trunStr addAttributes:dict2 range:NSMakeRange(trunStr.length - 4, 4)];
        }
        _descriLabel.attributedTruncationToken = trunStr;
        [self addSubview:_descriLabel];
    }
    return _descriLabel;
}

- (SSThemedLabel *)showMoreLabel {
    if (!_showMoreLabel) {
        _showMoreLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _showMoreLabel.textColorThemeKey = kColorText6;
        _showMoreLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _showMoreLabel.textAlignment = NSTextAlignmentLeft;
        _showMoreLabel.numberOfLines = 1;
        _showMoreLabel.font = [UIFont systemFontOfSize:lianzaiCellShowMoreLabelFontSize()];
        [self addSubview:_showMoreLabel];
    }
    return _showMoreLabel;
}

- (SSThemedImageView *)showMoreImageView {
    if (!_showMoreImageView) {
        _showMoreImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _showMoreImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _showMoreImageView.imageName = @"feed_read_more";
        [self addSubview:_showMoreImageView];
    }
    return _showMoreImageView;
}
/**
 *  重写父类的方法
 */
- (void)updateContentColor{
    LianZai *lianzai = self.orderedData.lianZai;
    if (!lianzai.managedObjectContext)
    {
        return;
    }
    
    BOOL hasRead = [self.orderedData hasRead];
    
    self.lianzaiTitleLabel.highlighted = hasRead;
    
    self.descriLabel.highlighted = hasRead;
}

/**
 *  重写父类的方法
 */
- (void)updateTitleLabel{
    if (self.lianzaiTitleLabel){
        if(!isEmptyString(self.orderedData.lianZai.title)){
            BOOL isBoldFont = [TTDeviceHelper isPadDevice];
            self.lianzaiTitleLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize]:
            [UIFont tt_fontOfSize:kCellTitleLabelFontSize];
            self.lianzaiTitleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.orderedData.lianZai.title fontSize:kCellTitleLabelFontSize lineHeight:kCellTitleLineHeight lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:isBoldFont firstLineIndent:0];
        }
        else{
            self.lianzaiTitleLabel.attributedText = nil;
        }
    }
}

- (void)updateDescriLabel{
    CGFloat fontSize = lianzaiCellDescriLabelFontSize();
    LianZai *lianzai= self.orderedData.lianZai;
    if(self.descriLabel){
        if (!isEmptyString(lianzai.abstract)) {
            BOOL isBoldFont = [TTDeviceHelper isPadDevice];
            self.descriLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:fontSize] : [UIFont tt_fontOfSize:fontSize];
            self.descriLabel.text = lianzai.abstract;
        } else {
            self.descriLabel.text = nil;
        }

    }
}


- (void)updateShowMoreLabel{
    CGFloat fontSize = lianzaiCellShowMoreLabelFontSize();
    LianZai *lianzai= self.orderedData.lianZai;
    if (self.showMoreLabel) {
        if (!isEmptyString(lianzai.showMoreText)) {
            BOOL isBoldFont = [TTDeviceHelper isPadDevice];
            self.showMoreLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:fontSize] : [UIFont tt_fontOfSize:fontSize];
            self.showMoreLabel.text = lianzai.showMoreText;
        } else {
            self.showMoreLabel.attributedText = nil;
        }
    }
}

- (void)updatePic{
    LianZai *lianzai = self.orderedData.lianZai;
    [self.coverImageView setImageWithModel:lianzai.coverImageModel placeholderView:nil];
}

- (void)refreshWithData:(id)data{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if(self.originalData && self.orderedData.managedObjectContext){
        LianZai *lianzai= self.orderedData.lianZai;
        if (lianzai && lianzai.managedObjectContext){
            [self updateContentColor];
            [self updateTitleLabel];
            [self updatePic];
            [self updateShowMoreLabel];
            [self updateDescriLabel];
        }
        else{
            self.lianzaiTitleLabel.height = 0;
        }
    }
}

- (void)refreshUI{
    //原来的label不用，用SSThemedLabel
    self.titleLabel.hidden = YES;
    
    LianZai *lianzai = nil;
    ExploreOrderedData *orderedData = self.orderedData;
    
    if (orderedData && [orderedData lianZai]) {
        lianzai = orderedData.lianZai;
        if ([orderedData preCellHasBottomPadding]) {
            CGRect bounds = self.bounds;
            bounds.origin.y = 0;
            self.bounds = bounds;
            self.topRect.hidden = YES;
        } else {
            CGRect bounds = self.bounds;
            bounds.origin.y = -kCellSeprateViewHeight();
            self.bounds = bounds;
            self.topRect.bottom = 0;
            self.topRect.width = self.width;
            self.topRect.hidden = NO;
        }
        
        if (!([orderedData nextCellHasTopPadding])) {
            self.bottomRect.bottom = self.height + self.bounds.origin.y;
            self.bottomRect.width = self.width;
            self.bottomRect.hidden = NO;
        }
        else{
            self.bottomRect.hidden = YES;
        }
    }
    else{
        return;
    }

    CGFloat containWidth = self.width - kCellLeftPadding - kCellRightPadding;

    CGFloat picX = 0;
    CGFloat picY = cellPicTopPaddingWithLianZai();
    CGFloat picWidth = lianzaiCellPicWidth();
    CGFloat picHeight = ceil(picWidth * 4 / 3);
    
    CGFloat titleX = 0;
    //图片的上边缘和title字的上边缘一致
    CGFloat titleY = picY - ceil((kCellTitleLineHeight - [UIFont systemFontOfSize:kCellTitleLabelFontSize].lineHeight + kCellTitleLineHeight - [UIFont systemFontOfSize:kCellTitleLabelFontSize].pointSize) / 2.0);
    CGFloat titleWidth = 0;
    
    //serial_style ＝ 1 表示图在右，其它表示图在左
    BOOL isPicOnRight = [lianzai.serialStyle intValue] == 1;
    if (isPicOnRight) {
        /* 图片在右时 */
        titleX = kCellLeftPadding;
        titleWidth = containWidth - lianzaiCellLeftPaddingToPic() - picWidth;
        picX = self.width - kCellRightPadding - picWidth;
    }
    else{
        /* 图片在左时 */
        titleX = kCellLeftPadding + picWidth + lianzaiCellRightPaddingToPic();
        titleWidth = containWidth - lianzaiCellRightPaddingToPic() - picWidth;
        picX = kCellLeftPadding;
    }
    
    CGFloat y = titleY;
    //标题
    CGFloat titleLabelHeight = [TTLabelTextHelper heightOfText:lianzai.title fontSize:kCellTitleLabelFontSize forWidth:titleWidth forLineHeight:kCellTitleLineHeight constraintToMaxNumberOfLines:kCellLianZaiTitleLabelMaxLine firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.lianzaiTitleLabel.frame = CGRectMake(titleX, y, titleWidth, titleLabelHeight);
    y += titleLabelHeight + lianzaiCellBottomPaddingToTitleForDescriLabel();
    
    //摘要
    float descriLabelHeight = [TTLabelTextHelper heightOfText:lianzai.abstract fontSize:lianzaiCellDescriLabelFontSize() forWidth:titleWidth forLineHeight:lianzaiCellDescriLabelLineHeight() constraintToMaxNumberOfLines:kLianZaiCellDescriptionLabelMaxLine firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.descriLabel.frame = CGRectMake(titleX, y, titleWidth, descriLabelHeight);
    y += descriLabelHeight + lianzaiCellDescriLabelAndShowMoreInterval();
    
    //继续阅读
    float showMoreLabelHeight = lianzaiCellShowMoreLabelFontSize();
    [self.showMoreLabel sizeToFit];
    [self.showMoreImageView sizeToFit];
    CGFloat showMoreLabelWidth = MIN(_showMoreLabel.width, titleWidth - 50 - _showMoreImageView.width);
    self.showMoreLabel.frame = CGRectMake(titleX, y, showMoreLabelWidth, showMoreLabelHeight);
    
    //继续阅读icon
    
    self.showMoreImageView.centerY = self.showMoreLabel.centerY;
    self.showMoreImageView.left = self.showMoreLabel.right + lianzaiCellShowMoreIconLeftPaddingForShowMoreLabel();
    
    //封面
    self.coverImageView.frame = CGRectMake(picX, picY, picWidth, picHeight);
    
    self.bottomLineView.hidden = YES;
    
    [self layoutUnInterestedBtn];
    [self reloadThemeUI];
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    _lianzaiTitleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    _lianzaiTitleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
    _descriLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];

}

/*重载父类的方法*/
- (void)fontSizeChanged
{
    _lianzaiTitleLabel.font = [UIFont systemFontOfSize:kCellTitleLabelFontSize];
    _descriLabel.font = [UIFont systemFontOfSize:lianzaiCellDescriLabelFontSize()];
    _showMoreLabel.font = [UIFont systemFontOfSize:lianzaiCellShowMoreLabelFontSize()];
    [self refreshUI];
}

- (void)layoutUnInterestedBtn
{
    CGFloat centerX = self.lianzaiTitleLabel.width - kCellUninterestedButtonWidth / 2;
    CGPoint p = CGPointMake(centerX, self.showMoreLabel.height / 2);
    p = [self convertPoint:p fromView:self.showMoreLabel];
    self.unInterestedButton.center = p;
}

- (void)setLabelsColorClear:(BOOL)clear{
    [super setLabelsColorClear:clear];
    UIColor *color;
    
    if (clear) {
        color = [UIColor clearColor];
    } else {
        color = [TTUISettingHelper cellViewBackgroundColor];
    }
    
    _lianzaiTitleLabel.backgroundColor = color;
    _descriLabel.backgroundColor = color;
    _showMoreLabel.backgroundColor = color;
    _showMoreImageView.backgroundColor = color;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (!newValue || [newValue isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    if ([oldValue isKindOfClass:[NSNull class]] || ([oldValue isKindOfClass:[NSNumber class]] && [newValue isKindOfClass:[NSNumber class]] && ![oldValue isEqualToNumber:newValue])) {
        if([keyPath isEqualToString:@"hasRead"])
        {
            _lianzaiTitleLabel.highlighted = [newValue boolValue];
        }
    }
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    LianZai *lianzai = self.orderedData.lianZai;
    if(lianzai != nil){
        lianzai.hasRead = @(YES);
        [lianzai save];
        
        NSURL *lianzaiURL = [TTStringHelper URLWithURLString:lianzai.openURL];
        if ([[TTRoute sharedRoute] canOpenURL:lianzaiURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:lianzaiURL];
            wrapperTrackEventWithCustomKeys(@"feed_novel", @"feed_novel_click", [NSString stringWithFormat:@"%@", lianzai.serialID], nil, nil);
        }
    }
}

@end
