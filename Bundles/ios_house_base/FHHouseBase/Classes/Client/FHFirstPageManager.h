//
//  FHFirstStartManager.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//技术方案：https://bytedance.feishu.cn/docs/doccnvtR6b7d43sMLt0yboSo4Cg

@interface FHFirstPageManager : NSObject

+ (instancetype)sharedInstance;

- (void)addFirstPageModelWithPageType:(NSString *)pageType withUrl:(NSString *)url withTabName:(NSString *)tabName withPriority:(NSInteger)priorityIndex;

- (void)sendTrace;

@end

@interface FHFirstPageModel : NSObject

@property (nonatomic, copy) NSString *pageType;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *tabName;

@property (nonatomic, assign) NSInteger priorityIndex;

@end

NS_ASSUME_NONNULL_END
