//
//  ExploreListPureTitleCellView.m
//  Article
//
//  Created by Chen Hong on 14-9-9.
//
//

#import "ExploreArticlePureTitleStickCellView.h"
#import "ExploreArticleCellViewConsts.h"
#import "Article.h"
#import "ExploreOrderedData.h"
#import "TTLabelTextHelper.h"

#import "NewsUserSettingManager.h"
#import "ExploreCellHelper.h"
#import "TTLabelTextHelper.h"

@interface ExploreArticlePureTitleStickCellView ()

@property (nonatomic,strong) UILabel * stickLabel;
@end

@implementation ExploreArticlePureTitleStickCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _stickLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        _stickLabel.textAlignment  = NSTextAlignmentCenter;
        _stickLabel.font = [UIFont systemFontOfSize:kCellTypeLabelFontSize];
        _stickLabel.layer.cornerRadius = kCellTypeLabelCornerRadius;
        _stickLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _stickLabel.clipsToBounds = YES;
        
        self.titleLabel.font = [UIFont systemFontOfSize:kCellCommentViewFontSize];
        [self addSubview:_stickLabel];
    }
    return self;
}

- (void)updateStickLabel
{
    [ExploreCellHelper layoutTypeLabel:self.stickLabel withOrderedData:self.orderedData];
}
- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if (self.orderedData && self.orderedData.managedObjectContext) {
        Article *article = self.orderedData.article;
        if (article && article.managedObjectContext) {
            [self updateTitleLabel];
            [self updateStickLabel];
            
        } else {
            self.typeLabel.height = 0;
            self.stickLabel.height = 0;
        }
    }
}

- (void)updateTitleLabel
{
    if (self.titleLabel)
    {
        [super updateContentColor];
        
        if (!isEmptyString(self.orderedData.article.title)) {
            BOOL isBoldFont = [TTDeviceHelper isPadDevice];
            
            NSString * intentStr = self.orderedData.stickLabel;
            if (!intentStr) {
                intentStr = NSLocalizedString(@"置顶", nil);
            }
            CGRect rect = [intentStr boundingRectWithSize:CGSizeMake(150, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.stickLabel.font} context:nil];
            CGFloat firstLineIndent = rect.size.width+10;
            self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.orderedData.article.title fontSize:[NewsUserSettingManager fontSizeFromNormalSize:15.0 isWidescreen:NO] lineHeight:[NewsUserSettingManager fontSizeFromNormalSize:15.0 isWidescreen:NO]+3 lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:isBoldFont firstLineIndent:firstLineIndent];
            self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            self.titleLabel.numberOfLines = kCellRightPicTitleLabelMaxLine;
            if ([self.orderedData respondsToSelector:@selector(isVideoPGCCard)] &&
                [self.orderedData isVideoPGCCard]) {
                self.titleLabel.numberOfLines = kCellTitleLabelMaxLine;
            }
        } else {
            self.titleLabel.text = @"";
        }
    }
}
- (void)refreshUI
{
    //置顶 没有底部的评论 时间 等UI控件
    self.infoBarView.frame = CGRectZero;
    self.infoBarView.hidden = YES;

    NSString * intentStr = self.orderedData.stickLabel;
    if (!intentStr) {
        intentStr = NSLocalizedString(@"置顶", nil);
    }
    self.titleLabel.frame = [[self class] frameForTitleLabel:self.titleLabel.text cellWidth:self.width indentString:intentStr];

    CGRect rect = [self.stickLabel.text boundingRectWithSize:CGSizeMake(150, kCellTypeLabelHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellTypeLabelFontSize]} context:nil];

    self.stickLabel.width = rect.size.width + kCellTypeLabelInnerPadding * 2;
    self.stickLabel.height = kCellTypeLabelHeight;
    self.stickLabel.top = ceil(kCellTopPadding + (kCellCommentViewLineHeight - kCellTypeLabelHeight) * 0.75);
    self.stickLabel.left = kCellLeftPadding;
    [self bringSubviewToFront: self.stickLabel];
    
    [self layoutUnInterestedBtn];
    [self layoutBottomLine];
}

- (void)layoutUnInterestedBtn
{
    [self.unInterestedButton removeFromSuperview];
    [self addSubview:self.unInterestedButton];
    
    CGFloat centerX = self.width - kCellRightPadding - kCellUninterestedButtonWidth / 2;
    CGPoint p = CGPointMake(centerX, self.height / 2);
    p = [self convertPoint:p fromView:self];
    self.unInterestedButton.center = p;
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
}




+ (CGRect)frameForTitleLabel:(NSString *)title cellWidth:(CGFloat)width indentString:(NSString *)intentStr
{
    if (isEmptyString(title)) {
        return CGRectZero;
    }
    
    float lineH = kCellCommentViewLineHeight;
    
    CGFloat titleWidth = width - kCellLeftPadding - kCellRightPadding - kCellUninterestedButtonRightPadding;
    
    CGRect rect = [intentStr boundingRectWithSize:CGSizeMake(150, kCellTypeLabelHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellTypeLabelFontSize]} context:nil];
    CGFloat firstLineIndent = rect.size.width + kCellTypeLabelInnerPadding * 2 + kCellTypelabelRightPaddingToInfoLabel;

    CGFloat titleHeight = [TTLabelTextHelper heightOfText:title fontSize:[NewsUserSettingManager fontSizeFromNormalSize:15.0 isWidescreen:NO] forWidth:titleWidth forLineHeight:lineH constraintToMaxNumberOfLines:kCellTitleLabelMaxLine firstLineIndent:firstLineIndent textAlignment:NSTextAlignmentLeft];
    
    CGRect frame = CGRectZero;
    frame.origin.x = kCellLeftPadding;
    frame.origin.y = kCellTopPadding;
    frame.size.width = titleWidth;
    frame.size.height = titleHeight;
    
    return CGRectIntegral(frame);
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            return cacheH;
        }
        
        Article *article = orderedData.article;
        NSString * intentStr = orderedData.stickLabel;
        if (!intentStr) {
            intentStr = NSLocalizedString(@"置顶", nil);
        }

        CGRect titleLabelRect = [[self class] frameForTitleLabel:article.title cellWidth:width indentString:intentStr];
        CGFloat height = kCellTopPadding + kCellBottomPadding + titleLabelRect.size.height;

       // [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        return height;
    }
    
    return 0.f;
}

@end
