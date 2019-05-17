//
//  TTCellBridge.h
//  Article
//
//  Created by Chen Hong on 16/2/18.
//
//

#import <Foundation/Foundation.h>

/**
 *  保存cell和cellView类信息
 */
@interface TTCellClassInfo : NSObject

// cell类
@property(nonatomic, strong) Class cellCls;

// cellView类
@property(nonatomic, strong) Class cellViewCls;

@end

/**
 *  各模块自己负责data到cell类的映射逻辑
 */
@protocol TTCellDataHelper <NSObject>

/**
 *  返回data对应的cell类，以ExploreOrderedData为例，多个cellDataHelper都会注册
 *  ExploreOrderedData类，所以需要判断具体的originalData才能确定cellDataHelper
 *  能不能处理该data实例，比如originalData是article，话题的cellHelper返回nil，交由其他
 *  cellHelper处理，originalData是topic时，话题的cellHelper返回对应的cellClass
 *
 *  @param data cell数据
 *
 *  @return cell类或nil
 */
+ (Class)cellClassFromData:(id)data;

@end

/**
 *  cell注册辅助类
 */
@interface TTCellBridge : NSObject

+ (instancetype)sharedInstance;

// 遍历所有注册的cell类
- (void)enumerateCellInfoUsingBlock:(void (^)(NSString *cellId, TTCellClassInfo *classInfo))block;

- (void)registerCellClass:(Class)cellClass
            cellViewClass:(Class)cellViewClass;

- (void)registerCellDataClass:(Class)cellDataClass
          cellDataHelperClass:(Class)cellDataHelperClass;

// cellData -> [TTCellDataHelper]
- (NSArray<Class<TTCellDataHelper>> *)cellHelperClassArrayForData:(id)data;

- (Class)cellViewClassFromCellClass:(Class)cellClass;

@end
