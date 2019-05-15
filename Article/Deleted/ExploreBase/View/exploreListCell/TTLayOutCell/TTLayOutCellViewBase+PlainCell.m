//
//  TTLayOutCellViewBase+PlainCell.m
//  Article
//
//  Created by 王双华 on 16/11/11.
//
//

#import "TTLayOutCellViewBase+PlainCell.h"

@implementation TTLayOutCellViewBase (PlainCell)

//- (void)setupSubviewsForPlainCell
//{
//    /** 关注栏 */
//    TTArticleCellEntityWordView *entityWordView = [[TTArticleCellEntityWordView alloc] initWithFrame:CGRectZero];
//    [self addSubview:entityWordView];
//    self.entityWordView = entityWordView;
//}

//- (void)setFrameAndHiddenForPlainCell
//{
//    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
//    
//    self.entityWordView.frame = cellLayOut.entityWordViewFrame;
//    self.entityWordView.hidden = cellLayOut.entityWordViewHidden;
//}
//
//- (void)updateTypeLabelForPlainCell
//{
//    if ([self.orderedData.originalData.userRepined boolValue] &&
//        self.listType != ExploreOrderedDataListTypeFavorite && self.listType != ExploreOrderedDataListTypeHistory) {
//        self.typeLabel.textColor = [UIColor tt_themedColorForKey:kCellTypeLabelTextRed];
//        self.typeLabel.layer.borderColor = [UIColor tt_themedColorForKey:kCellTypeLabelLineRed].CGColor;
//    }
//    else{
//        [ExploreCellHelper colorTypeLabel:self.typeLabel orderedData:self.orderedData];
//    }
//    NSString *typeString = [TTLayOutCellDataHelper getTypeStringWithOrderedData:self.orderedData];
//    self.typeLabel.text = typeString;
//}
//
//- (void)updateAbstractLabelForPlainCell
//{
//    self.abstractLabel.numberOfLines = 0;
//    self.abstractLabel.textColorThemeKey = kCellAbstractViewTextColor;
//    self.abstractLabel.attributedText = self.orderedData.cellLayOut.abstractAttributedStr;
//}
//
//- (void)updateCommentLabelForPlainCell
//{
//    self.commentLabel.textColorThemeKey = kCellCommentViewTextColor;
//    self.commentLabel.highlightedTextColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@%@", kCellCommentViewTextColor, @"Highlighted"]];
//    self.commentLabel.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
//    self.commentLabel.numberOfLines = kCellCommentViewMaxLine;
//    self.commentLabel.attributedText = self.orderedData.cellLayOut.commentAttributedStr;
//    self.commentLabel.userInteractionEnabled = YES;
//}
//
//- (void)updateEntityWordView
//{
//    if (self.orderedData.article.entityWordInfoDict){
//        [self.entityWordView updateEntityWordViewWithOrderedData:self.orderedData];
//    }
//}
//- (void)setFrameAndHiddenForPlainCell
//{
//    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
//    
//    self.logoImageView.frame = cellLayOut.logoImageViewFrame;
//    self.logoImageView.hidden = cellLayOut.logoImageViewHidden;
//    
//    self.entityWordView.frame = cellLayOut.entityWordViewFrame;
//    self.entityWordView.hidden = cellLayOut.entityWordViewHidden;
//}
//
//- (void)updateTypeLabelForPlainCell
//{
//    if ([self.orderedData.originalData.userRepined boolValue] &&
//        self.listType != ExploreOrderedDataListTypeFavorite && self.listType != ExploreOrderedDataListTypeReadHistory && self.listType != ExploreOrderedDataListTypePushHistory) {
//        self.typeLabel.textColor = [UIColor tt_themedColorForKey:kCellTypeLabelTextRed];
//        self.typeLabel.layer.borderColor = [UIColor tt_themedColorForKey:kCellTypeLabelLineRed].CGColor;
//    }
//    else{
//        [ExploreCellHelper colorTypeLabel:self.typeLabel orderedData:self.orderedData];
//    }
//    NSString *typeString = [TTLayOutCellDataHelper getTypeStringWithOrderedData:self.orderedData];
//    self.typeLabel.text = typeString;
//}
//
//- (void)updateAbstractLabelForPlainCell
//{
//    self.abstractLabel.numberOfLines = 0;
//    self.abstractLabel.textColorThemeKey = kCellAbstractViewTextColor;
//    self.abstractLabel.attributedText = self.orderedData.cellLayOut.abstractAttributedStr;
//}
//
//- (void)updateCommentLabelForPlainCell
//{
//    self.commentLabel.textColorThemeKey = kCellCommentViewTextColor;
//    self.commentLabel.highlightedTextColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@%@", kCellCommentViewTextColor, @"Highlighted"]];
//    self.commentLabel.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
//    self.commentLabel.numberOfLines = kCellCommentViewMaxLine;
//    self.commentLabel.attributedText = self.orderedData.cellLayOut.commentContentAttributedStr;
//    self.commentLabel.userInteractionEnabled = YES;
//}
//
//- (void)updateLogoImageView {
//    SSImageInfosModel *iconModel = [TTLayOutCellDataHelper getLogoImageModelWithOrderedData:self.orderedData];
//    [self.logoImageView setImageWithModel:iconModel];
//}

@end
