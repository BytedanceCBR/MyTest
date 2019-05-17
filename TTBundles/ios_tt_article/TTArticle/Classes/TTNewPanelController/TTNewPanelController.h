//
//  TTNewPanelController.h
//  Article
//
//  Created by chenjiesheng on 2017/2/10.
//
//

// TODO: ugly code

#import <Foundation/Foundation.h>
#import "SSThemed.h"
#import "TTPanelControllerItem.h"

#define kFRPanelSingleCellHeight    116
#define kFRPanelTopPadding          10
#define kFRPanelCancelButtonHeight  48
#define kFRPanelCellWidth           72

#define kRootViewWillTransitionToSize       @"kRootViewWillTransitionToSize"

typedef void (^CancelBlock)(void);

@interface TTNewPanelThemedButton : SSThemedButton

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int amount;   //小于4时，均匀分布在
@property (nonatomic, strong) SSThemedImageView *iconImage;
@property (nonatomic, strong) SSThemedImageView *selectedIconImage;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, assign) CGRect originFrame;// 未留白时原始frame
@property (nonatomic, assign) BOOL needLeaveWhite;//ipad 需要留白

- (instancetype)initWithFrame:(CGRect)frame item:(TTPanelControllerItem *)item row:(int)row index:(int)index amount:(int)amount needLeaveWhite:(BOOL)needLeaveWhite;

- (void)setSelected:(BOOL)selected;

//- (void)doZoomInAnimation;

@end


@interface TTNewPanelControllerWindow : UIWindow
@end

@interface TTNewPanelController : NSObject
@property (strong, nonatomic, readonly) TTNewPanelControllerWindow *backWindow;
/**
 *  构造一个PanelController
 *
 *  @param items       TTNewPanelControllerItem的数组的数组 @[@[item1, item2], @[item3, item4]]
 *  @param cancelTitle 取消button的title
 *
 *  @return TTNewPanelController
 */
- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle;

- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle cancelBlock:(CancelBlock)cancelBlock;

- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle isFullScreen:(BOOL)isFullScreen cancelBlock:(CancelBlock)cancelBlock;
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
