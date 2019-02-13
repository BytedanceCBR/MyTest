//
//  FHDetailBottomBarView.h
//  Pods
//
//  Created by 张静 on 2019/2/12.
//

#import <UIKit/UIKit.h>
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHDetailBottomBarView : UIView

@property(nonatomic, copy)void(^bottomBarContactBlock)(void);
@property(nonatomic, copy)void(^bottomBarRealtorBlock)(void);
@property(nonatomic, copy)void(^bottomBarLicenseBlock)(void);

- (void)refreshBottomBar:(FHDetailOldDataContactModel *)contactPhone contactTitle:(NSString *)contactTitle;

@end

NS_ASSUME_NONNULL_END
