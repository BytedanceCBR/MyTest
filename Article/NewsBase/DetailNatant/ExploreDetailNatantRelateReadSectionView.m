//
//  ExploreDetailNatantRelateReadSectionView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-24.
//
//

#import "ExploreDetailNatantRelateReadSectionView.h"
#import "ArticleCommentHeaderView.h"
#import "SSThemed.h"

#define kTitleLeftPadding 20
#define kTitleTopPadding 15

@interface ExploreDetailNatantRelateReadSectionView ()

@property(nonatomic, strong)SSThemedLabel * titleLabel;
@property(nonatomic, assign)CGFloat left;
@end

@implementation ExploreDetailNatantRelateReadSectionView

- (id)initWithWidth:(CGFloat)width left:(CGFloat)left
{
    self = [super initWithWidth:width];
    if (self) {
        _left = left;
        self.titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColorThemeKey = kColorText3;
        _titleLabel.font = [UIFont systemFontOfSize:12.f];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        self.backgroundColor = [UIColor clearColor];
        [self reloadThemeUI];
    }
    return self;
}

- (void)refreshWithWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    
    [self refreshUI];
}

- (void)refreshUI
{
    [_titleLabel sizeToFit];
    _titleLabel.origin = CGPointMake(_left, kTitleTopPadding);
    self.height = kTitleTopPadding + _titleLabel.height;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
}

- (void)refreshTitle:(NSString *)title
{
    _titleLabel.text = title;
    [self refreshUI];
}

@end
