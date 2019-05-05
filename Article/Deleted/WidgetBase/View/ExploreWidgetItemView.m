//
//  ExploreWidgetItemView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-11.
//
//

#import "ExploreWidgetItemView.h"
#import "ExploreWidgetItemModel.h"
#import "ExploreExtenstionDataHelper.h"
#import "TTBaseMacro.h"
#import "TTWidgetTool.h"
#import "UIImageView+SimpleWebImage.h"

#define WeakSelf   __weak typeof(self) wself = self
#define StrongSelf __strong typeof(wself) self = wself
#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]

#define kImageViewWidth                 80
#define kImageViewHeight                (([TTWidgetTool OSVersionNumber] >= 10.0) ? 80.0 : 56.0)
#define kImageViewLeftPadding           15
#define kImageViewCornerRadiusForIOS10  4.0

#define kTitleLabelBottomPadding        (([TTWidgetTool OSVersionNumber] >= 10.0) ? 8.0 : 4.0)
#define kTitleLabelFontSize             (([TTWidgetTool OSVersionNumber] >= 10.0) ? 18.0 : 16.0)
#define kInfoLabelFontSize              11
#define kInfoLabelHeight                13

#define kLeftMargin                     (([TTWidgetTool OSVersionNumber] >= 10.0) ? 8.0 : 0.0)
#define kRightMargin                    8
#define kBGButtonRightMargin            (([TTWidgetTool OSVersionNumber] >= 10.0) ? 0.0 : 8.0)
#define kTopMargin                      13
#define kBottomMargin                   13


@interface ExploreWidgetItemView()

@property(nonatomic, retain)UILabel * titleLabel;
/**
 *  评论 和 时间
 */
@property(nonatomic, retain)UILabel * infoLabel;

@property(nonatomic, retain)UIView * bottomLineView;

@property(nonatomic, retain)UIImageView * imageView;

@property(nonatomic, retain)UIButton * bgButton;

@property(nonatomic, retain)ExploreWidgetItemModel * model;

@property(nonatomic, assign)NSInteger index;

@property(nonatomic, strong)NSURL *currentURL;

@end

@implementation ExploreWidgetItemView

- (void)dealloc
{
    self.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - kImageViewWidth - kRightMargin, kTopMargin, kImageViewWidth, kImageViewHeight)];
        _imageView.userInteractionEnabled = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        if ([TTWidgetTool OSVersionNumber] >= 10.0) {
            _imageView.layer.cornerRadius = kImageViewCornerRadiusForIOS10;
        }
        _imageView.clipsToBounds = YES;
        _index = -1;
        [self addSubview:_imageView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor blueColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.backgroundColor = [UIColor clearColor];
        if ([TTWidgetTool OSVersionNumber] >= 10.0) {
            _titleLabel.textColor = [UIColor blackColor];
            _titleLabel.font = [UIFont boldSystemFontOfSize:kTitleLabelFontSize];
        }
        else {
            _titleLabel.textColor = [UIColor whiteColor];
            _titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        }
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];
        
        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.numberOfLines = 1;
        _infoLabel.userInteractionEnabled = NO;
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.font = [UIFont systemFontOfSize:kInfoLabelFontSize];
        if ([TTWidgetTool OSVersionNumber] >= 10.0) {
            _infoLabel.textColor = RGB(118, 118, 118);
            _infoLabel.alpha = 1.0f;
        }
        else {
            _infoLabel.textColor = [UIColor whiteColor];
            _infoLabel.alpha = 0.4f;
        }
        [self addSubview:_infoLabel];
        
        self.bottomLineView =[[UIView alloc] initWithFrame:CGRectZero];
        if ([TTWidgetTool OSVersionNumber] >= 10.0) {
            _bottomLineView.backgroundColor = [UIColor blackColor];
            _bottomLineView.alpha = 0.1f;
        }
        else {
            _bottomLineView.backgroundColor = [UIColor whiteColor];
            _bottomLineView.alpha = 0.4f;
        }
        [self addSubview:_bottomLineView];
        
        self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgButton.frame = CGRectMake(0, 0, self.frame.size.width - kRightMargin, self.frame.size.height);
        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_bgButton setBackgroundImage:[self.class imageWithUIColor:[UIColor colorWithWhite:1 alpha:0.3f]] forState:UIControlStateHighlighted];
        [_bgButton setBackgroundImage:[self.class imageWithUIColor:[UIColor colorWithWhite:1 alpha:0.3f]] forState:UIControlStateSelected];
        [self addSubview:_bgButton];
        [self sendSubviewToBack:_bgButton];
        
    }
    return self;
}

