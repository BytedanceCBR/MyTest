//
//  TTArticleInfoView.m
//  Article
//
//  Created by 杨心雨 on 16/8/22.
//
//

#import "TTArticleInfoView.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "ExploreCellHelper.h"
#import "UIButton+TTAdditions.h"
#import "TTBusinessManager+StringUtils.h"

@implementation TTArticleInfoView

/// 框架
- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        [self layoutInfoView];
    }
}

- (BOOL)hideTimeLabel {
    return self.timeLabel.hidden;
}

- (void)setHideTimeLabel:(BOOL)hideTimeLabel {
    self.timeLabel.hidden = hideTimeLabel;
}

/// 分类标签
- (TTArticleTagView *)typeIconView {
    if (_typeIconView == nil) {
        _typeIconView = [[TTArticleTagView alloc] init];
        [self addSubview:_typeIconView];
    }
    return _typeIconView;
}

/// 点赞按钮
- (TTDiggButton *)digButton {
    if (_digButton == nil) {
        _digButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeBothSmall];
        _digButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        _digButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        WeakSelf;
        [_digButton setClickedBlock:^(TTDiggButtonClickType type) {
            StrongSelf;
            [self digButtonClicked];
        }];
        [self addSubview:_digButton];
    }
    return _digButton;
}

/// 评论按钮
- (TTAlphaThemedButton *)commentButton {
    if (_commentButton == nil) {
        _commentButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _commentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _commentButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        _commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [_commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents: UIControlEventTouchUpInside];
        _commentButton.titleLabel.font = [UIFont tt_fontOfSize:kInfoViewFontSize()];
        _commentButton.titleColorThemeKey = kColorText9;
        _commentButton.backgroundColor = [UIColor clearColor];
        _commentButton.imageName = @"comment_icon_old";
        _commentButton.enableHighlightAnim = YES;
//        _commentButton.selectedImageName = "comment_icon_old_press"
        _commentButton.hitTestEdgeInsets = UIEdgeInsetsMake(-16, 0, -16, -16);
        _commentButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_commentButton];
    }
    return _commentButton;
}

/// 发布时间
- (SSThemedLabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColorThemeKey = kColorText9;
        _timeLabel.font = [UIFont tt_fontOfSize:11];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.numberOfLines = 1;
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
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

/** 更新点赞按钮 */
- (void)refreshDiggButton:(ExploreOrderedData *)orderedData {
    int64_t likeCount = 0;
    if ([[[orderedData article] likeCount] longLongValue]) {
        likeCount = [[[orderedData article] likeCount] longLongValue];
    }
    [self.digButton setDiggCount:likeCount];
    if ([[[orderedData article] userLike] boolValue] == YES) {
        self.digButton.selected = YES;
    } else {
        self.digButton.selected = NO;
    }
}
    
/**
 更新评论按钮
 
 - parameter commentModel: commentModel数据
 */
- (void)refreshCommentButton:(ExploreOrderedData *)orderedData {
    int64_t cmtCnt = 0;
    if ([[orderedData article] commentCount]) {
        cmtCnt = [[orderedData article] commentCount];
    }
    NSString *commentTitle = (cmtCnt > 0 ? [TTBusinessManager formatCommentCount:cmtCnt] : NSLocalizedString(@"评论", nil));
    [self.commentButton setTitle:commentTitle forState:UIControlStateNormal];
}

- (void)digButtonClicked {
    [self.delegate digButtonClick:self.digButton];
}

- (void)commentButtonClicked {
    [self.delegate commentButtonClick];
}

/**
 信息栏控件布局
 */
- (void)layoutInfoView {
    CGFloat leftMargin = 0;
    
    // layout typeIconView
    if (!self.typeIconView.hidden && self.typeIconView.width > 0) {
        self.typeIconView.left = leftMargin;
        self.typeIconView.centerY = ceil(self.height / 2);
        leftMargin += self.typeIconView.width + 5;
    }
    
    // layout digButton
    if (!self.digButton.hidden) {
        [self.digButton sizeToFit];
        self.digButton.frame = CGRectMake(leftMargin, 0, self.digButton.width, kInfoViewHeight());
        leftMargin += 60;
    }
    
    // layout commentButton
    if (!self.commentButton.hidden) {
        [self.commentButton sizeToFit];
        self.commentButton.frame = CGRectMake(leftMargin, 0, self.commentButton.width, kInfoViewHeight());
    }
    
    // layout timeLabel
    if (!self.timeLabel.hidden) {
        self.timeLabel.frame = CGRectMake(self.width - self.timeLabel.width, 0, self.timeLabel.width, kInfoViewHeight());
    }
}

/**
 信息栏控件更新
 
 - parameter orderedData:  orderedData数据
 */
- (void)updateInfoView:(ExploreOrderedData *)orderedData {
    [self.typeIconView updateTypeIcon:orderedData];
    
    if ([orderedData isShowDigButton]) {
        self.digButton.hidden = NO;
        [self refreshDiggButton:orderedData];
    } else {
        self.digButton.hidden = YES;
    }
    
    if ([orderedData isShowComment]) {
        self.commentButton.hidden = NO;
        [self refreshCommentButton:orderedData];
    } else {
        self.commentButton.hidden = YES;
    }
    
    if (!self.timeLabel.hidden) {
//        NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance]midInterval];
        if ([orderedData behotTime] > 0) {
            NSTimeInterval time = [orderedData behotTime];
            NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
//            NSString *publishTime = (midnightInterval > 0 ? [TTBusinessManager customtimeStringSince1970:time midnightInterval:midnightInterval] : [TTBusinessManager customtimeStringSince1970:time]);
            if (!isEmptyString(publishTime)) {
                self.timeLabel.text = publishTime;
                [self.timeLabel sizeToFit];
            } else {
                self.timeLabel.text = @"";
            }
        }
    }
    [self layoutInfoView];
}

@end
