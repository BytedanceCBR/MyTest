//
//  ExploreDetailFontSettingView.m
//  Article
//
//  Created by 王双华 on 15/7/26.
//
//

#import "ExploreDetailFontSettingView.h"
#import "SSThemed.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTTracker/TTTracker.h>
//#import "TTTrackerWrapper.h"

#import <TTUserSettingsManager+FontSettings.h>
//#import "TTLogManager.h"
//#import "SSCommon+UIApplication.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTUserSettingsManager.h"

#define kFontViewScale          0.172
#define kEdgeMargin             (self.width * kFontViewScale)
#define kVerticalLineStartOriY  50.f
#define kFontSizeLabelFont      10.f
#define kVerticalLineHeight     6.f

@interface ExploreDetailFontSettingView ()

@property (nonatomic, strong) UIImageView *switcher;

@property (nonatomic, assign) BOOL shouldMove;
@property (nonatomic, assign) NSInteger beginSegIdx;    //起始点位置
@property (nonatomic, strong) UIImageView *minFontView;
@property (nonatomic, strong) UIImageView *maxFontView;
@property (nonatomic, strong) NSMutableArray *fontSizeArr;

@end

@implementation ExploreDetailFontSettingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _switcher = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"roll_typebar_details.png"]];
        _switcher.bounds = CGRectMake(0, 0, 20, 20);
        _switcher.centerY = kVerticalLineStartOriY + kVerticalLineHeight / 2;
        
        _minFontView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"asmall_typebar_details.png"]];
        _minFontView.bounds = CGRectMake(0, 0, 16, 16);
        _minFontView.centerY = kVerticalLineStartOriY + kVerticalLineHeight / 2;
        _minFontView.centerX = kEdgeMargin / 2;
        
        _maxFontView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"abig_typebar_details.png"]];
        _maxFontView.bounds = CGRectMake(0, 0, 16, 16);
        _maxFontView.centerY = kVerticalLineStartOriY + kVerticalLineHeight / 2;
        _maxFontView.centerX = self.width - kEdgeMargin / 2;
        
        _switcher.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _minFontView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _maxFontView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_minFontView];
        [self addSubview:_maxFontView];
        
        [self initFontSizeLabels];
        
        [self refreshFontSizeLabelsWithSegmentIndex:(NSInteger)[TTUserSettingsManager settingFontSize] forLeftAlpha:1 rightAlpha:0];
        [self refreshSwitcherFrameWithSegmentIndex:(NSInteger)[TTUserSettingsManager settingFontSize]];
        
        [self addSubview:_switcher];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [_fontSizeArr enumerateObjectsUsingBlock:^(UILabel * label, NSUInteger idx, BOOL *stop) {
        [label setTextColor:SSGetThemedColorWithKey(kColorText3)];
    }];
    //    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground15);
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, SSGetThemedColorWithKey(kColorLine9).CGColor);
    
    CGFloat singleSegmentLineWidth = (self.width - kEdgeMargin * 2) / 3;
    
    for (int idx = 0; idx < 4; idx++) {
        CGContextSetLineWidth(context, [TTDeviceHelper ssOnePixel] * 2);
        CGFloat x = kEdgeMargin + idx * singleSegmentLineWidth;
        if (idx == 0) {
            x += [TTDeviceHelper ssOnePixel];
        }
        if (idx == 3) {
            x -= [TTDeviceHelper ssOnePixel];
        }
        
        CGContextMoveToPoint(context, x, kVerticalLineStartOriY);
        CGContextAddLineToPoint(context, x, kVerticalLineStartOriY + kVerticalLineHeight);
    }
    
    for (int idx = 0; idx < 3; idx++) {
        CGContextSetLineWidth(context, [TTDeviceHelper ssOnePixel] * 2);
        CGContextMoveToPoint(context, kEdgeMargin + idx * singleSegmentLineWidth, kVerticalLineStartOriY + kVerticalLineHeight );
        CGContextAddLineToPoint(context, kEdgeMargin + (idx + 1) * singleSegmentLineWidth, kVerticalLineStartOriY + kVerticalLineHeight);
    }
    
    CGContextStrokePath(context);
}

- (void)refreshSwitcherFrameWithSegmentIndex:(NSInteger)segIdx
{
    CGFloat singleSegmentLineWidth = (self.width - kEdgeMargin * 2) / 3;
    segIdx = segIdx < 3 ? segIdx : 3;
    _switcher.centerX = kEdgeMargin + segIdx * singleSegmentLineWidth;
}

- (void)initFontSizeLabels
{
    const NSArray *fontSizeArray = @[NSLocalizedString(@"小", nil), NSLocalizedString(@"中", nil), NSLocalizedString(@"大", nil), NSLocalizedString(@"特大", nil)];
    _fontSizeArr = [NSMutableArray arrayWithCapacity:4];
    for (int idx = 0; idx < 4; idx++) {
        UILabel *fontSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSString *text = fontSizeArray[idx];
        UIFont *font = [UIFont systemFontOfSize:kFontSizeLabelFont];
        CGFloat width = ceilf([text sizeWithAttributes:@{NSFontAttributeName : font}].width);
        [fontSizeLabel setText:text];
        fontSizeLabel.width = width;
        fontSizeLabel.height = font.lineHeight;
        [fontSizeLabel setTextAlignment:NSTextAlignmentCenter];
        fontSizeLabel.centerY = kVerticalLineStartOriY - 5 - (_switcher.height) / 2;
        fontSizeLabel.centerX = kEdgeMargin + idx*(self.width - 2 * kEdgeMargin) / 3;
        [fontSizeLabel setFont:font];
        [_fontSizeArr addObject:fontSizeLabel];
        fontSizeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:fontSizeLabel];
    }
}