- (void)bgButtonClicked
{
    if ([_model.uniqueID longLongValue] != 0) {
        NSString * url = [NSString stringWithFormat:@"%@detail?groupid=%@&gd_label=click_today_extenstion", [TTWidgetTool ssAppScheme], _model.uniqueID];
        
        if (_delegate && [_delegate respondsToSelector:@selector(itemView:urlStr:)]) {
            [_delegate itemView:self urlStr:url];
        }
    }
}

- (void)refreshViewHasImg:(BOOL)img
{
    CGFloat titleLabelHeight = 0.0;
    CGFloat contentHeight = 0.0;
    _imageView.frame = CGRectMake(self.frame.size.width - kImageViewWidth - kRightMargin, kTopMargin, kImageViewWidth, kImageViewHeight);
    if (img) {
        titleLabelHeight = [_titleLabel sizeThatFits:CGSizeMake(CGRectGetMinX(_imageView.frame) - kImageViewLeftPadding - kLeftMargin, 0)].height;
        contentHeight = titleLabelHeight + kTitleLabelBottomPadding + kInfoLabelHeight;
        _imageView.hidden = NO;
        _titleLabel.frame = CGRectMake(kLeftMargin, (CGRectGetHeight(self.bounds) - contentHeight)/2.0, CGRectGetMinX(_imageView.frame) - kImageViewLeftPadding - kLeftMargin, titleLabelHeight);
    }
    else {
        titleLabelHeight = [_titleLabel sizeThatFits:CGSizeMake(self.frame.size.width - kRightMargin - kLeftMargin, 0)].height;
        contentHeight = titleLabelHeight + kTitleLabelBottomPadding + kInfoLabelHeight;
        _imageView.hidden = YES;
        _titleLabel.frame = CGRectMake(kLeftMargin, (CGRectGetHeight(self.bounds) - contentHeight)/2.0, self.frame.size.width - kRightMargin - kLeftMargin, titleLabelHeight);
    }
    _infoLabel.frame = CGRectMake(kLeftMargin, CGRectGetMaxY(_titleLabel.frame) + kTitleLabelBottomPadding, _titleLabel.frame.size.width, kInfoLabelHeight);
    _bottomLineView.frame = CGRectMake(kLeftMargin, self.frame.size.height - [TTWidgetTool ssOnePixel], self.frame.size.width - kRightMargin - kLeftMargin, [TTWidgetTool ssOnePixel]);
    _bgButton.frame = CGRectMake(0, 0, self.frame.size.width - kBGButtonRightMargin, self.frame.size.height);
}

//解除对TTImageView的耦合，重写相关逻辑
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)refreshWithModel:(ExploreWidgetItemModel *)model widgetDisplayMode:(NCWidgetDisplayMode)mode
#pragma clang diagnostic pop
{
    _index = -1;
    
    self.model = model;
    [_titleLabel setText:model.title];
    
    NSString * str = [TTWidgetTool customtimeStringSince1970:[model.beHotTime doubleValue]];
    NSString * infoLabelText = [NSString stringWithFormat:@"%@%i  %@",NSLocalizedString(@"评论", nil), [model.commentCount intValue], str];
    [_infoLabel setText:infoLabelText];
    
    
    BOOL noImg = [ExploreExtenstionDataHelper isUserSetNoImgMode];
    if (noImg) {
        [self refreshViewHasImg:NO];
    }
    else {
        [self refreshViewHasImg:[model hasRightImg]];
    }
    
    [self setImageWithModel:model placeholderImage:[UIImage imageNamed:@"widget_placehold_img.png"]];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    self.bottomLineView.hidden = (mode == NCWidgetDisplayModeCompact);
#pragma clang diagnostic pop
}

