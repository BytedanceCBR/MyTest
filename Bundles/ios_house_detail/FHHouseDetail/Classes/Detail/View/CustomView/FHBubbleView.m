//
//  FHBubbleView.m
//  BubbleViewTest
//
//  Created by bytedance on 2020/8/25.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "FHBubbleView.h"
#import "UIFont+House.h"
#import <Masonry/Masonry.h>

@interface FHBubbleView ()

@property(nonatomic,strong) UIImageView *arrowView;
@property(nonatomic,strong) UIImageView *titleView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,copy) NSString *titleName;
@property(nonatomic,strong) UIFont *textFont;

@end


@implementation FHBubbleView

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
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = self.textFont;
    _titleLabel.text = self.titleName;
    _titleLabel.textColor = [UIColor whiteColor];
    [_titleView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(6, 8, 7, 8));
    }];
    
    _arrowView = [[UIImageView alloc] init];
    _arrowView.image = [UIImage imageNamed:@"surveyAgentArrow"];
    [self addSubview:_arrowView];
}


- (CGSize)bubbleSize {
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentLeft;
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:self.titleName attributes:@{NSFontAttributeName:self.textFont, NSParagraphStyleAttributeName:style}];
    CGSize maxSize = CGSizeMake(220, MAXFLOAT);
    CGSize textSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return CGSizeMake(textSize.width+16, textSize.height+21);
}



-(void)showWithsubView:(UIView *)subview toView:(UIView *)view {
    CGFloat navBarHeight = 88;
    CGFloat arrowOffset = 14;
    CGRect frame = subview.frame;
    CGPoint topMidPoint = CGPointMake(frame.size.width/2,0);
    CGPoint botMidPoint = CGPointMake(frame.size.width/2,frame.size.height);
    CGPoint point = [subview convertPoint:topMidPoint toView:view];
    CGSize bubbleSize = [self bubbleSize];
    if(point.y > navBarHeight + bubbleSize.height) {
        [_titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.bottom.equalTo(self.arrowView.mas_top);
        }];
        _arrowView.transform = CGAffineTransformIdentity;
        [_arrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(8);
            make.bottom.equalTo(self);
            make.left.equalTo(self).offset(arrowOffset);
        }];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(bubbleSize.width);
            make.height.mas_equalTo(bubbleSize.height);
            make.left.mas_equalTo(view).offset(point.x-(arrowOffset+4));
            make.bottom.mas_equalTo(view.mas_top).offset(point.y);
        }];
    } else {
        point = [subview convertPoint:botMidPoint toView:view];
        [_titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self.arrowView.mas_bottom);
        }];
        _arrowView.transform = CGAffineTransformMakeRotation(M_PI);
        [_arrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(8);
            make.top.equalTo(self);
            make.left.equalTo(self).offset(arrowOffset);
        }];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(bubbleSize.width);
            make.height.mas_equalTo(bubbleSize.height);
            make.left.mas_equalTo(view).offset(point.x-(arrowOffset+4));
            make.top.mas_equalTo(view.mas_top).offset(point.y);
        }];
    }
}




@end
