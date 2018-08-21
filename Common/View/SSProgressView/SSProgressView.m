//
//  SSProgressView.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-7-30.
//
//

#import "SSProgressView.h"

#define EdgeInsetsLeftDefaultMargin 0.f
#define EdgeInsetsRightDefaultMargin 0.f
#define EdgeInsetsTopDefaultMargin 0.f
#define EdgeInsetsBottomDefaultMargin 0.f


@interface SSProgressView()
@property(nonatomic, assign)BOOL progressAnimated;
@property(nonatomic, assign) UIImageView *headImageView;

@end

@implementation SSProgressView
@synthesize progressStop = _progressStop;
@synthesize progressViewEdgeInsets = _progressViewEdgeInsets;
@synthesize progress = _progress;
@synthesize style = _style;
@synthesize progressBackgroundImage = _progressBackgroundImage;
@synthesize progressForegroundImage = _progressForegroundImage;
@synthesize progressHeadImage = _progressHeadImage;
@synthesize progressAnimated = _progressAnimated;
@synthesize headImageView = _headImageView;

#pragma mark -- dealloc & init

- (void)dealloc
{
    self.headImageView = nil;
    
    self.progressBackgroundImage = nil;
    self.progressForegroundImage = nil;
    self.progressHeadImage = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _progressViewEdgeInsets = UIEdgeInsetsMake(EdgeInsetsTopDefaultMargin, EdgeInsetsLeftDefaultMargin, EdgeInsetsBottomDefaultMargin, EdgeInsetsRightDefaultMargin);
        self.backgroundColor = [UIColor clearColor];
        _progress = 0;
        self.contentMode = UIViewContentModeRedraw;
        
        self.headImageView = [[[UIImageView alloc] initWithImage:nil] autorelease];
        [self addSubview:_headImageView];
    }
    return self;
}

- (id)initWithProgressViewStyle:(SSProgressViewStyle)style
{
    self = [self initWithFrame:CGRectZero];
    
    if (self) {
        self.style = style;
        
    }
    
    return self;
}

#pragma mark -- private

- (CGRect)calculateBackgroundDrawRect
{
    CGFloat backImageHeight = _progressBackgroundImage.size.height;
    CGFloat backImageWidth = _progressBackgroundImage.size.width;
    
    if (backImageHeight == 0 || backImageWidth == 0) {
        return CGRectZero;
    }
    
    CGFloat backImageOriginX = (CGRectGetWidth(self.frame) - _progressViewEdgeInsets.left - _progressViewEdgeInsets.right - backImageWidth) / 2;
    backImageOriginX = backImageOriginX > 0 ? backImageOriginX + _progressViewEdgeInsets.left : 0;
    
    
    CGFloat backImageOriginY = (CGRectGetHeight(self.frame) - _progressViewEdgeInsets.top - _progressViewEdgeInsets.bottom - backImageHeight) / 2;
    backImageOriginY = backImageOriginY > 0 ? backImageOriginY + _progressViewEdgeInsets.top : 0;
    
    CGRect backRect = CGRectMake(backImageOriginX, backImageOriginY, backImageWidth, backImageHeight);
    return backRect;
}

- (CGRect)calculateForegroundDrawRect
{
    CGRect entireRect = [self calculateBackgroundDrawRect];
    if (_progress >= 100.f) {
        return entireRect;
    }
    
    CGFloat frontImageHeight = entireRect.size.height;
    CGFloat frontImageWidth = entireRect.size.width;
    
    CGRect foregroundRect = CGRectZero;
    switch (_style) {
        case SSProgressViewStyleTowardDown:
        {
            CGFloat imgHeight = _progress * frontImageHeight / 100.f;
            foregroundRect = entireRect;
            foregroundRect.size.width = frontImageWidth;
            foregroundRect.size.height = imgHeight;
        }
            break;
        case SSProgressViewStyleTowardLeft:
        {
            CGFloat imgWidth = _progress * frontImageWidth / 100.f;
            foregroundRect = entireRect;
            foregroundRect.origin.x = foregroundRect.origin.x + frontImageWidth - imgWidth;
            foregroundRect.size.width = imgWidth;
        }
            break;
        case SSProgressViewStyleTowardRight:
        {
            CGFloat imgWidth = _progress * frontImageWidth / 100.f;
            foregroundRect = entireRect;
            foregroundRect.size.width = imgWidth;
        }
            break;
        case SSProgressViewStyleTowardUp:
        {
            CGFloat imgHeight = _progress * frontImageHeight / 100.f;
            foregroundRect = entireRect;
            foregroundRect.origin.y = entireRect.origin.y + frontImageHeight- imgHeight;
            foregroundRect.size.height = imgHeight;
        }
            break;
        default:
            
            break;
    }
    return foregroundRect;
}

