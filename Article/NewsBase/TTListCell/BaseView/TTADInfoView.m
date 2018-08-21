//
//  TTADInfoView.m
//  Article
//
//  Created by 杨心雨 on 16/8/22.
//
//

#import "TTADInfoView.h"

#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTDeviceHelper.h"
#import "TTLayOutCellDataHelper.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"

/// 信息栏控件
@implementation TTADInfoView

/// 框架
- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        [self layoutInfoView];
    }
}

/// 分类标签
- (TTArticleTagView *)typeIconView {
    if (_typeIconView == nil) {
        _typeIconView = [[TTArticleTagView alloc] init];
        [self addSubview:_typeIconView];
    }
    return _typeIconView;
}

/// 来源文字
- (SSThemedLabel *)sourceLabel {
    if (_sourceLabel == nil) {
        _sourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.textColorThemeKey = kColorText3;
        _sourceLabel.font = [UIFont tt_fontOfSize:kCellInfoLabelFontSize];
        _sourceLabel.backgroundColor = [UIColor clearColor];
        _sourceLabel.numberOfLines = 1;
        [self addSubview:_sourceLabel];
    }
    return _sourceLabel;
}

/** 来源图片 */
- (TTImageView *)sourceImageView {
    if (_sourceImageView == nil) {
        _sourceImageView = [[TTImageView alloc] init];
        _sourceImageView.borderColorThemeKey = kSourceViewImageBorderColor();
        _sourceImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _sourceImageView.backgroundColorThemeKey = kSourceViewImageBackgroundColor();
        _sourceImageView.imageContentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_sourceImageView];
    }
    return _sourceImageView;
}

/// 评论数
- (SSThemedLabel *)commentLabel {
    if (_commentLabel == nil) {
        _commentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _commentLabel.textColorThemeKey = kColorText3;
        _commentLabel.font = [UIFont tt_fontOfSize:kCellInfoLabelFontSize];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.numberOfLines = 1;
        [self addSubview:_commentLabel];
    }
    return _commentLabel;
}

/// 发布时间
- (SSThemedLabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColorThemeKey = kColorText3;
        _timeLabel.font = [UIFont tt_fontOfSize:kCellInfoLabelFontSize];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.numberOfLines = 1;
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (SSThemedImageView *)locationIcon{
    if (_locationIcon == nil) {
        _locationIcon = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _locationIcon.imageName = @"lbs_ad_feed";
        [self addSubview:_locationIcon];
    }
    return _locationIcon;
}

- (SSThemedLabel *)locationLabel{
    
    if (_locationLabel == nil) {
        _locationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _locationLabel.textColorThemeKey = kColorText3;
        _locationLabel.font = [UIFont tt_fontOfSize:kCellInfoLabelFontSize];
        _locationLabel.backgroundColor = [UIColor clearColor];
        _locationLabel.numberOfLines = 1;
        [self addSubview:_locationLabel];
    }
    
    return _locationLabel;
}

/**
 信息栏控件初始化方法
 
 - parameter frame: 信息栏控件框架
 
 - returns: 信息栏控件实例
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)refreshCommentLabel:(ExploreOrderedData *)orderedData {
    NSString *commentTitle = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:[[orderedData originalData] commentCount]], NSLocalizedString(@"评论", nil)];
    self.commentLabel.text = commentTitle;
}

/**
 信息栏控件布局
 */
- (void)layoutInfoView{
    CGFloat left = 0, margin = 6, right = 30 + 12 , locationMargin = 4.f;
    CGFloat maxWidth = self.width;
    // layout typeIconView
    if (!self.typeIconView.hidden && self.typeIconView.width > 0) {
        self.typeIconView.left = left;
        self.typeIconView.centerY = ceil(self.height / 2);
        left += self.typeIconView.width + margin;
    }
    
    
    if (!self.locationIcon.hidden && !self.locationLabel.hidden && self.orderedData && self.orderedData.article && [self.orderedData.adModel isCreativeAd]) {
        
        maxWidth = self.width - left - right;
        
        CGFloat adLocationIconMaxWidth = maxWidth;
        if (adLocationIconMaxWidth > KCellADLocationIconWidth) {
            
            CGFloat adLocationIconOriginY = self.height - KCellADLocationIconHeight - 2;
            self.locationIcon.frame = CGRectMake(left, adLocationIconOriginY, KCellADLocationIconWidth, KCellADLocationIconHeight);
            self.locationLabel.centerY = ceil(self.height / 2);
            left += KCellADLocationIconWidth;
            left += locationMargin;
        }
        
        for (NSInteger index = 0; index <= 2; index++) {
            
            NSString *adLocationStr = [TTLayOutCellDataHelper getAdLocationStringForUnifyADCellWithOrderData:self.orderedData WithIndex:index];
            
            if (!isEmptyString(adLocationStr)) {
                
                maxWidth = self.width - left - right;
                
                CGFloat adLocationLabelMaxWidth = maxWidth;
                
                NSString *fixAdLocationStr =  [adLocationStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (adLocationLabelMaxWidth > 0 && !isEmptyString(fixAdLocationStr)) {
                    
                    CGSize adLocationLabelSize =  [fixAdLocationStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kCellInfoLabelFontSize]}];
                    
                    if (adLocationLabelMaxWidth >= adLocationLabelSize.width || index == 2) {
                        
                        
                        adLocationLabelSize = CGSizeMake(MIN(adLocationLabelMaxWidth, ceilf(adLocationLabelSize.width)), ceilf(adLocationLabelSize.height));
                        CGFloat adLocationLabelOriginY = self.height - adLocationLabelSize.height;
                        
                        self.locationLabel.frame = CGRectMake(left, adLocationLabelOriginY, adLocationLabelSize.width, adLocationLabelSize.height);
                        self.locationLabel.centerY = ceil(self.height / 2);
                        self.locationLabel.text = fixAdLocationStr;
                        
                        left += adLocationLabelSize.width;
                        left += locationMargin;
                        
                        break;
                    }
                }
            }
        }
        
    }
    
    else {
        
        if (!self.sourceLabel.hidden) {
            [self.sourceLabel sizeToFit];
            maxWidth = self.width - left - right;
            self.sourceLabel.frame = CGRectMake(left, 0, MIN(maxWidth, self.sourceLabel.width), kInfoViewHeight());
            left += (self.sourceLabel.width + margin);
        }
        
        // layout commentLabel
        if (!self.commentLabel.hidden) {
            [self.commentLabel sizeToFit];
            maxWidth = self.width - left - right;
            if (self.commentLabel.width <= maxWidth) {
                self.commentLabel.frame = CGRectMake(left, 0, self.commentLabel.width, kInfoViewHeight());
                left += (self.commentLabel.width + margin);
            } else {
                self.commentLabel.frame = CGRectZero;
            }
        }
        
        // layout timeLabel
        if (!self.timeLabel.hidden) {
            [self.timeLabel sizeToFit];
            maxWidth = self.width - left - right;
            if (self.timeLabel.width <= maxWidth) {
                self.timeLabel.frame = CGRectMake(left, 0, self.timeLabel.width, kInfoViewHeight());
                left += (self.timeLabel.width + margin);
            } else {
                self.timeLabel.frame = CGRectZero;
            }
        }
    }
    
}

