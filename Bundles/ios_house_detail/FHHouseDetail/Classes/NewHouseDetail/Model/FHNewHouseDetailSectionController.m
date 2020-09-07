//
//  FHNewHouseDetailSectionController.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionController.h"
#import "FHNewHouseDetailSectionModel.h"

@implementation FHNewHouseDetailSectionController

- (void)didUpdateToObject:(id)object {
    if (object && [object isKindOfClass:[FHNewHouseDetailSectionModel class]]) {
        self.sectionModel = (FHNewHouseDetailSectionModel *)object;
    }
}

@end
