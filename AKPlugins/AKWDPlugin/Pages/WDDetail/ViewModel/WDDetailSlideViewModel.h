//
//  WDDetailSlideViewModel.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/5.
//
//

#import <Foundation/Foundation.h>
#import "WDDetailContainerViewModel.h"

/*
 * 6.5 横向滑动切换回答的回答详情页对应的ViewModel类
 * 8.10 应用新字段控制样式及滑动提示是否显示：1 白色header，不显示滑动提示；2 白色header，显示滑动提示；3 蓝色header，显示滑动提示
 */

@class WDDetailModel;

@interface WDDetailSlideViewModel : NSObject

// 最初答案的model类
@property (nonatomic, strong, readonly) WDDetailModel *initialDetailModel;
// 当前展示的model类，外界赋值，用于判断是否最后一个
@property (nonatomic, strong) WDDetailModel *currentDetailModel;

@property (nonatomic, strong) NSMutableArray *ansItemsArray;

@property (nonatomic, assign, readonly) BOOL hasCountChange;

@property (nonatomic, assign, readonly) BOOL hasGetAllAnswers;

@property (nonatomic, assign, readonly) NSInteger showSlideType;

// 初始化
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj;
// 发请求（只获取进入时的第一个回答的内容）
- (void)fetchContentFromRemoteIfNeededWithComplete:(WDFetchRemoteContentBlock)block;
// 获取列表数据
- (void)startFetchAnswerListWithResult:(void(^)(NSError *error))resultBlock;
// 获取接下来的回答的paramObj
- (TTRouteParamObj *)getRouteParamObjWithIndex:(NSInteger)index;
// 是否显示折叠回答toast
- (BOOL)isFirstFoldAnswerWithIndex:(NSInteger)index;
// 是否是最后一个回答
- (BOOL)isLastAnswerFromDetailModel:(WDDetailModel *)detailModel;
// 是否是最后一个回答
- (BOOL)isLastAnswer;
// 是否是唯一一个回答
- (BOOL)isOnlyAnswer;
// 是否该显示滑动提示
- (BOOL)isNeedShowSlideHint;
// 已经显示过滑动提示
- (void)afterShowSlideHint;

@end

@interface WDDetailSlideViewModel (NetWorkCategory)

+ (void)startFetchAnswerListWithAnswerID:(NSString *)ansID
                               enterFrom:(NSString *)enterFrom
                               gdExtJson:(NSString *)gdExtJson
                            apiParameter:(NSString *)apiParameter
                             finishBlock:(void(^)(WDWendaAnswerListResponseModel *responseModel, NSError *error))finishBlock;

@end
