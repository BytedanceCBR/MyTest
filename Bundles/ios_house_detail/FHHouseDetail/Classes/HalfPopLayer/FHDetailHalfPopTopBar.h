//
//  FHDetailHalfPopTopBar.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailHalfPopTopBar : UIView

@property(nonatomic , copy) void (^headerActionBlock)(BOOL isClose);

@end

NS_ASSUME_NONNULL_END
