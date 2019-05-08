//
//  FHDetailPageCellCoordinator.m
//  AKCommentPlugin
//
//  Created by leo on 2018/11/19.
//

#import "FHDetailPageCellCoordinator.h"

@interface FHDetailPageCellCoordinator ()
{
    NSMutableArray<FHSectionNode*>* _sections;
}
@end

@implementation FHDetailPageCellCoordinator

- (nonnull id<TableCellRender>)cellRenderAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return nil;
}

- (nonnull NSString *)cellReusedIdentiferForIndexPath:(nonnull NSIndexPath *)incexPath {
    return @"cycle";
}

- (void)addSectionNode:(FHSectionNode*)sectionNode {
    [_sections addObject:sectionNode];
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowInSection:(NSInteger)section {
    return 1;
}

- (id)modelAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

@end
