//
//  FHFirstStartManager.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 技术方案：https://bytedance.feishu.cn/docs/doccnvtR6b7d43sMLt0yboSo4Cg
// 用户感知启动页面：https://bytedance.feishu.cn/docs/doccnUYepK21zGIZ45VffoJi9qf
// 需求链接：https://bytedance.feishu.cn/docs/doccnq1ED8UbSYryV9kA3FJxhTe
@interface FHFirstPageManager : NSObject

+ (instancetype)sharedInstance;

//该需求特殊场景用，不可全局用
- (BOOL)isColdStart;

//改需求特殊场景用，不可全局用
- (void)setColdStart;


//将当前页面page_type或host加入待埋点队列
- (void)addFirstPageModelWithPageType:(NSString *)pageType withUrl:(NSString *)url withTabName:(NSString *)tabName withPriority:(NSInteger)priorityIndex;

//上报埋点
- (void)sendTrace;

@end

@interface FHFirstPageModel : NSObject

@property (nonatomic, copy) NSString *pageType;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *tabName;

@property (nonatomic, assign) NSInteger priorityIndex;

@end

NS_ASSUME_NONNULL_END
