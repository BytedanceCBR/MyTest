//
//  FHHouseFindHelpBottomView.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindHelpBottomView : UIView

@property(nonatomic, copy)void(^resetBlock)(void);
@property(nonatomic, copy)void(^confirmBlock)(void);

@end

NS_ASSUME_NONNULL_END
