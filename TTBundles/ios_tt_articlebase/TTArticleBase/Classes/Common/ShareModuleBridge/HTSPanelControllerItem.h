//
//  HTSPanelControllerItem.h
//  Article
//
//  Created by 王霖 on 16/6/24.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^HTSPanelButtonClick)(void);

typedef NS_ENUM(NSUInteger, HTSPanelControllerItemType) {
    /**
     *  Bundle Icon name 使用TTThemed加载
     */
    HTSPanelControllerItemTypeIcon,
    /**
     *  Bundle Icon name 拥有selected状态的Icon
     *  拥有selected 状态的icon在点击后，会自动变为selected状态，并且触发block
     *  但是不会自动取消状态，需要调用者手动关闭pannel
     *  @see HTSPanelController
     */
    HTSPanelControllerItemTypeSelectedIcon,
    /**
     *  Avatar Url 使用网络加载
     */
    HTSPanelControllerItemTypeAvatar,
    /**
     *  Bundle Icon name 拥有selected状态的Icon,顶踩用
     *  拥有selected 状态的icon在点击后，会自动变为selected状态，下面的namelabel的计数加1，并且触发block
     *  点击不能取消状态，且点完赞后不能取消也不能再点踩
     *  @see HTSPanelController
     */
    HTSPanelControllerItemTypeSelectedDigIcon
};

@interface HTSPanelControllerItem : NSObject

/**
 *  创建一个item
 *
 *  @param icon  Icon Name 使用TTThemed加载 highlighted Icon 以_press结尾
 *  @param title 对应的名称
 *
 *  @return HTSPanelControllerItem
 */
- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title;
/**
 *  创建一个拥有selected状态的item
 *
 *  @param icon  Icon Name 使用TTThemed加载 highlighted Icon 以_press结尾 selected Icon 以_selected结尾 hilighted selected Icon 以_selected_press结尾
 *  @param title 对应的名称
 *
 *  @return HTSPanelControllerItem
 */
- (instancetype)initSelectedTypeIcon:(NSString *)icon title:(NSString *)title;
/**
 *  创建一个item
 *
 *  @param icon  Icon Name 使用TTThemed加载
 *  @param title 对应的名称
 *  @param block 对应的操作
 *
 *  @return HTSPanelControllerItem
 */
- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title block:(HTSPanelButtonClick)block;

/**
 *  创建一个item
 *
 *  @param url   url string
 *  @param title 对应的名称
 *
 *  @return HTSPanelControllerItem
 */
- (instancetype)initWithAvatar:(NSString *)url title:(NSString *)title;
/**
 *  创建一个item
 *
 *  @param url   url string
 *  @param title 对应的名称
 *  @param block 对应的操作
 *
 *  @return HTSPanelControllerItem
 */
- (instancetype)initWithAvatar:(NSString *)url title:(NSString *)title block:(HTSPanelButtonClick)block;

@property (assign, nonatomic) HTSPanelControllerItemType itemType;
@property (strong, nonatomic) NSString *iconKey;
@property (strong, nonatomic) NSString *title;
@property (copy, nonatomic) HTSPanelButtonClick clickAction;
// Extended by luohuaqing
@property (strong, nonatomic) UIImage * iconImage;
@property (assign, nonatomic) BOOL selected;
// Extended by wangshuanghua
@property (nonatomic, retain) NSString *count;     //顶踩的计数
@property (nonatomic, assign) BOOL banDig;      //禁止顶踩
@end
