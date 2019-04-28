//
//  TTFeedBaseDelegate.h
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import "TTTableViewBaseDelegate.h"

@class ExploreCellBase;
@class TTFeedContainerViewModel;
@class TTFeedSectionHeaderFooterControl;

@protocol TTFeedBaseProtocol <NSObject>

@required
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected;

@optional
- (TTFeedSectionHeaderFooterControl *)sectionHeaderControlForSection:(NSUInteger)section;
- (CGFloat)sectionHeaderControlHeightForSection:(NSUInteger)section;
- (TTFeedSectionHeaderFooterControl *)sectionFooterControlForSection:(NSUInteger)section;
- (CGFloat)sectionFooterControlHeightForSection:(NSUInteger)section;
- (void)didGenerateCell:(ExploreCellBase *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)willDisplayCell:(ExploreCellBase *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)endDisplayCell:(ExploreCellBase *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface TTFeedBaseDelegate : TTTableViewBaseDelegate

@property (nonatomic, weak) id<TTFeedBaseProtocol> delegate;

- (void)updateTableView:(UITableView *)tableView viewModel:(TTFeedContainerViewModel *)viewModel;

@end
