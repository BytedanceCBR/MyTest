//
//  WDMoreListViewModel
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import <Foundation/Foundation.h>
#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDSettingHelper.h"

/*
 * 1.3 折叠列表页底部几种view类型：没有更多/正在加载（cell）
 */

@class WDMoreListCellViewModel;
@class WDListCellDataModel;

extern NSString * const kWDWendaListMorePageSource;
extern NSString * const kWDWendaMoreListViewControllerUMEventName;

typedef void(^WDWendaMoreListManagerFinishBlock)(NSError * error);

@interface WDMoreListViewModel : NSObject

@property (nonatomic, readonly, copy) NSString *qID;
@property (nonatomic, readonly, copy) NSDictionary *apiParameter;
@property (nonatomic, readonly, copy) NSDictionary *gdExtJson;

@property (nonatomic, strong, readonly) NSMutableArray<WDListCellDataModel *> *dataModelsArray;

- (instancetype)initWithQid:(NSString *)qid
                  gdExtJson:(NSDictionary *)gdExtJson
               apiParameter:(NSDictionary *)apiParameter;

- (BOOL)hasMore;
- (BOOL)isLoading;
- (BOOL)isFinish;  // 请求是否正在进行
- (BOOL)isFailure; // 最近的一次是否失败
- (BOOL)latelyHasException;

- (void)refresh;

- (void)requestFinishBlock:(WDWendaMoreListManagerFinishBlock)finishBlock;
- (void)loadMoreFinishBlock:(WDWendaMoreListManagerFinishBlock)finishBlock;

- (WDQuestionEntity *)questionEntity;
- (NSDictionary *)detailExtraInfoWith:(WDAnswerEntity *)answerEntity;

@end

@interface WDMoreListViewModel(NetworkCategory)

// 合二为一
+ (void)requestForQuestionID:(NSString *)qid
                    apiParam:(NSDictionary *)apiParam
                   gdExtJson:(NSDictionary *)gdExtJson
                      offset:(NSInteger)offset
                 finishBlock:(void(^)(WDWendaV2QuestionBrowResponseModel *responseModel, NSError *error))finishBlock;

@end

@interface WDMoreListViewModel(WDTracker)

+ (void)trackEvent:(NSString *)event label:(NSString *)label gdExtJson:(NSDictionary *)gdExtJson;

@end