- (void)setImageWithModel:(ExploreWidgetItemModel *)model placeholderImage:(UIImage *)image
{
    [self loadNextPreviousLoadError:nil];
}

- (void)loadNextPreviousLoadError:(NSError *)error
{
    if (_model == nil) {
        [self setImageWithURL:nil];
        return;
    }
    
    _index += 1;
    NSString * urlString = [self _urlStringForImageModelHeaders:self.model.rightImgURLHeaders atIndex:_index];
    NSURL * url = [TTWidgetTool URLWithURLString:urlString];
    if (url) {
        [self setImageWithURL:url];
    }
}

- (NSString *)_urlStringForImageModelHeaders:(NSArray *)urlHeaders atIndex:(NSInteger)index
{
    if (index >= [urlHeaders count]) {
        return nil;
    }
    return [[urlHeaders objectAtIndex:index] objectForKey:@"url"];
}

- (void)setImageWithURL:(NSURL *)URL
{
    WeakSelf;
    [_imageView simple_setImageWithURL:URL placeholderImage:[self.class placeHolderImage] completed:^(UIImage *image, BOOL cached, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        StrongSelf;
        if (image) {
            //对第一次加载出来的图片 做个动画效果 --nick
            if (![self.currentURL isEqual:URL] && !cached) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    _imageView.alpha = 0;
                    _imageView.alpha = 1;
                    
                } completion:^(BOOL finished) {
                    _imageView.alpha = 1;
                }];
            }
            _currentURL = URL;
        } else {
            if (_model != nil) {
                [self loadNextPreviousLoadError:error];
            }
        }
    }];
}

- (void)refreshImageViewIfNeed
{
    if (_imageView.contentMode == UIViewContentModeScaleAspectFill) {
        CGSize imageSize = _imageView.image.size;
        _imageView.autoresizingMask = UIViewAutoresizingNone;
        if (imageSize.height > 0 && imageSize.width > 0) {
            //对于高 > 宽的图片， 缩放保留顶/底部逻辑
            if (imageSize.height > imageSize.width) {
                _imageView.frame = CGRectMake(0, 0, self.frame.size.width, (imageSize.height * self.frame.size.width) / imageSize.width);
            }
            else { //对于宽 > 高的图片，缩放保留中部， 直接使用UIViewContentModeScaleAspectFill
                _imageView.frame = self.bounds;
                _imageView.contentMode = UIViewContentModeScaleAspectFill;
            }
        }
        else {
            _imageView.frame = self.bounds;
        }
        
    } else {
        if (!CGRectEqualToRect(_imageView.frame, self.bounds)) {
            _imageView.frame = self.bounds;
        }
    }
}

+ (CGFloat)heightForModel:(ExploreWidgetItemModel *)model
{
    return kTopMargin + kImageViewHeight + kBottomMargin;
}

+ (CGFloat)preferredInitHeight
{
    return [self heightForModel:nil];
}


+ (UIImage *)imageWithUIColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)placeHolderImage {
    static UIImage *placeHolderImage = nil;
    if (!placeHolderImage) {
        UIImage *placeHolderOrigin = [UIImage imageNamed:@"widget_placehold_img.png"];
        CGRect rect=CGRectMake(0.0f, 0.0f, kImageViewWidth, kImageViewHeight);
        
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGPoint point = CGPointMake((rect.size.width - placeHolderOrigin.size.width) / 2.0, (rect.size.height - placeHolderOrigin.size.height) / 2.0);
            [placeHolderOrigin drawAtPoint:point];
            placeHolderImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
    }
    return placeHolderImage;
}

@end
