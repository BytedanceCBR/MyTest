//
//  FHDetailHalfPopFooter.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , FHDetailHalfPopFooterType) {
    FHDetailHalfPopFooterTypeConfirm = 0 ,
//    FHDetailHalfPopFooterTypeConfirmed ,
    FHDetailHalfPopFooterTypeChoose ,
};

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailHalfPopFooter : UIView

@property(nonatomic , copy) void (^actionBlock)(BOOL positive);

@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIButton *actionButton;
@property(nonatomic , strong) UIButton *negativeButton;

-(void)showTip:(NSString *)tip type:(FHDetailHalfPopFooterType)type positiveTitle:(NSString *)ptitle negativeTitle:(NSString *_Nullable)ntitle;


@end

NS_ASSUME_NONNULL_END
