//
//  TTTableViewBaseCellView.m
//  Article
//
//  Created by 杨心雨 on 16/8/19.
//
//

#import "TTTableViewBaseCellView.h"

@implementation TTTableViewBaseCellView

- (NSUInteger)refer {
    return [[self cell] refer];
}

- (void)setOrderedData:(ExploreOrderedData *)orderedData {
    _orderedData = orderedData;
    if (_orderedData) {
        self.originalData = [_orderedData originalData];
    } else {
        self.originalData = nil;
    }
}

- (id)cellData {
    return [self orderedData];
}

- (BOOL)shouldRefresh {
    if ([[self originalData] needRefreshUI]) {
        return [[self originalData] needRefreshUI];
    }
    return NO;
}

- (void)refreshDone {
    if ([self originalData]) {
        [[self originalData] setNeedRefreshUI:NO];
    }
}

@end
