//
//  FHDetailNewTimeLineItemCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNewTimeLineItemCell : FHDetailBaseCell

@end

@interface FHDetailNewTimeLineItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *createdTime;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, assign) BOOL isFirstCell;
@property (nonatomic, assign) BOOL isLastCell;
@property (nonatomic, assign) CGFloat offsetY;

@end

NS_ASSUME_NONNULL_END
