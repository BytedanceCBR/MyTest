//
//  HTSPanelController.h
//  Article
//
//  Created by 王霖 on 16/6/24.
//
//

#import <Foundation/Foundation.h>

typedef void (^HTSPanelControllerCancelBlock)(void);

@interface HTSPanelController : NSObject

/**
 *  构造一个PanelController
 *
 *  @param items       HTSPanelControllerItem的数组的数组 @[@[item1, item2], @[item3, item4]]
 *  @param cancelTitle 取消button的title
 *
 *  @return HTSPanelController
 */
- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle;

- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle cancelBlock:(HTSPanelControllerCancelBlock)cancelBlock;
/**
 *  展示panel
 */
- (void)show;
/**
 *  收起pannel
 *
 *  @param block block when animation finish
 */
- (void)hideWithBlock:(void(^)(void))block;
- (void)hideWithBlock:(void(^)(void))block animation:(BOOL)animated;

@end
