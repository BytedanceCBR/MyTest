//
//  FHHouseNewTopContainer.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewComponentView.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseNewTopContainerViewModel;
@interface FHHouseNewTopContainer : FHHouseNewComponentView

@property (nonatomic, copy) void (^onStateChanged)(void);

@end

NS_ASSUME_NONNULL_END
