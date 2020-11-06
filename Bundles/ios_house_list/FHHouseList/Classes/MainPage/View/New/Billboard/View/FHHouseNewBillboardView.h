//
//  FHHouseNewBillboardView.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewComponentView.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHHouseNewBillboardView : FHHouseNewComponentView
@property (nonatomic, copy) void (^onStateChanged)(void);
@end

NS_ASSUME_NONNULL_END
