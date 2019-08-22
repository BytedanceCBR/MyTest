//
//  FHMapSearchInfoTopBar.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/9.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchInfoTopBar : UIView

@property(nonatomic , copy) void (^backBlock)();
@property(nonatomic , copy) void (^filterBlock)();
@property(nonatomic , strong) NSString *title;

@end

NS_ASSUME_NONNULL_END
