//
//  IndexPathMappingCellCoordination.m
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/11.
//

#import "IndexPathMappingCellCoordinator.h"

@interface IndexPathMappingCellCoordinator ()

@end

@implementation IndexPathMappingCellCoordinator

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.renders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addCellRender:(id<TableCellRender>)render atIndexPath:(NSIndexPath *)indexPath {
    _renders[indexPath] = render;
}

- (id<TableCellRender>)cellRenderAtIndexPath:(NSIndexPath *)indexPath {
    return _renders[indexPath];
}

@end
