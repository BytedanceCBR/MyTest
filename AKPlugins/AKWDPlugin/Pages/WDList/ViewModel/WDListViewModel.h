//
//  WDListViewModel.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import <Foundation/Foundation.h>
#import "WDDefines.h"
#import "WDSettingHelper.h"
#import "WDApiModel.h"

/*
 * 1.3 列表页底部几种view类型：没有更多/正在加载（cell），查看折叠（footer），暂无回答（empty）
 */

@class WDQuestionEntity;
@class WDAnswerEntity;
@class TTActivity;
@class TTImageInfosModel;
@class WDListCellViewModel;
@class WDListCellDataModel;

typedef NS_ENUM(NSUInteger, WDQuestionRelatedStatus) {
    WDQuestionRelatedStatusNormal,
    WDQuestionRelatedStatusPrimary,
    WDQuestionRelatedStatusSecondary,
};

extern NSString * const kWDListNeedReturnKey;
extern NSString * const kWDWendaListViewControllerUMEventName;

typedef void(^WDActionButtonClicked)(void);
typedef void(^WDWendaListManagerFinishBlock)(NSError * error);

@interface WDListViewModel : NSObject

@property (nonatomic, readonly,   copy) NSString *qID;
@property (nonatomic, readonly,   copy) NSDictionary *apiParameter;
@property (nonatomic, readonly,   copy) NSDictionary *gdExtJson;
@property (nonatomic, readonly, assign) BOOL listPageneedReturn;

@property (nonatomic, readonly,   copy) NSArray<WDModuleStructModel>*tabModelArray;
@property (nonatomic, strong, readonly) WDQuestionEntity *questionEntity;
@property (nonatomic, strong, readonly) NSMutableArray<WDListCellDataModel *> *dataModelsArray;
@property (nonatomic, strong, readonly) NSMutableArray<WDInviteUserStructModel *> *inviteUserModels;

//问题重定向相关
@property (nonatomic, readonly, assign) WDQuestionRelatedStatus questionRelatedStatus;
@property (nonatomic, readonly, assign) BOOL canAnswer;
@property (nonatomic, readonly,   copy) NSString *relatedQuestionTitle;
@property (nonatomic, readonly,   copy) NSString *relatedQuestionSchema;
@property (nonatomic, readonly,   copy) NSString *relatedReasonUrl;

// 转发相关
@property (nonatomic, readonly, strong) WDForwardStructModel *repostParams;

@property (nonatomic, readonly, assign) BOOL canGetRedPacket; // 控制右下角按钮文案
@property (nonatomic, readonly, assign) BOOL showRewardView;  // 控制顶部view
@property (nonatomic, readonly, strong) WDProfitStructModel *profitModel; // 稍后看看是否有必要改成本地model

@property (nonatomic, readonly, assign) BOOL showShareRewardView;
@property (nonatomic, readonly, strong) WDShareProfitStructModel *shareProfitModel; // 分享有礼数据


@property (nonatomic, copy) WDActionButtonClicked editBlock;
@property (nonatomic, copy) WDActionButtonClicked deleteBlock;
@property (nonatomic, copy) WDActionButtonClicked closeBlock;

- (instancetype)initWithQid:(NSString *)qid
                  gdExtJson:(NSDictionary *)gdExtJson
               apiParameter:(NSDictionary *)apiParameter
                 needReturn:(BOOL)needReturn;

- (BOOL)hasAnswers;
- (BOOL)hasNiceAnswers;
- (BOOL)hasMore;
- (BOOL)hasTags;
- (BOOL)showInviteScrollView;
- (BOOL)canEditTags;
- (BOOL)isLoading;
- (BOOL)isFinish;  // 请求是否正在进行
- (BOOL)isFailure; // 最近的一次是否失败
- (BOOL)latelyHasException;
- (void)refresh;
- (void)reportQuestion;

- (void)requestFinishBlock:(WDWendaListManagerFinishBlock)finishBlock;
- (void)loadMoreFinishBlock:(WDWendaListManagerFinishBlock)finishBlock;
- (void)deleteQuestionWithFinishBlock:(void(^)(NSString *tips, NSError *error))finishBlock;
- (void)followQuestionWithFinishBlock:(void(^)(NSString *tips, NSError *error))finishBlock;

- (void)closePage;

- (NSArray *)answerIDArray;
- (NSDictionary *)detailExtraInfoWith:(WDAnswerEntity *)answerEntity;
- (NSString *)moreListAnswersTitle;
- (NSInteger)defaultNumberOfLines;

@end

@interface WDListViewModel(NetworkCategory)

// 合二为一
+ (void)requestForQuestionID:(NSString *)qid
                    apiParam:(NSDictionary *)apiParam
                   gdExtJson:(NSDictionary *)gdExtJson
                      offset:(NSInteger)offset
                 finishBlock:(void(^)(WDWendaV2QuestionBrowResponseModel *responseModel, NSError *error))finishBlock;

@end

@interface WDListViewModel(WDTracker)

+ (void)trackEvent:(NSString *)event label:(NSString *)label gdExtJson:(NSDictionary *)gdExtJson;

@end
