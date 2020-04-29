//
//  FHDetailTimelineItemCorrectingCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/4/29.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailTimelineItemCorrectingCell : FHDetailBaseCell

@end

@interface FHDetailNewTimeLineItemCorrectingModel : FHDetailBaseModel

@property (nonatomic, copy , nullable) NSString *createdTime;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, assign) BOOL isFirstCell;
@property (nonatomic, assign) BOOL isLastCell;
@property (nonatomic, assign) BOOL isExpand;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, copy) NSString * courtId;


@end

NS_ASSUME_NONNULL_END
