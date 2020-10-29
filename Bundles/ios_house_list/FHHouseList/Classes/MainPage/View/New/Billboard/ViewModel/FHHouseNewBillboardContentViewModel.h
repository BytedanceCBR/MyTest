//
//  FHHouseNewBillboardContentViewModel.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewComponentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseNewBillboardItemViewModel;
@class FHCourtBillboardPreviewModel;
@interface FHHouseNewBillboardContentViewModel : FHHouseNewComponentViewModel

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *buttonText;
@property (nonatomic, copy, readonly) NSArray<FHHouseNewBillboardItemViewModel *> *items;

- (instancetype)initWithModel:(FHCourtBillboardPreviewModel *)model;

- (void)onClickButton;

@end

NS_ASSUME_NONNULL_END
