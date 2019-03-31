//
//  FHDetailListViewModel.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHDetailListViewModel.h"
#import "ReactiveObjC.h"
#import "RXCollection.h"

@interface FHDetailListViewModel ()
@end

@implementation FHDetailListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sections = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addSectionPlaceHolder:(id<FHSectionCellPlaceHolder>)placeHolder {
    [placeHolder registerCellToTableView:_tableView];
    [_sections addObject:placeHolder];
    [self adjustSectionOffset];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray<id<FHSectionCellPlaceHolder>>* holders = [_sections rx_filterWithBlock:^BOOL(id<FHSectionCellPlaceHolder> each) {
        return [each isDisplayData];
    }];

    __block NSUInteger count = 0;
    [holders enumerateObjectsUsingBlock:^(id<FHSectionCellPlaceHolder>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        count += [obj numberOfSection];
    }];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numbers = [[self holderAtSection:section] numberOfRowInSection:section];
    return numbers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<FHSectionCellPlaceHolder> holder = [self holderAtSection:indexPath.section];
    UITableViewCell* cell = [holder tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

-(id<FHSectionCellPlaceHolder>)holderAtSection:(NSUInteger)section {
    __block id<FHSectionCellPlaceHolder> result = nil;
    __block NSUInteger index = 0;

    [_sections enumerateObjectsUsingBlock:^(id<FHSectionCellPlaceHolder>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger sectionCount = [obj numberOfSection];
        if ([obj isDisplayData]) {
            if (section >= index && section < index + sectionCount) {
                result = obj;
                *stop = YES;
            } else {
                index += sectionCount;
            }
        } else {
            // do nothing
        }
    }];
    return result;
}

- (void)setTableView:(UITableView *)tableView {
    [self willChangeValueForKey:@"tableView"];
    _tableView = tableView;
    [_sections enumerateObjectsUsingBlock:^(id<FHSectionCellPlaceHolder>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj registerCellToTableView:_tableView];
    }];
    [self didChangeValueForKey:@"tableView"];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<FHSectionCellPlaceHolder> holder = [self holderAtSection:indexPath.section];
    return [holder tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id<FHSectionCellPlaceHolder> holder = [self holderAtSection:section];
    return [holder tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id<FHSectionCellPlaceHolder> holder = [self holderAtSection:section];
    return [holder tableView:tableView heightForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<FHSectionCellPlaceHolder> holder = [self holderAtSection:indexPath.section];
    [holder tableView:tableView didSelectRowAtIndexPath:indexPath];
}

-(void)adjustSectionOffset {
    __block NSUInteger sectionOffset = 0;
    [_sections enumerateObjectsUsingBlock:^(id<FHSectionCellPlaceHolder>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isDisplayData]) {
            [obj setSectionOffset:sectionOffset];
            sectionOffset += [obj numberOfSection];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
