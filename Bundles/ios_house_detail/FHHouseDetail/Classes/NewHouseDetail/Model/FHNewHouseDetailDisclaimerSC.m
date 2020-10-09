//
//  FHNewHouseDetailDisclaimerSC.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/9.
//

#import "FHNewHouseDetailDisclaimerSC.h"
#import "FHNewHouseDetailDisclaimerSM.h"
#import "FHNewHouseDetailDisclaimerCollectionCell.h"

@implementation FHNewHouseDetailDisclaimerSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNewHouseDetailDisclaimerSM *model = (FHNewHouseDetailDisclaimerSM *)self.sectionModel;
    return [FHNewHouseDetailDisclaimerCollectionCell cellSizeWithData:model.disclaimerModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailDisclaimerSM *model = (FHNewHouseDetailDisclaimerSM *)self.sectionModel;
    FHNewHouseDetailDisclaimerCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailDisclaimerCollectionCell class] withReuseIdentifier:NSStringFromClass([model.disclaimerModel class]) forSectionController:self atIndex:index];
    cell.clickFeedback = ^{
        [weakSelf clickFeedbackLog];
    };
    [cell refreshWithData:model.disclaimerModel];
    return cell;
}

-(void)clickFeedbackLog{
    NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
    [tracerDic removeObjectsForKeys:@[@"card_type"]];
    [tracerDic removeObjectsForKeys:@[@"rank"]];
    [tracerDic removeObjectsForKeys:@[@"element_from"]];
    [tracerDic removeObjectForKey:@"origin_search_id"];
    [FHUserTracker writeEvent:@"click_feedback" params:tracerDic];
}

@end
