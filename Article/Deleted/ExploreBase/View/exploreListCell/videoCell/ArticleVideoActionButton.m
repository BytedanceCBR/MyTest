//
//  ArticleVideoActionButton.m
//  Article
//
//  Created by Chen Hong on 15/5/19.
//
//

#import "ArticleVideoActionButton.h"
#import "TTThemeManager.h"
#import "SSMotionRender.h"
#import "TTDeviceUIUtils.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"


static const CGFloat textLeftMargin = 4;

@implementation ArticleVideoActionButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.minWidth = 51.f;
        self.minHeight = 44;
        self.maxWidth = 1000.0f;
        self.imageSize  = CGSizeZero;
        [self setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]] forState:UIControlStateNormal];
        //self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

- (void) doZoomInAndDisappearMotion
{
    [SSMotionRender motionInView:self.imageView byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(4, -9)];
}

- (void)updateFrames
{
    [titleLabel sizeToFit];
    //如果外部没有传size, 则sizeToFit
    if (CGSizeEqualToSize(self.imageSize, CGSizeZero)) {
        [imageView sizeToFit];
    } else {
        imageView.size = self.imageSize;
    }
    
    CGFloat titleW = CGRectGetWidth(titleLabel.frame);
    
    CGSize tmpSize;
    if (self.verticalLayout) {
        tmpSize = CGSizeMake(MAX(titleW, CGRectGetWidth(imageView.frame)) + 2 * textLeftMargin, _minHeight);
    }
    else {
        tmpSize = CGSizeMake((titleW > 0 ? titleW + textLeftMargin : 0) + CGRectGetWidth(imageView.frame), _minHeight);
    }
    
    CGRect textRect = CGRectIntegral(titleLabel.frame);
    CGRect imageRect = imageView.frame;
    
    CGRect selfRect = self.frame;
    selfRect.size.height = tmpSize.height;
    
    CGFloat space = 0.0;
    if(tmpSize.width < _minWidth) {
        tmpSize.width = _minWidth;
    }
    else if (tmpSize.width > _maxWidth) {
        tmpSize.width = _maxWidth;
    }
    else {
        //space = 10.0;
    }

    if (self.verticalLayout) {
        
        selfRect.size.width = tmpSize.width;
        self.frame = selfRect;
        
        CGFloat top = (self.frame.size.height - imageRect.size.height - textRect.size.height - 2)/2;
        imageRect.origin.y = top;
        imageRect.origin.x = (self.frame.size.width - imageRect.size.width)/2;
        textRect.origin.y = top + imageRect.size.height + 2;
        textRect.origin.x = (self.frame.size.width - textRect.size.width)/2;

        imageView.frame = imageRect;
        titleLabel.frame = textRect;
    }
    else {
        imageRect.origin.x = /*[TTDeviceHelper isPadDevice] ? 0.f :*/ space;
        textRect.origin.x = CGRectGetMaxX(imageRect) + textLeftMargin;
        
        selfRect.size.width = tmpSize.width;
        self.frame = selfRect;
        titleLabel.frame = textRect;
        imageView.frame = imageRect;
        
        backgroundImageView.frame = self.bounds;
        
        if (self.centerAlignImage) {
            imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        }
        else {
            titleLabel.center = CGPointMake(titleLabel.center.x, self.frame.size.height/2);
            imageView.center = CGPointMake(imageView.center.x, self.frame.size.height/2);
        }
    }
}

- (UIEdgeInsets)contentEdgeInset
{
    CGFloat top = MIN(titleLabel.top, imageView.top);
    CGFloat left = MIN(titleLabel.left, imageView.left);
    CGFloat bottom = MIN(self.height - titleLabel.bottom, self.height - imageView.bottom);
    CGFloat right = MIN(self.width - titleLabel.right, self.width - imageView.right);
    return UIEdgeInsetsMake(top, left, bottom, right);
}

@end
