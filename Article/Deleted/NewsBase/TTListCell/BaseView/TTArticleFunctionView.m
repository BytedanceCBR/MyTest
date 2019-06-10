//
//  TTArticleFunctionView.m
//  Article
//
//  Created by 杨心雨 on 16/8/23.
//
//

#import <Foundation/Foundation.h>
#import "TTArticleFunctionView.h"

#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTDeviceHelper.h"
#import "ExploreOrderedData+TTAd.h"
#import "Article+TTADComputedProperties.h"



// MARK: - TTArticleFunctionView 功能区控件
/** 功能区控件 */
@implementation TTArticleFunctionView
/** 框架 */
- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        [self layoutFunction];
    }
}

/** 喜欢视图 */
- (SSThemedLabel *)likeView {
    if (_likeView == nil) {
        _likeView = [[SSThemedLabel alloc] init];
        _likeView.font = [UIFont tt_fontOfSize:kLikeViewFontSize()];
        _likeView.textColorThemeKey = kLikeViewTextColor();
        _likeView.lineBreakMode = NSLineBreakByTruncatingTail;

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeViewClick)];
        _likeView.userInteractionEnabled = YES;
        [_likeView addGestureRecognizer:tapGestureRecognizer];
        
        [self addSubview:_likeView];
    }
    return _likeView;
}

/** 来源图片 */
- (TTImageView *)sourceImageView {
    if (_sourceImageView == nil) {
        _sourceImageView = [[TTImageView alloc] init];
        _sourceImageView.borderColorThemeKey = kSourceViewImageBorderColor();
        _sourceImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _sourceImageView.backgroundColorThemeKey = kSourceViewImageBackgroundColor();
        _sourceImageView.imageContentMode = UIViewContentModeScaleAspectFill;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceImageClick)];
        _sourceImageView.userInteractionEnabled = YES;
        [_sourceImageView addGestureRecognizer:tapGestureRecognizer];
        
        [self addSubview:_sourceImageView];
    }
    return _sourceImageView;
}

/** 来源文字 */
- (SSThemedLabel *)sourceView {
    if (_sourceView == nil) {
        _sourceView = [[SSThemedLabel alloc] init];
        _sourceView.textColorThemeKey = kSourceViewTextColor();
        _sourceView.font = [UIFont tt_fontOfSize:kSourceViewFontSize()];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceImageClick)];
        _sourceView.userInteractionEnabled = YES;
        [_sourceView addGestureRecognizer:tapGestureRecognizer];
        
        [self addSubview:_sourceView];
    }
    return _sourceView;
}

/** 订阅标签 */
- (SSThemedLabel *)subscriptView {
    if (_subscriptView == nil) {
        _subscriptView = [[SSThemedLabel alloc] init];
        _subscriptView.text = @"已关注";
        _subscriptView.textColorThemeKey = kColorText3;
        _subscriptView.backgroundColor = [UIColor clearColor];
        _subscriptView.font = [UIFont tt_fontOfSize:12];
        [_subscriptView sizeToFit];
        _subscriptView.hidden = YES;
        [self addSubview:_subscriptView];
    }
    return _subscriptView;
}

/** 右向箭头 */
- (SSThemedImageView *)moreImageView {
    if (_moreImageView == nil) {
        _moreImageView = [[SSThemedImageView alloc] init];
        _moreImageView.imageName = @"right_arrow_icon";
        _moreImageView.enableNightCover = NO;
        [_moreImageView sizeToFit];
        _moreImageView.hidden = YES;
        [self addSubview:_moreImageView];
    }
    return _moreImageView;
}

/** 实体词 */
- (SSThemedLabel *)entityView {
    if (_entityView == nil) {
        _entityView = [[SSThemedLabel alloc] init];
        _entityView.textColorThemeKey = kSourceViewTextColor();
        _entityView.font = [UIFont tt_fontOfSize:kSourceViewFontSize()];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(entityViewClick)];
        _entityView.userInteractionEnabled = YES;
        [_entityView addGestureRecognizer:tapGestureRecognizer];
        
        _entityView.hidden = YES;
        [self addSubview:_entityView];
    }
    return _entityView;
}

/**
 功能区控件初始化方法
 
 - parameter frame: 功能区控件框架
 
 - returns: 功能区控件实例
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.clipsToBounds = YES;
    }
    return self;
}

// MARK: LayoutSubviews / UpdateSubviews
/**
 标题控件更新
 
 - parameter article: Article数据
 */
