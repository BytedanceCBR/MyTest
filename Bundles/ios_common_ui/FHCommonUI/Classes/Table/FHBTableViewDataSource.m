//
//  FHBTableViewDataSource.m
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/14.
//

#import "FHBTableViewDataSource.h"
#import "TableCellRender.h"
@interface FHBTableViewDataSource ()
@property (nonatomic, strong) id<TableViewCellCoordinator> coordinator;
@property (nonatomic, strong) id<FlatRawTableRepository> repository;
@end

@implementation FHBTableViewDataSource

- (instancetype)initWithCoordinator:(id<TableViewCellCoordinator>)coordinator withRespoitory:(nonnull id<FlatRawTableRepository>)repository
{
    self = [super init];
    if (self) {
        self.coordinator = coordinator;
        self.repository = repository;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_repository numberOfSections];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_repository numberOfRowInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<TableCellRender> render = [_coordinator cellRenderAtIndexPath:indexPath];
    NSString* reused = [_coordinator cellReusedIdentiferForIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reused];
    [render renderCell:cell withModel:[_repository modelAtIndexPath:indexPath] atIndexPath:indexPath];
    if (cell == nil) {

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<TableCellRender> render = [_coordinator cellRenderAtIndexPath:indexPath];
    if ([render respondsToSelector:@selector(selectedWithModel:)]) {
        [render selectedWithModel:[_repository modelAtIndexPath:indexPath]];
    }
}

@end
