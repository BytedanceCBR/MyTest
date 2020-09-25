//
//  FHNewHouseDetailHeaderMediaSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailHeaderMediaSM.h"

@implementation FHNewHouseDetailHeaderMediaSM

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return YES;
}

- (void)updateDetailModel:(FHDetailNewModel *)model {
    // 添加头滑动图片 && 视频
    FHNewHouseDetailHeaderMediaModel *headerCellModel = [[FHNewHouseDetailHeaderMediaModel alloc] init];
    headerCellModel.albumInfo = model.data.albumInfo;
    headerCellModel.courtTopImage = model.data.courtTopImages;
    headerCellModel.isShowTopImageTab = model.data.isShowTopImageTab;
    self.headerCellModel = headerCellModel;
    self.items = [NSArray arrayWithObject:self.headerCellModel];
}

- (void)updatewithContactViewModel:(FHHouseDetailContactViewModel *)contactViewModel {
    self.headerCellModel.contactViewModel = contactViewModel;
}

@end
