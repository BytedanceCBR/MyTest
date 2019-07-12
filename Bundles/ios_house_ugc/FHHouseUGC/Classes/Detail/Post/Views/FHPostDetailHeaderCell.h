//
//  FHPostDetailHeaderCell.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/13.
//

#import <UIKit/UIKit.h>
#import "FHUGCBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHUGCScialGroupModel.h"

NS_ASSUME_NONNULL_BEGIN

// 帖子头部
@interface FHPostDetailHeaderCell : FHUGCBaseCell

@end

// 模型
@interface FHPostDetailHeaderModel : FHDetailBaseModel

@property (nonatomic, strong)   FHUGCScialGroupDataModel       *socialGroupModel;
@property (nonatomic, copy)     NSDictionary       *tracerDict;

@end

NS_ASSUME_NONNULL_END
