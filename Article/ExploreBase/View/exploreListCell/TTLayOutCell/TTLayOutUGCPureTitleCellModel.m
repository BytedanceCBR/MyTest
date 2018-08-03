//
//  TTLayOutUGCPureTitleCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutUGCPureTitleCellModel.h"

@implementation TTLayOutUGCPureTitleCellModel

- (void)calculateOtherFramesWithContainWidth:(CGFloat)containWidth
{
    CGFloat x = self.originX;
    CGFloat y = self.originY;
    
    Article *article = [self.orderedData article];
    if (article) {
        
        NSString *titleStr = [TTLayOutCellDataHelper getTitleStringWithOrderedData:self.orderedData];
        
        CGSize titleSize = CGSizeMake(containWidth, 0);
        NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kTitleViewFontSize() lineHeight:kTitleViewLineHeight() lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:NO];
        self.titleAttributedStr = titleAttributedStr;
        titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kTitleViewFontSize() forWidth:containWidth forLineHeight:kTitleViewLineHeight() constraintToMaxNumberOfLines:kTitleViewLineNumber()
                            isBold:NO];
        CGFloat titlePadding = kTitleViewLineHeight() - kTitleViewFontSize();
        CGFloat titleY = y - titlePadding / 2;
        y += titleSize.height - titlePadding;
        CGRect titleLabelFrame = CGRectMake(x, titleY, titleSize.width, titleSize.height);
        self.titleLabelFrame = titleLabelFrame;
        self.titleLabelHidden = NO;
        self.titleLabelNumberOfLines = kTitleViewLineNumber();
        
        BOOL displayAbstractView = [TTArticleCellHelper shouldDisplayAbstractView:article listType:self.listType mustShow:[self.orderedData isShowAbstract]];
        NSString *abstractString = [TTLayOutCellDataHelper getAbstractStringWithOrderedData:self.orderedData];
        
        if (displayAbstractView && !isEmptyString(abstractString)) {
            // 显示摘要标题位于图片上方
            y += kPaddingTitleToAbstract();
            
            CGSize abstractSize = CGSizeMake(containWidth, 0);
            NSAttributedString *abstractAttributedStr = [TTLabelTextHelper attributedStringWithString:abstractString fontSize:kAbstractViewFontSize() lineHeight:kAbstractViewLineHeight() lineBreakMode:NSLineBreakByTruncatingTail];
            self.abstractAttributedStr = abstractAttributedStr;
            abstractSize.height = [TTLabelTextHelper heightOfText:abstractString fontSize:kAbstractViewFontSize() forWidth:abstractSize.width forLineHeight:kAbstractViewLineHeight() constraintToMaxNumberOfLines:kAbstractViewLineNumber()];
            CGFloat abstractPadding = kAbstractViewLineHeight() - kAbstractViewFontSize();
            CGFloat abstractY = y - abstractPadding / 2;
            y += abstractSize.height - abstractPadding;
            CGRect abstractLabelFrame = CGRectMake(x, abstractY, abstractSize.width, abstractSize.height);
            self.abstractLabelFrame = abstractLabelFrame;
            self.abstractLabelHidden = NO;
            self.abstractLabelNumberOfLines = kAbstractViewLineNumber();
            self.abstractLabelTextColorThemeKey = kColorText2;
        }
        else{
            self.abstractLabelHidden = YES;
        }
        
        BOOL displayCommentView = [TTArticleCellHelper shouldDisplayCommentView:article listType:self.listType];
        NSString *commentContent = [TTLayOutCellDataHelper getCommentStringWithOrderedData:self.orderedData];
        if (displayCommentView && !isEmptyString(commentContent)) {
            y += kPaddingTitleOrAbstractToComment();
            CGRect commentFrame;
            NSAttributedString *commentAttributedStr = [TTLabelTextHelper attributedStringWithString:commentContent fontSize:kCommentViewFontSize() lineHeight:kCommentViewLineHeight() lineBreakMode:NSLineBreakByTruncatingTail];
            self.commentAttributedStr = commentAttributedStr;
            CGFloat commentHeight = [TTLabelTextHelper heightOfText:commentContent fontSize:kCommentViewFontSize() forWidth:containWidth forLineHeight:kCommentViewLineHeight() constraintToMaxNumberOfLines:kCommentViewLineNumber()];
            CGFloat commentPadding = kCommentViewLineHeight() - kCommentViewFontSize();
            CGFloat commentY = y - commentPadding / 2;
            commentFrame = CGRectMake(x, commentY , containWidth, commentHeight);
            self.commentLabelFrame = commentFrame;
            self.commentLabelHidden = NO;
            self.commentLabelNumberOfLines = kCommentViewLineNumber();
            self.commentLabelTextColorThemeKey = kCommentViewTextColor();
            self.commentLabelUserInteractionEnabled = YES;
            
            y += commentHeight - commentPadding / 2;
        }
        else{
            self.commentLabelHidden = YES;
        }
        
        y += kPaddingInfoTop();
        
        CGSize infoSize = [TTArticleCellHelper getInfoSize:containWidth];
        
        NSString *typeString = [TTLayOutCellDataHelper getTypeStringWithOrderedData:self.orderedData];
        if (!isEmptyString(typeString)) {
            CGSize typeSize = [typeString sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kTagViewFontSize()]}];
            typeSize = CGSizeMake(ceilf(typeSize.width), ceilf(typeSize.height));
            typeSize.width = ceilf(typeSize.width + kTagViewPaddingHorizontal() * 2);
            typeSize.height = kTagViewHeight();
            CGFloat typeLabelOriginY = ceilf(y + (infoSize.height - typeSize.height) / 2);
            CGRect typeLabelFrame = CGRectMake(x, typeLabelOriginY, typeSize.width, typeSize.height);
            self.typeLabelFrame = typeLabelFrame;
            
            x += typeSize.width + 5;
            self.typeLabelHidden = NO;
        }
        else{
            self.typeLabelHidden = YES;
        }
        
        if ([self.orderedData isShowDigButton]){
            self.digButtonImageName = @"comment_like_icon";
            self.digButtonSelectedImageName = @"comment_like_icon_press";
            self.digButtonTextColorThemeKey = kColorText13;
            self.digButtonFontSize = kInfoViewFontSize();
            self.digButtonContentInsets = UIEdgeInsetsMake(0, 0, 0, 5);
            self.digButtonTitleInsets = UIEdgeInsetsMake(0, 5, 0, -5);
            CGRect digButtonFrame = CGRectMake(x, y, 60, kInfoViewHeight());
            self.digButtonFrame = digButtonFrame;
            self.digButtonHidden = NO;
            x += 60;
        }
        else{
            self.digButtonHidden = YES;
        }
        
        if ([self.orderedData isShowComment]) {
            self.commentButtonImageName = @"comment_icon_old";
            self.commentButtonTextColorThemeKey = kColorText9;
            self.commentButtonFontSize = kInfoViewFontSize();
            self.commentButtonContentInsets = UIEdgeInsetsMake(0, 0, 0, 5);
            self.commentButtonTitleInsets = UIEdgeInsetsMake(0, 5, 0, -5);
            CGRect commentButtonFrame = CGRectMake(x, y, 60, kInfoViewHeight());
            self.commentButtonFrame = commentButtonFrame;
            self.commentButtonHidden = NO;
        }
        else{
            self.commentButtonHidden = YES;
        }
        
        self.infoBarOriginY = y;
        self.infoBarContainWidth = containWidth;
        self.hideTimeForRightPic = NO;
        [self calculateTimeLabelWithY:y withContainWidth:containWidth];
        
        y += infoSize.height;
        y += kPaddingBottom();
        self.cellCacheHeight = y;
    }

}

@end