- (void)updateFunction:(ExploreOrderedData *)orderedData refer:(NSUInteger)refer {
    if (!isEmptyString([orderedData recommendReason])) {
        self.likeView.text = [orderedData recommendReason];
    } else {
        self.likeView.text = nil;
    }
    
    Article *article = [orderedData article];
    if (article) {
        NSString *sourceName = nil;
        NSString *sourceUrl = nil;
        BOOL subscibed = NO;
        if ([article mediaInfo]) {
            NSDictionary *mediaInfo = [article mediaInfo];
            sourceName = mediaInfo[@"name"];
            sourceUrl = mediaInfo[@"avatar_url"];
            //let mediaId = mediaInfo["media_id"]?.stringValue
            //if let mediaId = mediaId {
            subscibed = [[article isSubscribe] boolValue];
            //}
        }
        if (sourceUrl == nil) {
            sourceUrl = [article sourceAvatar];
        }
        if (isEmptyString(sourceName)) {
            sourceName = [article source];
        }
        if (isEmptyString(sourceName)) {
            sourceName = @"佚名";
        }
        self.sourceView.text = sourceName;
        NSString *source = [[sourceName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"\\u0008" withString:@""];
        if (!isEmptyString(sourceUrl)) {
            [self.sourceImageView setImageWithURLString:sourceUrl];
            self.sourceImageView.backgroundColors = nil;
            self.sourceImageView.backgroundColorThemeKey = kSourceViewImageBackgroundColor();
            self.sourceImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        } else if ([source length] > 0) {
            NSString *character = [source substringWithRange:NSMakeRange(0, 1)];
            SSThemedLabel *view = [[SSThemedLabel alloc] init];
            view.text = character;
            view.font = [UIFont tt_fontOfSize:12];
            view.textColorThemeKey = kColorText8;
            [view sizeToFit];
            self.sourceImageView.backgroundColors = [article sourceIconBackgroundColors];
            [self.sourceImageView setImageWithModel:nil placeholderView:view];
            self.sourceImageView.layer.borderWidth = 0;
        } else {
            self.sourceImageView.backgroundColors = nil;
            self.sourceImageView.backgroundColorThemeKey = kSourceViewImageBackgroundColor();
            [self.sourceImageView setImageWithModel:nil placeholderView:[[UIView alloc] init]];
            self.sourceImageView.layer.borderWidth = 0;
        }
        
        self.subscriptView.hidden = !subscibed;
        
        if (refer == 1 && !isEmptyString([article sourceDesc])) {
            self.entityView.text = [article sourceDesc];
            self.entityView.hidden = NO;
            self.moreImageView.hidden = NO;
        } else {
            self.entityView.hidden = YES;
            self.moreImageView.hidden = YES;
        }
    }
    [self updateReadState:[[[orderedData originalData] hasRead] boolValue]];
    [self layoutFunction];
}

- (void)updateADFunction:(ExploreOrderedData *)orderedData {
    if (!isEmptyString([orderedData recommendReason])) {
        self.likeView.text = [orderedData recommendReason];
    } else {
        self.likeView.text = nil;
    }
    
    id<TTAdFeedModel> adModel = orderedData.adModel;

    if ([adModel isCreativeAd]) {
        SSThemedLabel *placeHolder = nil;
        self.sourceView.text = [adModel source];
        self.sourceImageView.backgroundColors = nil;
        self.sourceImageView.backgroundColorThemeKey = kSourceViewImageBackgroundColor();
        self.sourceImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        NSString *source = [adModel source];
        if (isEmptyString(source)) {
            source = @"佚名";
        }
        if ([source length] > 0) {
            NSString *character = [source substringWithRange:NSMakeRange(0, 1)];
            placeHolder = [[SSThemedLabel alloc] init];
            placeHolder.text = character;
            placeHolder.font = [UIFont tt_fontOfSize:12];
            placeHolder.textColorThemeKey = kColorText8;
            [placeHolder sizeToFit];
            self.sourceImageView.backgroundColors = @[@"cccccc", @"666666"];
            self.sourceImageView.layer.borderWidth = 0;
        }
        [self.sourceImageView setImageWithModel:orderedData.article.listSourceIconModel placeholderView:placeHolder];
    }
    [self updateReadState:[[[orderedData originalData] hasRead] boolValue]];
    [self layoutFunction];
}

/**
 标题控件布局
 */
- (void)layoutFunction {
    CGFloat x = 0, y = 0;
    if (self.likeView.text != nil) {
        self.likeView.hidden = NO;
        self.likeView.frame = CGRectMake(0, 0, self.width - kMoreViewSide() - kMoreViewExpand(), kLikeViewFontSize());
        y += kLikeViewFontSize() + kFunctionViewPaddingLikeToSource();
    } else {
        self.likeView.hidden = YES;
    }
    
    self.sourceImageView.frame = CGRectMake(x, y, kSourceViewImageSide(), kSourceViewImageSide());
    self.sourceImageView.layer.cornerRadius = self.sourceImageView.width / 2;
    x += self.sourceImageView.width + kFunctionViewPaddingSourceImageToSource();
    CGFloat centerY = self.sourceImageView.centerY;
    
    [self.sourceView sizeToFit];
    self.sourceView.left = x;
    self.sourceView.centerY = centerY;
    x += self.sourceView.width + kFunctionViewPaddingSourceImageToSource();
    
    if (!self.subscriptView.hidden) {
        self.subscriptView.left = x;
        self.subscriptView.centerY = centerY;
        x += self.subscriptView.width + kFunctionViewPaddingSourceImageToSource();
    }
    
    if (!self.entityView.hidden) {
        self.moreImageView.left = x;
        self.moreImageView.centerY = centerY;
        x += self.moreImageView.width + kFunctionViewPaddingSourceImageToSource();
        
        [self.entityView sizeToFit];
        self.entityView.left = x;
        self.entityView.centerY = centerY;
    }
}

- (void)likeViewClick {
    [[self delegate] functionViewLikeViewClick];
}

- (void)sourceImageClick {
    [[self delegate] functionViewPGCClick];
}

- (void)entityViewClick {
    [[self delegate] functionViewEntityClick];
}

- (void)updateReadState:(BOOL)hasRead {
    self.sourceView.highlighted = hasRead;
    self.entityView.highlighted = hasRead;
}

@end
