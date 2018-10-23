//
//  TTRepostThreadSchemaQuoteView.m
//  Article
//
//  Created by ranny_90 on 2017/9/11.
//
//

#import "TTRepostThreadSchemaQuoteView.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Link.h"
#import "TTUGCEmojiParser.h"
#import "TTKitchenHeader.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "NSDictionary+TTAdditions.h"
#import "UIViewAdditions.h"
#import "TTDeviceUIUtils.h"

static const CGFloat KKQuoteFontSize = 16.0f;

@implementation TTRepostQuoteModel

- (instancetype)initWithRepostParam:(NSDictionary *)repostParam{
    
    self = [super init];
    if (self) {
        
        if (!SSIsEmptyDictionary(repostParam)) {
            self.title = [repostParam tt_stringValueForKey:@"title"];
            self.titleRichSpan = [repostParam tt_stringValueForKey:@"title_rich_span"];
            self.coverURL = [repostParam tt_stringValueForKey:@"cover_url"];
            self.isVideo = [repostParam tt_boolValueForKey:@"is_video"];
        }
    }
    return self;
}

@end

@interface TTRepostThreadSchemaQuoteView ()

@property (nonatomic,strong) TTRepostQuoteModel *quoteModel;

@property (nonatomic, strong) SSThemedImageView *imageView;
@property (nonatomic, strong) SSThemedImageView *playIcon;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedImageView *placeholderImageView;

@end

@implementation TTRepostThreadSchemaQuoteView

- (instancetype)initWithQuoteModel:(TTRepostQuoteModel *)quoteModel{
    self = [super init];
    if (self) {
        
        self.quoteModel = quoteModel;
        [self setup];
    }
    return self;
}

- (instancetype)initWithRepostParam:(NSDictionary *)repostParam {
    TTRepostQuoteModel *quoteModel = [[TTRepostQuoteModel alloc] initWithRepostParam:repostParam];
    return [self initWithQuoteModel:quoteModel];
}

- (void)setup {
    self.backgroundColorThemeKey = kColorBackground3;
    [self addSubview:self.placeholderImageView];
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self.imageView addSubview:self.playIcon];
    
    //文字
    if (!isEmptyString(self.quoteModel.title)) {
        TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.quoteModel.titleRichSpan];
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:self.quoteModel.title richSpans:richSpans];
        TTRichSpanText *replacedRichSpanText = [richSpanText replaceWhitelistLinksAsInactiveLinks];
        NSAttributedString *attributedString = [TTUGCEmojiParser parseInTextKitContext:replacedRichSpanText.text fontSize:KKQuoteFontSize];
        NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        NSRange range;
        NSParagraphStyle *paragraphStyle = [attributedString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:&range];
        if (paragraphStyle) {
                if (@available(iOS 9.0, *)) {
                    [mutableParagraphStyle setParagraphStyle:paragraphStyle];
                } else {
                    // Fallback on earlier versions
                    [mutableParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
                }
        } else {
            [mutableParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        }
        [mutableParagraphStyle setLineSpacing:4.0];
        NSMutableAttributedString *mutableAttrStr = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
        [mutableAttrStr addAttribute:NSParagraphStyleAttributeName value:mutableParagraphStyle range:NSMakeRange(0, attributedString.length)];
        [self.titleLabel setAttributedText:mutableAttrStr];
    }
    
    //图片
    BOOL showLinkIcon = YES;
    self.imageView.hidden = YES;
    if (!isEmptyString(self.quoteModel.coverURL)) {
        showLinkIcon = NO;
        __block BOOL imageLoaded = NO;
        self.imageView.alpha = 0;
        WeakSelf;
        NSURL *imageURL = [NSURL URLWithString:self.quoteModel.coverURL];
        [self.imageView sda_setImageWithURL:imageURL
                          placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     StrongSelf;
                                     if (!error && !imageLoaded){
                                         imageLoaded = YES;
                                         self.imageView.alpha = 0;
                                         [UIView animateWithDuration:0.25 animations:^{
                                             self.imageView.alpha = 1;
                                         } completion:^(BOOL finished) {
                                         }];
                                     }
                                 }];
        self.imageView.hidden = NO;
    }
    
    if (showLinkIcon) {
        self.placeholderImageView.image = [UIImage imageNamed:@"u13_link_share_icon"];
        self.placeholderImageView.enableNightCover = YES;
    } else {
        self.placeholderImageView.image = [UIImage imageNamed:@"u13_feed_share_icon"];
        self.placeholderImageView.enableNightCover = YES;
    }
    
    //视频图片标志
    self.playIcon.hidden = YES;
    if (!self.imageView.hidden && self.quoteModel.isVideo) {
        self.playIcon.hidden = NO;
        self.playIcon.center = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));
    }

}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderImageView.frame = CGRectMake(1, 1, self.height-2, self.height-2);
    self.titleLabel.frame = CGRectMake(self.height + [TTDeviceUIUtils tt_padding:4.0], 0, self.width - self.height - [TTDeviceUIUtils tt_padding:4.0], self.height);
    self.imageView.frame = CGRectMake(1, 1, self.height-2, self.height-2);
    self.playIcon.center = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));
}

#pragma mark - accessor

//灰块或者link图标
//灰块不需要nightCover，link图标需要
- (SSThemedImageView *)placeholderImageView {
    if (!_placeholderImageView) {
        _placeholderImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _placeholderImageView.clipsToBounds = YES;
        _placeholderImageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground2];
    }
    return _placeholderImageView;
}

- (SSThemedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.enableNightCover = YES;
    }
    return _imageView;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:KKQuoteFontSize]];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.contentInset = UIEdgeInsetsMake(0, [TTDeviceUIUtils tt_padding:12.0], 0, [TTDeviceUIUtils tt_padding:12.0]);
    }
    return _titleLabel;
}

- (SSThemedImageView *)playIcon {
    if (!_playIcon) {
        _playIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 44.0, 44.0)];
        _playIcon.contentMode = UIViewContentModeScaleAspectFill;
        _playIcon.imageName = @"u11_play";
    }
    return _playIcon;
}


@end
