//
//  ArticleSearchBaseCell.h
//  Article
//
//  Created by SunJiangting on 14-7-7.
//
//

#import "SSThemed.h"

#define kArticleSearchBaseCellH 44

@interface ArticleSearchBaseCell : SSThemedTableViewCell

@property (nonatomic, strong) UILabel       * keywordLabel;

@property (nonatomic, strong) UIView        * separatorView;

@property (nonatomic, strong) SSThemedImageView   * iconView;

@end
