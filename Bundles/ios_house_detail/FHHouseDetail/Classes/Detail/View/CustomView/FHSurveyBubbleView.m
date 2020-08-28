//
//  FHSurveyBubbleView.m
//  BubbleViewTest
//
//  Created by bytedance on 2020/8/25.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "FHSurveyBubbleView.h"
#import "UIFont+House.h"
#import <Masonry/Masonry.h>

@implementation MLLabel

- (void)drawRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsZero)];
}

@end

@interface FHSurveyBubbleView ()

@property(nonatomic,strong) UIImageView *arrowView;
@property(nonatomic,strong) UIImageView *titleView;
@property(nonatomic,strong) MLLabel *titleLabel;
@property(nonatomic,copy) NSString *titleName;
@property(nonatomic,strong) UIFont *textFont;
@property(nonatomic,assign) BOOL isPositive;

@end


@implementation FHSurveyBubbleView

-(instancetype)initWithTitle:(NSString *)titleName font:(UIFont *)font {
    self = [super init];
    if(self) {
        self.textFont = font;
        _titleName = titleName;
        [self initView];
    }
    return self;
}

- (void)initView {
    _titleView = [[UIImageView alloc] init];
    UIImage *backgroundImage = [UIImage imageNamed:@"surveyAgentBackgroud"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2 topCapHeight:backgroundImage.size.height/2];
    _titleView.image = backgroundImage;
    [self addSubview:_titleView];
    
    _titleLabel = [[MLLabel alloc] init];
    _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = self.textFont;
    _titleLabel.text = self.titleName;
    _titleLabel.textColor = [UIColor whiteColor];
    [_titleView addSubview:_titleLabel];

    _arrowView = [[UIImageView alloc] init];
    _arrowView.image = [UIImage imageNamed:@"surveyAgentArrow"];
    [self addSubview:_arrowView];
}

-(void)setLabelInsets:(UIEdgeInsets)labelInsets {
    _labelInsets = labelInsets;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.labelInsets);
    }];
}

- (CGSize)bubbleSize {
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentLeft;
    CGSize maxSize = CGSizeMake(self.maxWidth, MAXFLOAT);
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:self.titleName attributes:@{NSFontAttributeName:self.textFont, NSParagraphStyleAttributeName:style}];
    CGSize textSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return CGSizeMake(textSize.width + self.labelInsets.left + self.labelInsets.right, textSize.height + self.labelInsets.top + self.labelInsets.bottom + 8);
}

- (CGRect)calcFrameWithSubView:(UIView *)subview toView:(UIView *)view {
    CGFloat navBarHeight = 88;
    CGRect frame = subview.frame;
    CGPoint topMidPoint = CGPointMake(frame.size.width/2,0);
    CGPoint botMidPoint = CGPointMake(frame.size.width/2,frame.size.height);
    CGPoint point = [subview convertPoint:topMidPoint toView:view];
    CGSize bubbleSize = [self bubbleSize];
    if(point.y > navBarHeight + bubbleSize.height - 3 ) {
        self.isPositive = YES;
        return CGRectMake(point.x - (self.arrowOffset + 4), point.y - bubbleSize.height + 3, bubbleSize.width, bubbleSize.height);
    } else {
        point = [subview convertPoint:botMidPoint toView:view];
        self.isPositive = NO;
        return CGRectMake(point.x - (self.arrowOffset + 4), point.y - 3, bubbleSize.width, bubbleSize.height);
    }
}

- (void)updateView {
    if(self.isPositive) {
        [_titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.bottom.equalTo(self.arrowView.mas_top);
        }];
        _arrowView.transform = CGAffineTransformIdentity;
        [_arrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(8);
            make.bottom.equalTo(self);
            make.left.equalTo(self).offset(self.arrowOffset);
        }];
    } else {
        [_titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self.arrowView.mas_bottom);
        }];
        _arrowView.transform = CGAffineTransformMakeRotation(M_PI);
        [_arrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(8);
            make.top.equalTo(self);
            make.left.equalTo(self).offset(self.arrowOffset);
        }];
    }
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.labelInsets);
    }];
}


@end
