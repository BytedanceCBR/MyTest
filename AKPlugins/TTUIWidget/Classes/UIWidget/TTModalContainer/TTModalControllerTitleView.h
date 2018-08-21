//
//  TTMomentTitleView.h
//  Article
//
//  Created by zhaoqin on 10/01/2017.
//
//

#import "SSViewBase.h"

typedef enum : NSUInteger {
    TTModalControllerTitleTypeBoth,
    TTModalControllerTitleTypeOnlyBack,
    TTModalControllerTitleTypeOnlyClose
} TTModalControllerTitleType;

@interface TTModalControllerTitleView : SSViewBase
//标题类型：返回按钮 or 关闭按钮
@property (nonatomic, assign) TTModalControllerTitleType type;
@property (nonatomic, copy) void (^closeComplete)(UIButton *sender);
@property (nonatomic, copy) void (^backComplete)(void);
@property (nonatomic, assign) BOOL hiddenBottomLine;

- (void)setTitle:(NSString *)title;

@end
