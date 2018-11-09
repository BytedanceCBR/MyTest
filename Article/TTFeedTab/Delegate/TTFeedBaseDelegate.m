//
//  TTFeedBaseDelegate.m
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import "TTFeedBaseDelegate.h"
#import "TTFeedSectionHeaderFooterControl.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOriginalData.h"
#import "ExploreCellHelper.h"
#import "ExploreCellBase.h"
#import "TTFeedContainerViewModel.h"
#import "NSObject+FBKVOController.h"
#import "TTHistoryEntryGroup.h"
#import "TTFeedSectionHeaderFooterControl.h"
#import "ExploreCellViewBase.h"
#import "Card+CoreDataClass.h"
#import "ExploreArticleCardCellView.h"
#import "TSVFeedFollowCell.h"

@interface TTFeedBaseDelegate ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) TTFeedContainerViewModel *viewModel;

@end

@implementation TTFeedBaseDelegate

@synthesize dataSource;

#pragma mark - Public

- (void)updateTableView:(UITableView *)tableView viewModel:(TTFeedContainerViewModel *)viewModel {
    [super updateTableView:tableView dataSource:viewModel.allItems];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.viewModel = viewModel;
    WeakSelf;
    [self.KVOController observe:viewModel keyPath:@"allItems" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        self.dataSource = [change valueForKey:NSKeyValueChangeNewKey];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self supportMultiSections] ? self.dataSource.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self supportMultiSections] ? ((TTHistoryEntryGroup *)[self.dataSource objectAtIndex:section]).orderedDataList.count : self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExploreCellBase * cell = nil;
    
    if (indexPath.row < [self maxModelIndexForSection:indexPath.section]) {
        ExploreOrderedData *item = [self modelForIndexPath:indexPath];
        
        cell = [ExploreCellHelper dequeueTableCellForData:item tableView:tableView atIndexPath:indexPath refer:[self.viewModel.delegate refer]];
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            cell.refer = [self.viewModel.delegate refer];
            if ([self.tableView.viewController conformsToProtocol:@protocol(CustomTableViewCellEditDelegate)]) {
                cell.delegate = (id<CustomTableViewCellEditDelegate>)self.tableView.viewController;
            }
            [cell setDataListType:[self.viewModel.delegate listType]];
            [cell refreshWithData:item];
            
            //每个section最后一个cell底部分割线隐藏
            if (indexPath.row == [self tableView:self.tableView numberOfRowsInSection:indexPath.section] -1) {
                cell.cellView.hideBottomLine = YES;
            } else {
                cell.cellView.hideBottomLine = NO;
            }
        }
    }
    
    if (!cell) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preventCrashCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"preventCrashCellIdentifier"];
        }
        cell.textLabel.text = @"";
        return cell;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didGenerateCell:atIndexPath:)]) {
        [self.delegate didGenerateCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self hasSectionHeaderForSection:section] ? [self.delegate sectionHeaderControlHeightForSection:section] : 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TTFeedSectionHeaderFooterControl *control = nil;
    if ([self hasSectionHeaderForSection:section]) {
        control = [self.delegate sectionHeaderControlForSection:section];
    }
    return control;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self hasSectionFooterForSection:section] ? [self.delegate sectionFooterControlHeightForSection:section] : 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    TTFeedSectionHeaderFooterControl *control = nil;
    if ([self hasSectionFooterForSection:section]) {
        control = [self.delegate sectionFooterControlForSection:section];
    }
    return control;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self maxModelIndexForSection:indexPath.section]) {
        ExploreOrderedData *item = [self modelForIndexPath:indexPath];
        
        if ([item isKindOfClass:[ExploreOrderedData class]]) {
            if (!(item.managedObjectContext || ! item.originalData.managedObjectContext)) {
                return 0;//fault的item高度返回0
            }
        }
        
        CGFloat cellWidth = [TTUIResponderHelper splitViewFrameForView:tableView].size.width;
        
        return [ExploreCellHelper heightForData:item cellWidth:cellWidth listType:[self.viewModel.delegate listType]];
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectCellAtIndexPath:isSelected:)]) {
        [self.delegate didSelectCellAtIndexPath:indexPath isSelected:YES];
    }
    
    if (tableView.isEditing) {
        return;
    }
    
    if (indexPath.row >= [self maxModelIndexForSection:indexPath.section]) {
    }
    else {
        ExploreCellBase *cell = [self cellForIndexPath:indexPath];
        [cell didSelectAtIndexPath:indexPath viewModel:self.viewModel];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(didSelectCellAtIndexPath:isSelected:)]) {
        [self.delegate didSelectCellAtIndexPath:indexPath isSelected:NO];
    }
    
    if (tableView.isEditing) {
        return;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self maxModelIndexForSection:indexPath.section]) {
        ExploreCellBase *cell = [self cellForIndexPath:indexPath];
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            [cell willDisplayAtIndexPath:indexPath viewModel:self.viewModel];
        }
    }
    ExploreCellBase *cellV = (ExploreCellBase *)cell;
    if ([self.delegate isKindOfClass:NSClassFromString(@"TTFavoriteViewController")]&&[self.delegate respondsToSelector:@selector(willDisplayCell: atIndexPath:)]) {
        [self.delegate willDisplayCell:cellV atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self maxModelIndexForSection:indexPath.section]) {
        ExploreCellBase *cell = [self cellForIndexPath:indexPath];
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            [cell didEndDisplayAtIndexPath:indexPath viewModel:self.viewModel];
        }
    }
    ExploreCellBase *cellV = (ExploreCellBase *)cell;
    if ([self.delegate isKindOfClass:NSClassFromString(@"TTFavoriteViewController")]&&[self.delegate respondsToSelector:@selector(willDisplayCell: atIndexPath:)]) {
        [self.delegate endDisplayCell:cellV atIndexPath:indexPath];
    }
}

