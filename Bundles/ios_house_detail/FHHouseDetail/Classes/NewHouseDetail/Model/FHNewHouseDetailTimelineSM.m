//
//  FHNewHouseDetailTimelineSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailTimelineSM.h"


@implementation FHNewHouseDetailTimelineSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    NSMutableArray *items = [NSMutableArray array];
    FHNewHouseDetailTimeLineCellModel *newsCellModel = [[FHNewHouseDetailTimeLineCellModel alloc] init];
    if (model.data.timeline.list.count > 0) {
        newsCellModel.timeLineModel = model.data.timeline;
        self.newsCellModel = newsCellModel;
        [items addObject:self.newsCellModel];
    } else {
        self.newsCellModel = nil;
    }
    self.items = items.copy;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
