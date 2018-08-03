//
//  FRPanelControllerItem.h
//  Article
//
//  Created by zhaopengwei on 15/7/26.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^TTPanelButtonClick)(void);

typedef NS_ENUM(NSUInteger, TTPanelControllerItemType) {
    /**
     *  Bundle Icon name 使用TTThemed加载
     */
    TTPanelControllerItemTypeIcon,
    /**
     *  Bundle Icon name 拥有selected状态的Icon
     *  拥有selected 状态的icon在点击后，会自动变为selected状态，并且触发block
     *  但是不会自动取消状态，需要调用者手动关闭pannel
     *  @see TTPanelController
     */
    TTPanelControllerItemTypeSelectedIcon,
    /**
     *  Avatar Url 使用网络加载
     */
    TTPanelControllerItemTypeAvatar,
    /**
     *  Avatar Url 使用网络加载，没有边框
     */
    TTPanelControllerItemTypeAvatarNoBorder,
    /**
     *  Bundle Icon name 拥有selected状态的Icon,顶踩用
     *  拥有selected 状态的icon在点击后，会自动变为selected状态，下面的namelabel的计数加1，并且触发block
     *  点击不能取消状态，且点完赞后不能取消也不能再点踩
     *  @see TTPanelController
     */
    TTPanelControllerItemTypeSelectedDigIcon
};

@interface TTPanelControllerItem : NSObject

/**
 *  创建一个item
 *
 *  @param icon  Icon Name 使用TTThemed加载 highlighted Icon 以_press结尾
 *  @param title 对应的名称
 *
 *  @return TTPanelControllerItem
 */
- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title;
/**
 *  创建一个拥有selected状态的item
 *
 *  @param icon  Icon Name 使用TTThemed加载 highlighted Icon 以_press结尾 selected Icon 以_selected结尾 hilighted selected Icon 以_selected_press结尾
 *  @param title 对应的名称
 *
 *  @return TTPanelControllerItem
 */
- (instancetype)initSelectedTypeIcon:(NSString *)icon title:(NSString *)title;
/**
 *  创建一个item
 *
 *  @param icon  Icon Name 使用TTThemed加载
 *  @param title 对应的名称
 *  @param block 对应的操作
 *
 *  @return TTPanelControllerItem
 */
- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title block:(TTPanelButtonClick)block;

/**
 *  创建一个item
 *
 *  @param url   url string
 *  @param title 对应的名称
 *
 *  @return TTPanelControllerItem
 */
- (instancetype)initWithAvatar:(NSString *)url title:(NSString *)title showBorder:(BOOL)showBorder;
/**
 *  创建一个item
 *
 *  @param url   url string
 *  @param title 对应的名称
 *  @param block 对应的操作
 *
 *  @return TTPanelControllerItem
 */
- (instancetype)initWithAvatar:(NSString *)url title:(NSString *)title showBorder:(BOOL)showBorder block:(TTPanelButtonClick)block;

@property (assign, nonatomic) TTPanelControllerItemType itemType;
@property (strong, nonatomic) NSString *iconKey;
@property (strong, nonatomic) NSString *title;
@property (copy, nonatomic) TTPanelButtonClick clickAction;
// Extended by luohuaqing
@property (strong, nonatomic) UIImage * iconImage;
@property (assign, nonatomic) BOOL selected;
// Extended by wangshuanghua 
@property (nonatomic, retain) NSString *count;     //顶踩的计数
@property (nonatomic, assign) BOOL banDig;      //禁止顶踩
@end
