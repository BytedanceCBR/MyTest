//
//  TTArticleSearchCell.h
//  Article
//
//  Created by yangning on 2017/4/17.
//
//

#import "SSThemed.h"

@class TTArticleSearchCellItemViewModel;
@interface TTArticleSearchCell : SSThemedTableViewCell

- (void)configureWithItemViewModel:(TTArticleSearchCellItemViewModel *)viewModel
                        atSubIndex:(NSInteger)subIndex;

@end

@class TTArticleSearchHeaderCellViewModel;
@interface TTArticleSearchHeaderCell : SSThemedTableViewCell

@property (nonatomic, readonly) SSThemedLabel *titleLabel;
@property (nonatomic, readonly) SSThemedButton *actionButton;

- (void)configureWithViewModel:(TTArticleSearchHeaderCellViewModel *)viewModel;

@end

@interface TTArticleSearchFooterCell : SSThemedTableViewCell

@end

@interface TTArticleSearchInboxCell : SSThemedTableViewCell

- (void)configureWithItemViewModel:(TTArticleSearchCellItemViewModel *)viewModel
                        atSubIndex:(NSInteger)subIndex;

@end
