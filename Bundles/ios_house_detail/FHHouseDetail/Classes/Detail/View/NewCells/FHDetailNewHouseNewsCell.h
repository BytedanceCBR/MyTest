//
//  FHDetailNewHouseNewsCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNewHouseNewsCell : FHDetailBaseCell

@end

@interface FHDetailNewHouseNewsCellModel : FHDetailBaseModel

@property (nonatomic, strong) FHDetailNewDataTimelineModel *timeLineModel;

@end

@interface FHDetailNewHouseNewsCellItemView : UIView
- (void)newsViewShowWithData:(id)data;
@end

NS_ASSUME_NONNULL_END
