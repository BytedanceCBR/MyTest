//
//  FHHouseTableView.m
//  FHHouseList
//
//  Created by bytedance on 2020/11/30.
//

#import "FHHouseTableView.h"
#import "FHHouseNewComponentView.h"
#import "FHHouseNewComponentViewModel.h"
#import "FHHouseCardTableViewCell.h"
#import "FHHouseCardCellViewModelProtocol.h"
#import <ByteDanceKit/UIDevice+BTDAdditions.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import <ByteDanceKit/NSArray+BTDAdditions.h>
#import "FHUserTracker.h"

@interface FHHouseTableView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) id<UITableViewDelegate> customDelegate;
@property (nonatomic, weak) id<UITableViewDataSource> customDataSource;
@end

@implementation FHHouseTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setDelegate:self];
        [self setDataSource:self];
    }
    return self;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    if (delegate != self) {
        self.customDelegate = delegate;
        return;
    }
    
    [super setDelegate:delegate];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    if (dataSource != self) {
        self.customDataSource = dataSource;
        return;
    }
    
    [super setDataSource:dataSource];
}

- (void)registerCellStyles {
    NSDictionary *supportCellStyles = [self.fhHouse_dataSource fhHouse_supportCellStyles];
    for (NSString *cellClassName in [supportCellStyles allValues]) {
        Class cellClass = NSClassFromString(cellClassName);
        if (cellClass) {
            [self registerClass:cellClass forCellReuseIdentifier:cellClassName];
        }
    }
}

- (void)handleAppWillEnterForground {
    NSArray *tableCells = [self visibleCells];
    if (tableCells) {
        [tableCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) {
                [(UITableViewCell<FHHouseCardTableViewCellProtocol> *)obj cellWillEnterForground];
            }
        }];
    }
}

- (void)handleAppDidEnterBackground {
    NSArray *tableCells = [self visibleCells];
    if (tableCells) {
        [tableCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) {
                [(UITableViewCell<FHHouseCardTableViewCellProtocol> *)obj cellDidEnterBackground];
            }
        }];
    }
}

- (NSObject<FHHouseCardCellViewModelProtocol> *)getViewModelAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dataList = [self.fhHouse_dataSource fhHouse_dataList];
    if (indexPath == nil || dataList.count <= indexPath.section) return nil;
    NSArray *items = [dataList btd_objectAtIndex:indexPath.section class:NSArray.class];
    if (!items || items.count <= indexPath.row) return nil;
    id item = [items btd_objectAtIndex:indexPath.row];
    if (![item conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) return nil;
    NSObject<FHHouseCardCellViewModelProtocol> *viewModel = (NSObject<FHHouseCardCellViewModelProtocol> *)item;
    if ([viewModel respondsToSelector:@selector(setCardIndex:)]) {
        viewModel.cardIndex = indexPath.row;
    }
    
    if ([viewModel respondsToSelector:@selector(setCardCount:)]) {
        viewModel.cardCount = items.count;
    }
    return viewModel;
}

- (Class)getCellClassWithViewModel:(NSObject<FHHouseCardCellViewModelProtocol> *)viewModel {
    if (viewModel == nil) return nil;
    
    NSString *itemClassName = NSStringFromClass(viewModel.class);
    if (itemClassName == nil) return nil;
    
    NSDictionary *supportCellStyles = [self.fhHouse_dataSource fhHouse_supportCellStyles];
    NSString *cellClassName = [supportCellStyles btd_objectForKey:itemClassName default:nil];
    Class cellClass = NSClassFromString(cellClassName);
    return cellClass;
}

- (Class)getCellClassAtIndexPath:(NSIndexPath *)indexPath {
    NSObject<FHHouseCardCellViewModelProtocol> *viewModel = [self getViewModelAtIndexPath:indexPath];
    return [self getCellClassWithViewModel:viewModel];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *dataList = [self.fhHouse_dataSource fhHouse_dataList];
    return dataList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *dataList = [self.fhHouse_dataSource fhHouse_dataList];
    NSArray *items = [dataList btd_objectAtIndex:section class:NSArray.class];
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject<FHHouseCardCellViewModelProtocol> *viewModel = [self getViewModelAtIndexPath:indexPath];
    if (viewModel == nil) return [[UITableViewCell alloc] init];
    
    Class cellClass = [self getCellClassWithViewModel:viewModel];
    if (cellClass == nil) return [[UITableViewCell alloc] init];
    
    UITableViewCell *cell = (UITableViewCell<FHHouseCardTableViewCellProtocol> *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    if (![cell isKindOfClass:cellClass] || ![cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) return [[UITableViewCell alloc] init];
    
    [(UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell setViewModel:viewModel];
    return cell;
}

///其他delegate按需扩展

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) {
        UITableViewCell<FHHouseCardTableViewCellProtocol> *componentCell = (UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell;
        if ([componentCell respondsToSelector:@selector(cellWillShowAtIndexPath:)]) {
            [componentCell cellWillShowAtIndexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol) ]) {
        UITableViewCell<FHHouseCardTableViewCellProtocol> *componentCell = (UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell;
        if ([componentCell respondsToSelector:@selector(cellDidEndShowAtIndexPath:)]) {
            [componentCell cellDidEndShowAtIndexPath:indexPath];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject<FHHouseCardCellViewModelProtocol> *viewModel = [self getViewModelAtIndexPath:indexPath];
    if (viewModel == nil) return 0.0f;
    
    Class cellClass = [self getCellClassWithViewModel:viewModel];
    if (cellClass == nil) return 0.0f;
    
    if (![cellClass conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)] || ![cellClass respondsToSelector:@selector(viewHeightWithViewModel:)]) return 0.0f;
    return [cellClass viewHeightWithViewModel:viewModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.customDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.customDelegate tableView:tableView heightForHeaderInSection:section];
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.customDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.customDelegate tableView:tableView heightForFooterInSection:section];
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol) ]) {
        UITableViewCell<FHHouseCardTableViewCellProtocol> *componentCell = (UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell;
        if ([componentCell respondsToSelector:@selector(cellDidClickAtIndexPath:)]) {
            [componentCell cellDidClickAtIndexPath:indexPath];
        }
    }
}

///其他delegate按需扩展

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.fhHouse_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.fhHouse_delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.fhHouse_delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.fhHouse_delegate scrollViewDidZoom:scrollView];
    }
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.fhHouse_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.fhHouse_delegate scrollViewWillBeginDragging:scrollView];
    }
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.fhHouse_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.fhHouse_delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.fhHouse_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.fhHouse_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.fhHouse_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.fhHouse_delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.fhHouse_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.fhHouse_delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.fhHouse_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.fhHouse_delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

@end
