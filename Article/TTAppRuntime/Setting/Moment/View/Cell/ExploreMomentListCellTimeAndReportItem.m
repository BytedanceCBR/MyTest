//
//  ExploreMomentListCellTimeAndReportItem.m
//  Article
//
//  Created by 冯靖君 on 16/7/13.
//
//

#import "ExploreMomentListCellTimeAndReportItem.h"
#import "TTDeviceUIUtils.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIButton+TTAdditions.h"


#define kMomentCellItemViewLeftPadding      [TTDeviceUIUtils tt_paddingForMoment:60]
#define kUserViewTopPadding                 [TTDeviceUIUtils tt_paddingForMoment:24]
#define kUserViewVerticalGap                [TTDeviceUIUtils tt_paddingForMoment:2]
#define kTopPadding                         8.f

@implementation ExploreMomentListCellTimeAndReportItem

- (instancetype)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        _timeLabel.numberOfLines = 1;
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
        
        _reportButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _reportButton.titleLabel.font = _timeLabel.font;
        [_reportButton setTitle:@" · 举报" forState:UIControlStateNormal];
        [_reportButton sizeToFit];
        _reportButton.hitTestEdgeInsets = UIEdgeInsetsMake(-6, -8, -8, -8);
        [_reportButton addTarget:self action:@selector(reportButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reportButton];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _timeLabel.textColor = [UIColor tt_themedColorForKey:kColorText13];
    [_reportButton setTitleColor:_timeLabel.textColor forState:UIControlStateNormal];
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
        NSString * timeLabelStr = [TTBusinessManager customtimeStringSince1970:model.createTime];
    if (!isEmptyString(model.deviceModelString)) {
        timeLabelStr = [NSString stringWithFormat:@"%@  %@", timeLabelStr, model.deviceModelString];
    }
    [_timeLabel setText:timeLabelStr];
    [_timeLabel sizeToFit];
    _timeLabel.origin = CGPointMake(kMomentCellItemViewLeftPadding, kTopPadding);
    
    self.reportButton.left = _timeLabel.right;
    self.reportButton.centerY = _timeLabel.centerY;
}

- (void)reportButtonClicked
{
    if (self.trigReportActionBlock) {
        self.trigReportActionBlock();
    }
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellTimeAndReportItem heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (![self needShowForModel:model userInfo:uInfo]) {
        return 0;
    }
 
    UILabel *tempLabel = [UILabel new];
    tempLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
    tempLabel.numberOfLines = 1;
    NSString * timeLabelStr = [TTBusinessManager customtimeStringSince1970:model.createTime];
    tempLabel.text = timeLabelStr;
    [tempLabel sizeToFit];
    return tempLabel.height + kTopPadding;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    return YES;
}

@end
