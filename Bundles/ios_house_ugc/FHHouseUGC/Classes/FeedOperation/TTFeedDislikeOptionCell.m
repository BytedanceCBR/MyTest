//
//  TTFeedDislikeOptionCell.m
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/13.
//

#import "TTFeedDislikeOptionCell.h"
#import "UIViewAdditions.h"
#import "TTFeedDislikeWord.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTFeedDislikeConfig.h"
#import "FHFeedOperationView.h"

@interface TTFeedDislikeOptionCell ()

@property (nonatomic, strong) TTFeedDislikeOption *option;

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *subTitleLabel;
@property (nonatomic, strong) UIImageView *accessor;

@end

@implementation TTFeedDislikeOptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifiers {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifiers]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _iconImageView = [UIImageView new];
        [self addSubview:_iconImageView];
        
        _titleLabel = ({
            SSThemedLabel *v = [SSThemedLabel new];
            v.font = [UIFont systemFontOfSize:16.0];
            v.textColorThemeKey = kColorText1;
            v;
        });
        [self addSubview:_titleLabel];
        
        _subTitleLabel = ({
            SSThemedLabel *v = [SSThemedLabel new];
            v.font = [UIFont systemFontOfSize:12.0];
            v.textColorThemeKey = kColorText3;;
            v;
        });
        [self addSubview:_subTitleLabel];
        
        _accessor = ({
            UIImageView *v = [UIImageView new];
            v.image = [UIImage themedImageNamed:@"feed_dislike_arrow_right" inBundle:FHFeedOperationView.resourceBundle];
            v;
        });
        [self addSubview:_accessor];
        
        _separator = ({
            SSThemedView *v = [SSThemedView new];
            v.backgroundColorThemeKey = kColorLine1;
            v;
        });
        [self addSubview:_separator];
        
        self.backgroundView = ({
            SSThemedView *v = [[SSThemedView alloc] init];
            v.backgroundColorThemeKey = kColorBackground4;
            v;
        });
        
        [self addSubview:_separator];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL enableSubTitle = !!self.subTitleLabel.text.length;
    BOOL enableArrow = (self.option.type == TTFeedDislikeOptionTypeFeedback || self.option.type == TTFeedDislikeOptionTypeShield || self.option.type == TTFeedDislikeOptionTypeReport);
    CGFloat padding = 15.0;
    CGFloat offsetTop = padding;
    
    self.iconImageView.size = CGSizeMake(24.0, 24.0);
    self.iconImageView.left = padding - 6.0;
    self.iconImageView.centerY = self.height / 2.0;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.left = self.iconImageView.right + 9.0;
    self.titleLabel.top = enableSubTitle ? offsetTop : (offsetTop + 10.0);
    self.titleLabel.width = self.width - self.titleLabel.left - padding;
    offsetTop = self.titleLabel.bottom;
    
    if (enableSubTitle) {
        [self.subTitleLabel sizeToFit];
        self.subTitleLabel.top = offsetTop + 2.0;
        self.subTitleLabel.left = self.titleLabel.left;
        self.subTitleLabel.width = self.width - self.subTitleLabel.left - padding;
        offsetTop = self.subTitleLabel.bottom;
    }
    
    self.accessor.hidden = !enableArrow;
    if (enableArrow) {
        self.accessor.size = CGSizeMake(10.0, 16.0);
        self.accessor.right = self.width - (padding + 3.0);
        self.accessor.centerY = self.height / 2.0;
    }
    
    self.separator.height = [TTDeviceHelper ssOnePixel];
    self.separator.left = padding;
    self.separator.bottom = self.height;
    self.separator.width = self.width - self.separator.left - padding;
}

- (void)configWithOption:(TTFeedDislikeOption *)option showSeparator:(BOOL)showSeparator {
    self.option = option;
    
    UIImage *icon = nil;
    NSString *titleStr = nil;
    NSString *subTitleStr = nil;
    
    NSDictionary *textStrings = [TTFeedDislikeConfig textStrings];
    
    switch (option.type) {
        case TTFeedDislikeOptionTypeUnfollow: {
            icon = [UIImage imageNamed:@"feed_dislike_unfollow" inBundle:FHFeedOperationView.resourceBundle compatibleWithTraitCollection:nil];
            titleStr = option.words.firstObject.name;
        }
            break;
        case TTFeedDislikeOptionTypeUninterest: {
            icon = [UIImage imageNamed:@"dislike" inBundle:FHFeedOperationView.resourceBundle compatibleWithTraitCollection:nil];
            titleStr = textStrings[@"new_dislike_index_dislike_text"];
            subTitleStr = textStrings[@"new_dislike_index_dislike_hint"];
        }
            break;
        case TTFeedDislikeOptionTypeReport: {
            icon = [UIImage imageNamed:@"report" inBundle:FHFeedOperationView.resourceBundle compatibleWithTraitCollection:nil];
            titleStr = textStrings[@"new_dislike_index_report_text"];;
            subTitleStr = textStrings[@"new_dislike_index_report_hint"];
        }
            break;
        case TTFeedDislikeOptionTypeSource: {
            icon = [UIImage imageNamed:@"shield" inBundle:FHFeedOperationView.resourceBundle compatibleWithTraitCollection:nil];
            TTFeedDislikeWord *w = option.words.firstObject;
            titleStr = w.name;
        }
            break;
        case TTFeedDislikeOptionTypeShield: {
            icon = [UIImage imageNamed:@"no_see" inBundle:FHFeedOperationView.resourceBundle compatibleWithTraitCollection:nil];
            titleStr = textStrings[@"new_dislike_nosee_title"];;
            subTitleStr = [option strForSubTitleWithKeywords];
        }
            break;
        case TTFeedDislikeOptionTypeCommand: {
            icon = [UIImage imageNamed:@"feed_dislike_why" inBundle:FHFeedOperationView .resourceBundle compatibleWithTraitCollection:nil];
            titleStr = option.words.firstObject.name;
        }
    }
    
    self.iconImageView.image = icon;
    self.titleLabel.text = titleStr;
    self.subTitleLabel.text = subTitleStr;
    self.separator.hidden = !showSeparator;
    
    [self setNeedsLayout];
}

@end
