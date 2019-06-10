//
//  ArticleEssayActionButton.m
//  Article
//
//  Created by Yu Tianhang on 13-2-27.
//
//

#import "ArticleEssayActionButton.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

@implementation ArticleEssayActionButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.minWidth = 51.f;
        self.minHeight = kEssayActionButtonH;
        self.maxWidth = 1000.0f;
        
        CGFloat fontSize = /*[TTDeviceHelper isPadDevice] ? 12.f :*/ 12.f;
        [self setFont:[UIFont systemFontOfSize:fontSize] forState:UIControlStateNormal];
        //[self setFont:[UIFont boldSystemFontOfSize:fontSize] forState:UIControlStateSelected];
        //self.backgroundColor = [UIColor cyanColor];
    }
    return self;
}

- (void)updateThemes {
//    self.backgroundColor = [UIColor clearColor];
    //if (![TTDeviceHelper isPadDevice]) {
    UIColor *normalColor = [UIColor tt_themedColorForKey:kColorText3];
    [self setTitleColor:normalColor forState:UIControlStateNormal];
    
    UIColor *selectedColor = [UIColor tt_themedColorForKey:kColorText1Selected];
    [self setTitleColor:selectedColor forState:UIControlStateSelected];
    
    if (_disableRedHighlight) {
        [self setTitleColor:[UIColor tt_themedColorForKey:kColorText3Highlighted] forState:UIControlStateHighlighted];
    } else {
        [self setTitleColor:selectedColor forState:UIControlStateHighlighted];
    }
    [super updateThemes];
}

- (void)updateFrames
{
    [titleLabel sizeToFit];
    [imageView sizeToFit];
    
    CGFloat textLeftMargin = 4;

    CGSize tmpSize = CGSizeMake(CGRectGetWidth(titleLabel.frame) + CGRectGetWidth(imageView.frame), _minHeight);
    
    CGRect textRect = CGRectIntegral(titleLabel.frame);
    CGRect imageRect = imageView.frame;
    //此处强制设为20 是为了使 点击时，动画发生时不改变图片的位置
    imageRect.size = CGSizeMake(20.f, 20.f);
    CGRect selfRect = self.frame;
    selfRect.size.height = tmpSize.height;
    
    CGFloat space = 0.0;
    if(tmpSize.width < _minWidth) {
        tmpSize.width = _minWidth;
        //space = (tmpSize.width - CGRectGetWidth(titleLabel.frame) - CGRectGetWidth(imageView.frame) - textLeftMargin) / 2;

    }
    else if (tmpSize.width > _maxWidth) {
        tmpSize.width = _maxWidth;
        //space = (tmpSize.width - CGRectGetWidth(titleLabel.frame) - CGRectGetWidth(imageView.frame) - textLeftMargin) / 2;
    }
    else {
        //space = 10.0;
    }
    
    imageRect.origin.x = /*[TTDeviceHelper isPadDevice] ? 0.f :*/ space;
    textRect.origin.x = CGRectGetMaxX(imageRect) + textLeftMargin;

    
    selfRect.size.width = tmpSize.width;
    self.frame = selfRect;
    titleLabel.frame = textRect;
    imageView.frame = imageRect;
    backgroundImageView.frame = self.bounds;

    if (self.centerAlignImage) {
        imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    } else {
        titleLabel.center = CGPointMake(titleLabel.center.x, self.frame.size.height/2);
        imageView.center = CGPointMake(imageView.center.x, self.frame.size.height/2);
    }
}

@end
