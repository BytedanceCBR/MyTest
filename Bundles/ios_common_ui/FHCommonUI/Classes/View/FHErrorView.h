//
//  FHErrorView.h
//  Article
//
//  Created by 张元科 on 2018/12/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 空页面图片名称定义
#define kFHErrorMaskNoDataImageName         @"group-8"          // 无数据
#define kFHErrorMaskNoNetWorkImageName      @"group-4"          // 无网络
#define kFHErrorMaskNetWorkErrorImageName   @"group-9"          // 网络异常
#define kFHErrorMaskNoMessageImageName      @"empty_message"    // 无消息
#define kFHErrorMaskNoListDataImageName     @"group_invalid"    // 列表空数据

typedef enum : NSUInteger {
    FHEmptyMaskViewTypeNoNetWorkAndRefresh,         // 网络异常，请检查网络连接；刷新按钮        "group-4"
    FHEmptyMaskViewTypeNoNetWorkNotRefresh,         // 网络异常，请检查网络连接；无刷新按钮       "group-4"
    FHEmptyMaskViewTypeNoData,                      // 数据走丢了                            "group-8"
    FHEmptyMaskViewTypeNetWorkError,                // 网络异常                              "group-9"
    FHEmptyMaskViewTypeEmptyMessage,                // 暂无消息                              "empty_message"
    FHEmptyMaskViewTypeNoDataForCondition,          // 暂无搜索结果                           "group-9"
} FHEmptyMaskViewType;

@interface FHErrorView : UIView

@property(nonatomic, copy) void (^retryBlock)();
@property(nonatomic , strong) UIButton *retryButton;

- (void)showEmptyWithType:(FHEmptyMaskViewType)maskViewType;

- (void)showEmptyWithTip:(NSString *)tips errorImageName:(NSString *)imageName showRetry:(BOOL)showen;
- (void)showEmptyWithTip:(NSString *)tips errorImage:(UIImage *)image showRetry:(BOOL)showen;

- (void)hideEmptyView;

@end

NS_ASSUME_NONNULL_END
