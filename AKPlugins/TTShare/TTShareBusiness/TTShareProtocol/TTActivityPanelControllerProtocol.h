//
//  TTActivityPanelControllerProtocol.h
//  Pods
//
//  Created by 延晋 张 on 16/7/10.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"

@class TTShareManager;
@protocol TTActivityPanelControllerProtocol;

@protocol TTActivityPanelDelegate <NSObject>

- (void)activityPanel:(id<TTActivityPanelControllerProtocol>)panel
          clickedWith:(id<TTActivityProtocol>)acitivity;

- (void)activityPanel:(id<TTActivityPanelControllerProtocol>)panel
        completedWith:(id<TTActivityProtocol>)activity
                error:(NSError *)error
                 desc:(NSString *)desc;
@end

@protocol TTActivityPanelControllerProtocol <NSObject>

@property (nonatomic, weak) id<TTActivityPanelDelegate> delegate;
/**
 *  构造一个PanelController
 *
 *  @param items       TTPanelControllerItem的数组的数组 @[@[item1, item2], @[item3, item4]]
 *  @param cancelTitle 取消button的title
 *
 *  @return TTPanelController
 */
- (instancetype)initWithItems:(NSArray <NSArray *> *)items cancelTitle:(NSString *)cancelTitle;
/**
 *  展示panel
 */
- (void)show;
/**
 *  收起pannel
 */
- (void)hide;

@end
