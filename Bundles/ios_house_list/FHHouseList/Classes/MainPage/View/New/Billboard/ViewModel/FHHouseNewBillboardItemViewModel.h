//
//  FHHouseNewBillboardItemViewModel.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewComponentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHImageModel;
@class FHCourtBillboardPreviewItemModel;
@interface FHHouseNewBillboardItemViewModel : FHHouseNewComponentViewModel

@property (nonatomic, assign) BOOL isLastItem;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;
@property (nonatomic, copy, readonly) NSString *detail;
@property (nonatomic, strong, readonly) FHImageModel *img;

- (instancetype)initWithModel:(FHCourtBillboardPreviewItemModel *)model;

- (void)onClickView;

@end

NS_ASSUME_NONNULL_END