/**
 信息栏控件更新
 
 - parameter orderedData:  orderedData数据
 */
- (void)updateInfoView:(ExploreOrderedData *)orderedData {
    
    self.orderedData = orderedData;
    
    [self.typeIconView updateTypeIcon:orderedData];
    
    NSString *sourceName = [TTLayOutCellDataHelper getADSourceStringWithOrderedDada:orderedData];

    BOOL isShowLocationStr = [TTLayOutCellDataHelper isAdShowLocation:self.orderedData];
    if (isShowLocationStr) {
        
        self.sourceLabel.text = @"";
        self.sourceLabel.hidden = YES;
        
        self.commentLabel.text = @"";
        self.commentLabel.hidden = YES;
        
        self.timeLabel.text = @"";
        self.timeLabel.hidden = YES;
    
        self.locationIcon.hidden = NO;
        self.locationLabel.hidden = NO;
        
    } else {
        
        self.locationIcon.hidden = YES;
        self.locationLabel.hidden = YES;
       
        if(!sourceName) {
            sourceName = [[orderedData article] source];
        }
        
        if (isEmptyString(sourceName) || ![TTLayOutCellDataHelper isAdShowSourece:orderedData]) {
            self.sourceLabel.text = @"";
            self.sourceLabel.hidden = YES;
        } else {
            self.sourceLabel.text = sourceName;
            self.sourceLabel.hidden = NO;
        }
        
        if ([orderedData isShowComment]) {
            self.commentLabel.hidden = NO;
            [self refreshCommentLabel:orderedData];
        } else {
            self.commentLabel.text = @"";
            self.commentLabel.hidden = YES;
        }
        
        NSString *publishTime = nil;
        //    NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
        if ([orderedData behotTime] > 0) {
            NSTimeInterval time = [orderedData behotTime];
            publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
            //        publishTime = (midnightInterval > 0 ? [TTBusinessManager customtimeStringSince1970:time midnightInterval:midnightInterval] : [TTBusinessManager customtimeStringSince1970:time]);
        }
        if (!isEmptyString(publishTime)) {
            self.timeLabel.text = publishTime;
            self.timeLabel.hidden = NO;
        } else {
            self.timeLabel.text = @"";
            self.timeLabel.hidden = YES;
        }
    }
    
    [self layoutInfoView];
}

- (NSArray<NSString *> *)randomSourceBackgroundColors {
    int index = arc4random() % 5;
    switch (index) {
        case 0:
            return @[@"90ccff", @"48667f"];
        case 1:
            return @[@"cccccc", @"666666"];
        case 2:
            return @[@"bfa1d0", @"5f5068"];
        case 3:
            return @[@"80c184", @"406042"];
        case 4:
            return @[@"e7ad90", @"735648"];
        default:
            return @[@"ff9090", @"7f4848"];
    }
}

@end
