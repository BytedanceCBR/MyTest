//
//  ExploreCellCommentView.m
//  Article
//
//  Created by Chen Hong on 14-9-9.
//
//

#import "ExploreArticleCellCommentView.h"
#import "NewsUserSettingManager.h"
#import "TTLabelTextHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "Article.h"
#import "NSDictionary+TTAdditions.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

@interface ExploreArticleCellCommentView ()

@end



@implementation ExploreArticleCellCommentView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.clipsToBounds = YES;
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellCommentViewHorizontalPadding, kCellCommentViewVerticalPadding - kCellCommentViewCorrect, 0, 0)];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = kCellCommentViewMaxLine;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.font = [UIFont systemFontOfSize:kCellCommentViewFontSize];
        _contentLabel.textColor = [UIColor tt_themedColorForKey:kCellCommentViewTextColor];
        _contentLabel.clipsToBounds = YES;
        [self addSubview:_contentLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged:) name:kSettingFontSizeChangedNotification object:nil];
        
        [self themeChanged:nil];
    }
    
    return self;
}

- (void)fontChanged:(NSNotification*)notification
{
    _contentLabel.font = [UIFont systemFontOfSize:kCellCommentViewFontSize];
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    [self updateContentWithNormalColor];
    _contentLabel.textColor = [UIColor tt_themedColorForKey:kColorText2];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateContentWithHighlightColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateContentWithNormalColor];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateContentWithNormalColor];
}

- (void)handleTapGestureRecognizer:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(exploreArticleCellCommentViewSelected:)])
    {
        [self updateContentWithHighlightColor];
        [self performSelector:@selector(updateContentWithNormalColor) withObject:nil afterDelay:0.25];
        [_delegate exploreArticleCellCommentViewSelected:self];
    }
}

- (void)updateContentWithHighlightColor
{
    UIColor *highlightColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@Highlighted", kCellCommentViewBackgroundColor]];
    self.backgroundColor = highlightColor;
    _contentLabel.backgroundColor = highlightColor;

    //self.layer.borderColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@Highlighted", kCellCommentViewBorderColor]].CGColor;
    [self updateBackgroundWithHighlightedColor:YES];
}

- (void)updateContentWithNormalColor
{
    UIColor *normalColor = [UIColor clearColor];
    self.backgroundColor = normalColor;
    _contentLabel.backgroundColor = normalColor;

    //self.layer.borderColor = [UIColor tt_themedColorForKey:kCellCommentViewBorderColor].CGColor;
    [self updateBackgroundWithHighlightedColor:NO];
}

- (void)handleLongPressRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    //do nothing
}

- (void)updateBackgroundWithHighlightedColor:(BOOL)highlighted
{
    _contentLabel.textColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@%@", kCellCommentViewTextColor, (highlighted ? @"Highlighted" : @"")]];
    
    _contentLabel.highlightedTextColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@%@", kCellCommentViewTextColor, @"Highlighted"]];
    
    _contentLabel.attributedText = [[self class] commentAttributedStrFromCommentDict:self.currentCommentData highlighted:highlighted];
    _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)reloadCommentDict:(NSDictionary *)commentDict cellWidth:(CGFloat)cellWidth {
    self.currentCommentData = commentDict;
    
    [self updateBackgroundWithHighlightedColor:NO];
}

- (void)layoutSubviews {
    _contentLabel.frame = CGRectMake(self.contentLabel.frame.origin.x, self.contentLabel.frame.origin.y, self.frame.size.width - 2 * kCellCommentViewHorizontalPadding, self.frame.size.height - kCellCommentViewVerticalPadding * 2 + kCellCommentViewCorrect);
}

+ (NSAttributedString *)commentAttributedStrFromCommentDict:(NSDictionary *)commentDic highlighted:(BOOL)highlighted {
    NSString *text = [commentDic tt_stringValueForKey:@"text"];
    
    NSString *userName      = [commentDic tt_stringValueForKey:@"user_name"];
    
    NSDictionary *mediaInfo = [commentDic tt_dictionaryValueForKey:@"media_info"];
    NSString *mediaName     = [mediaInfo tt_stringValueForKey:@"name"];
    
    BOOL isZZ = ([commentDic tt_intValueForKey:@"isZZ"] > 0);
    NSString *name          = isZZ ? mediaName : userName;
    
    //NSInteger length = userName.length;
    //BOOL bVerified = ([commentDic intValueForKey:@"user_verified" defaultValue:0] > 0);
    
    
    //NSString *content = [NSString stringWithFormat:@"%@%@%@：%@", userName, (bVerified?@"V":@""), (isZZ?@" 转载":@""), text];
    NSString *content = [NSString stringWithFormat:@"%@：%@", name, text];
    
    NSMutableAttributedString *attributeString = [TTLabelTextHelper attributedStringWithString:content fontSize:kCellCommentViewFontSize lineHeight:kCellCommentViewLineHeight];
    
    
//    UIColor *nameColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@%@", kCellCommentViewUserTextColor, (highlighted ? @"Highlighted" : @"")]];
//    NSMutableDictionary *nameAttr = [NSMutableDictionary dictionary];
//    [nameAttr setValue:nameColor forKey:NSForegroundColorAttributeName];
//    [nameAttr setValue:[UIFont systemFontOfSize:kCellCommentViewFontSize] forKey:NSFontAttributeName];
//    
//    [attributeString setAttributes:nameAttr range:NSMakeRange(0, length)];
    
//    if (bVerified) {
//        NSDictionary *dic = @{
//                              NSForegroundColorAttributeName : [UIColor colorWithHexString:@"ffb400"],
//                              NSFontAttributeName : [UIFont boldSystemFontOfSize:kCellCommentViewFontSize]
//                              };
//        [attributeString setAttributes:dic range:NSMakeRange(length, 1)];
//    }
    return attributeString;
}

@end
