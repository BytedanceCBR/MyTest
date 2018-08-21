//
//  TTADActionView.m
//  Article
//
//  Created by 杨心雨 on 16/8/24.
//
//

#import "TTADActionView.h"

#import "TTArticleCellHelper.h"
#import "TTLayOutCellDataHelper.h"


@interface TTADActionView ()
@property (nonatomic, assign) CGFloat rightWidth;
@end

@implementation TTADActionView
/** 框架 */
- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        [self layoutADActionView];
    }
}

/** 创意广告下载左侧分割线 */
- (SSThemedView *)separatorView {
    if (_separatorView == nil) {
        _separatorView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 1, 16)];
        _separatorView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_separatorView];
    }
    return _separatorView;
}

/// 来源文字
- (SSThemedLabel *)sourceLabel {
    if (_sourceLabel == nil) {
        _sourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.textColorThemeKey = kColorText3;
        _sourceLabel.font = [UIFont tt_fontOfSize:15.0f];
        _sourceLabel.backgroundColor = [UIColor clearColor];
        _sourceLabel.numberOfLines = 1;
        [self addSubview:_sourceLabel];
    }
    return _sourceLabel;
}

/**
 信息栏控件初始化方法
 
 - parameter frame: 信息栏控件框架
 
 - returns: 信息栏控件实例
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground3;
    }
    return self;
}

/**
 信息栏控件布局
 */
- (void)layoutADActionView {
    CGFloat rightWidth = 90.0f;
    const CGFloat subtitleRight = 20.0f;
    const CGFloat subtitleLeft = 8.0f;
    
    if (self.actionButton) {
        rightWidth = CGRectGetWidth(self.actionButton.frame);
    }
    
    if (!self.sourceLabel.hidden) {
        [self.sourceLabel sizeToFit];
        const CGFloat sourceWidth = self.width -subtitleLeft - rightWidth - subtitleRight - 1;
        self.sourceLabel.frame = CGRectMake(subtitleLeft, floor((self.height - self.sourceLabel.height) / 2), sourceWidth , self.sourceLabel.height);
    }
    self.separatorView.origin = CGPointMake(self.width - rightWidth - 1 , floor((self.height - self.separatorView.height) / 2));
}

/**
 信息栏控件更新
 
 - parameter orderedData:  orderedData数据
 */
- (void)updateADActionView:(ExploreOrderedData *)orderedData {
    self.separatorView.hidden = NO;
    
    NSString *subtitle = [TTLayOutCellDataHelper getSubtitleStringWithOrderedData:orderedData];
    if (isEmptyString(subtitle)) {
        self.sourceLabel.text = @"";
        self.sourceLabel.hidden = YES;
    } else {
        self.sourceLabel.text = subtitle;
        self.sourceLabel.hidden = NO;
    }
    
    self.sourceLabel.userInteractionEnabled = [TTLayOutCellDataHelper isADSubtitleUserInteractive:orderedData];
    
    [self layoutADActionView];
}

@end
