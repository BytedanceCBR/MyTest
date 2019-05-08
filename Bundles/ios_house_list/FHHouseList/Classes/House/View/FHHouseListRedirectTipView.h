//
//  FHHouseListRedirectTipView.h
//  Pods
//
//  Created by 张静 on 2019/1/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListRedirectTipView : UIView

@property(nonatomic, copy)NSString *text;
@property(nonatomic, copy)NSString *text1;
@property(nonatomic, copy)void (^clickCloseBlock)(void);
@property(nonatomic, copy)void (^clickRightBlock)(void);

@end

NS_ASSUME_NONNULL_END