- (void)refreshFontSizeLabelsWithSegmentIndex:(NSInteger)leftIndex forLeftAlpha:(float)leftAlpha rightAlpha:(float)rightAlpha
{
    [_fontSizeArr enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        if (idx == leftIndex) {
            label.alpha = leftAlpha;
        }
        else if (idx == leftIndex + 1) {
            label.alpha = rightAlpha;
        }
        else {
            label.alpha = 0;
        }
    }];
}

- (void)refreshFontSize:(NSInteger)segIdx
{
    const NSArray * fontArray = @[@"font_small", @"font_middle", @"font_big", @"font_ultra_big"];
    NSString * eventID = nil;
    if (segIdx < fontArray.count) {
        eventID = fontArray[segIdx];
    } else {
        eventID = fontArray[0];
    }
    ttTrackEvent(@"detail", eventID);
    
    //详情页业务中收到notification后发送
    //    [TTLogManager logEvent:[NSString stringWithFormat:@"set_%@", eventID] context:nil screenName:nil];
    
    [TTUserSettingsManager setSettingFontSize:(int)segIdx];
}

- (void)refreshSwitcherFrameByFingleWithLocationX:(CGFloat)locationX
{
    if (locationX < kEdgeMargin) {
        locationX = kEdgeMargin;
    }
    else if (locationX > self.width - kEdgeMargin) {
        locationX = self.width - kEdgeMargin;
    }
    
    _switcher.centerX = locationX;
}

- (NSInteger)leftSegIdxByLocationX:(CGFloat)locationX
{
    if (locationX < kEdgeMargin) {
        return 0;
    }
    else if (locationX > self.width - kEdgeMargin) {
        return 3;
    }
    else {
        CGFloat singleSegmentLineWidth = (self.width - kEdgeMargin * 2) / 3;
        return (locationX - kEdgeMargin) / singleSegmentLineWidth;
    }
}

- (NSInteger)staySegIdxByLocationX:(CGFloat)locationX
{
    if (locationX < kEdgeMargin) {
        return 0;
    }
    else if (locationX > self.width - kEdgeMargin) {
        return 3;
    }
    else {
        CGFloat singleSegmentLineWidth = (self.width - kEdgeMargin * 2) / 3;
        return round((locationX - kEdgeMargin) / singleSegmentLineWidth);
    }
}

- (CGFloat)relativeWidthFromLeftIndexByLocationX:(CGFloat)locationX
{
    CGFloat singleSegmentLineWidth = (self.width - kEdgeMargin * 2) / 3;
    if (locationX < kEdgeMargin) {
        return 0;
    }
    else if (locationX > self.width - kEdgeMargin) {
        return singleSegmentLineWidth;
    }
    else {
        NSInteger leftIndex = (locationX - kEdgeMargin) / singleSegmentLineWidth;
        return locationX - kEdgeMargin - leftIndex * singleSegmentLineWidth;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(CGRectMake(kEdgeMargin - 15, kVerticalLineStartOriY - 15, self.width - kEdgeMargin * 2 + 30, 30), touchPoint) || CGRectContainsPoint(_switcher.bounds, touchPoint))
    {
        _beginSegIdx = [self leftSegIdxByLocationX: _switcher.centerX];
        _shouldMove = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //随手移动
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (_shouldMove) {
        if (CGRectContainsPoint(self.bounds, touchPoint)) {
            [self refreshSwitcherFrameByFingleWithLocationX:touchPoint.x];
            CGFloat singleSegmentLineWidth = (self.width - kEdgeMargin * 2) / 3;
            CGFloat marginFromLeftIndex = [self relativeWidthFromLeftIndexByLocationX:touchPoint.x];
            
            float leftAlpha = (singleSegmentLineWidth - marginFromLeftIndex) /singleSegmentLineWidth;
            float rightAlpha = marginFromLeftIndex /singleSegmentLineWidth;
            [self refreshFontSizeLabelsWithSegmentIndex:[self leftSegIdxByLocationX:touchPoint.x] forLeftAlpha:leftAlpha rightAlpha:rightAlpha];
        }
        else {
            [self touchesCancelled:touches withEvent:event];
        }
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //回到节点位置
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    NSInteger endSegIdx = [self staySegIdxByLocationX:touchPoint.x];
    if (_shouldMove) {
        [UIView animateWithDuration:0.1 animations:^{
            [self refreshSwitcherFrameWithSegmentIndex:endSegIdx];
        }completion:^(BOOL finished) {
            [self refreshFontSizeLabelsWithSegmentIndex:endSegIdx forLeftAlpha:1.f rightAlpha:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refreshFontSize:endSegIdx];
            });
        }];
    }
    _shouldMove = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_shouldMove) {
        [UIView animateWithDuration:0.25 animations:^{
            [self refreshSwitcherFrameWithSegmentIndex:_beginSegIdx];
        }
                         completion:^(BOOL finished) {
                             [self refreshFontSizeLabelsWithSegmentIndex:_beginSegIdx forLeftAlpha:1.f rightAlpha:0];
                         }];
        
    }
    _shouldMove = NO;
}

- (void)dismiss
{
    [self removeFromSuperview];
}

@end