#pragma mark - Helper

- (BOOL)supportMultiSections {
    if (!SSIsEmptyArray(self.dataSource)) {
        id item = [self.dataSource firstObject];
        if ([item isKindOfClass:[ExploreOrderedData class]]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)hasSectionHeaderForSection:(NSUInteger)section {
    return [self.delegate respondsToSelector:@selector(sectionHeaderControlHeightForSection:)]
    && [self.delegate sectionHeaderControlHeightForSection:section] > 0
    && [self.delegate respondsToSelector:@selector(sectionHeaderControlForSection:)]
    && [self.delegate sectionHeaderControlForSection:section];
}

- (BOOL)hasSectionFooterForSection:(NSUInteger)section {
    
    return [self.delegate respondsToSelector:@selector(sectionFooterControlHeightForSection:)]
    && [self.delegate sectionFooterControlHeightForSection:section] > 0
    && [self.delegate respondsToSelector:@selector(sectionFooterControlForSection:)]
    && [self.delegate sectionFooterControlForSection:section];
}

- (NSInteger)maxModelIndexForSection:(NSUInteger)section {
    if ([self supportMultiSections]) {
        NSUInteger maxIndex = 0;
        if (section < self.dataSource.count) {
            maxIndex = ((TTHistoryEntryGroup *)[self.dataSource objectAtIndex:section]).orderedDataList.count;
        }
        return maxIndex;
    } else {
        return self.dataSource.count;
    }
}

- (ExploreOrderedData *)modelForIndexPath:(NSIndexPath *)indexPath {
    if ([self supportMultiSections]) {
        ExploreOrderedData *orderedData = nil;
        if (indexPath.section < self.dataSource.count) {
            orderedData = [((TTHistoryEntryGroup *)[self.dataSource objectAtIndex:indexPath.section]).orderedDataList objectAtIndex:indexPath.row];
        }
        return orderedData;
    } else {
        return (ExploreOrderedData *)[self.dataSource objectAtIndex:indexPath.row];
    }
}

- (ExploreCellBase *)cellForIndexPath:(NSIndexPath *)indexPath {
    ExploreCellBase *cell = nil;
    if (indexPath.row < [self maxModelIndexForSection:indexPath.section]) {
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

@end
