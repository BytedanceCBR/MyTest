//
//  TTArticleCommentView.m
//  Article
//
//  Created by 杨心雨 on 16/8/23.
//
//

#import "TTArticleCommentView.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "NSString-Extension.h"

/// 评论控件
@implementation TTArticleCommentView

@synthesize font = _font;

/// 框架
- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        [self layoutComment];
    }
}

/// 评论
- (SSThemedLabel *)commentView {
    if (_commentView == nil) {
        _commentView = [[SSThemedLabel alloc] init];
        _commentView.frame = CGRectMake(0, 0, self.width, self.height);
        _commentView.font = [UIFont tt_fontOfSize:kCommentViewFontSize()];
        _commentView.textColorThemeKey = kCommentViewTextColor();
        _commentView.backgroundColor = [UIColor clearColor];
        _commentView.numberOfLines = kCommentViewLineNumber();
        _commentView.lineBreakMode = NSLineBreakByTruncatingTail;
        _commentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_commentView];
    }
    return _commentView;
}

/// 评论字体
- (UIFont *)font {
    return self.commentView.font;
}

- (void)setFont:(UIFont *)font {
    self.commentView.font = font;
}

//lazy var userRange = NSMakeRange(0, 0)

/**
 评论控件初始化方法
 
 - parameter frame: 评论控件框架
 
 - returns: 评论控件实例
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

/**
 评论控件布局
 */
- (void)layoutComment {
    CGFloat correct = self.lineHeight - self.commentView.font.pointSize;
    self.commentView.height = self.height + ceil(correct);
    self.commentView.bottom = self.height + round(correct / 2);
}

/**
 评论控件更新
 
 - parameter orderedData: OrderedData数据
 */
- (void)updateComment:(ExploreOrderedData *)orderedData {
    if ([orderedData article]) {
        if ([[orderedData article] displayComment]) {
            self.lineHeight = kCommentViewLineHeight();
            NSString *commentText = [[orderedData article] commentContent];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[commentText tt_attributedStringWithFont:[UIFont tt_fontOfSize:kCommentViewFontSize()] lineHeight:kCommentViewLineHeight()]];
            self.commentView.attributedText = attributedString;
        } else {
            self.commentView.text = @"";
        }
        [self updateCommentState:[[[orderedData originalData] hasRead] boolValue]];
        [self layoutComment];
    }
}

/** 更新评论阅读状态 */
- (void)updateCommentState:(BOOL)hasRead {
    self.commentView.highlighted = hasRead;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
//    if let attributedString = self.commentView.attributedText as? NSMutableAttributedString {
//        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.tt_themedColorForKey(kCommentViewUserTextColor()), range: self.userRange)
//        self.commentView.attributedText = attributedString
//        self.commentView.setNeedsDisplay()
//    }
}

@end