- (CGRect)calculateCreateNewForegroundImageRect
{
    CGRect entireRect = [self calculateBackgroundDrawRect];
    if (_progress >= 100.f) {
        return entireRect;
    }
    
    CGFloat frontImageHeight = entireRect.size.height;
    CGFloat frontImageWidth = entireRect.size.width;
    
    CGRect foregroundRect = CGRectZero;
    switch (_style) {
        case SSProgressViewStyleTowardDown:
        {
            CGFloat imgHeight = _progress * frontImageHeight / 100.f;
            foregroundRect.size.width = frontImageWidth;
            foregroundRect.size.height = imgHeight;
        }
            break;
        case SSProgressViewStyleTowardLeft:
        {
            CGFloat imgWidth = _progress * frontImageWidth / 100.f;
            foregroundRect.size.width = imgWidth;
            foregroundRect.size.height = frontImageHeight;
            foregroundRect.origin.x = frontImageWidth - imgWidth;
        }
            break;
        case SSProgressViewStyleTowardRight:
        {
            CGFloat imgWidth = _progress * frontImageWidth / 100.f;
            foregroundRect.size.width = imgWidth;
            foregroundRect.size.height = frontImageHeight;
        }
            break;
        case SSProgressViewStyleTowardUp:
        {
            CGFloat imgHeight = _progress * frontImageHeight / 100.f;
            foregroundRect.origin.y = frontImageHeight- imgHeight;
            foregroundRect.origin.x = 0;
            foregroundRect.size.height = imgHeight;
            foregroundRect.size.width = frontImageWidth;
        }
            break;
        default:
            
            break;
    }
    return foregroundRect;
    
}

- (CGRect)getCoreGraphicRectByDevice:(CGRect)rect
{
    float scale = [UIScreen mainScreen].scale;
    CGRect resultRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    return resultRect;
}

+ (CGRect)getRectByCenter:(CGPoint)center size:(CGSize)size
{
    CGRect result = CGRectMake(0, 0, size.width, size.height);
    result.origin.x = center.x - size.width / 2.f;
    result.origin.y = center.y - size.height / 2.f;
    return result;
}

- (CGRect)calculateHeadImageRect
{
    if (_progressHeadImage == nil || _progressStop) {
        return CGRectZero;
    }
    
    CGRect fgDrawRect = [self calculateForegroundDrawRect];
    CGPoint rectCenter;
    switch (_style) {
    case SSProgressViewStyleTowardDown:
    {
        rectCenter = CGPointMake(CGRectGetMaxX(fgDrawRect) - CGRectGetWidth(fgDrawRect) / 2.f, CGRectGetMaxY(fgDrawRect));
    }
        break;
    case SSProgressViewStyleTowardLeft:
    {
        rectCenter = CGPointMake(CGRectGetMinX(fgDrawRect), CGRectGetMaxY(fgDrawRect) - CGRectGetHeight(fgDrawRect) / 2.f);
    }
        break;
    case SSProgressViewStyleTowardRight:
    {
        rectCenter = CGPointMake(CGRectGetMaxX(fgDrawRect), CGRectGetMaxY(fgDrawRect) - CGRectGetHeight(fgDrawRect) / 2.f);
    }
        break;
    case SSProgressViewStyleTowardUp:
    {
        rectCenter = CGPointMake(CGRectGetMaxX(fgDrawRect) - CGRectGetWidth(fgDrawRect) / 2.f, CGRectGetMinY(fgDrawRect));
    }
        break;
    default:
        break;
    }
    CGRect headRect = [SSProgressView getRectByCenter:rectCenter size:_progressHeadImage.size];
    return headRect;
}


#pragma mark -- protect

- (void)drawRect:(CGRect)rect
{
    CGRect bgRect = [self calculateBackgroundDrawRect];
    if (!CGRectEqualToRect(bgRect, CGRectZero)) {
        [_progressBackgroundImage drawInRect:bgRect];
    }
    
    if (_progress <= 0) {
        return;
    }
    
    CGRect drawFgRect = [self calculateForegroundDrawRect];
    CGRect createNewImageRect = [self calculateCreateNewForegroundImageRect];
    if (!CGRectEqualToRect(drawFgRect, CGRectZero) && !CGRectEqualToRect(createNewImageRect, CGRectZero)) {
        CGImageRef sourceImageRect = _progressForegroundImage.CGImage;
        CGImageRef newImgRef = CGImageCreateWithImageInRect(sourceImageRect, [self getCoreGraphicRectByDevice:createNewImageRect]);
        UIImage * newImage = [UIImage imageWithCGImage:newImgRef];
        [newImage drawInRect:drawFgRect];
        CGImageRelease(newImgRef);
    }
    
    CGRect headRect = [self calculateHeadImageRect];
    if (!CGRectEqualToRect(headRect, CGRectZero)) {
        
//        [_progressHeadImage drawInRect:headRect];
        _headImageView.frame = headRect;
    }
}

#pragma mark -- setter & getter

- (void)setProgressStop:(BOOL)progressStop
{
    _progressStop = progressStop;
    _headImageView.hidden = _progressStop;
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress
{
    _progressStop = NO;
    if (progress < 0) {
        _progress = 0;
    }
    else if (progress > 100) {
        _progress = 100;
    }
    else {
        _progress = progress;
    }

    [self setNeedsDisplay];
}

#pragma mark -- public

- (void)setProgressHeadImage:(UIImage *)progressHeadImage
{
    [_progressHeadImage release];
    _progressHeadImage = [progressHeadImage retain];
    
    self.headImageView.image = _progressHeadImage;
    [_headImageView sizeToFit];
    _headImageView.center = CGPointMake(0.f, self.bounds.size.height/2);
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    self.progressAnimated = animated;
    self.progress = progress;
}


@end
