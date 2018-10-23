//
//  WDListCellViewModel.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/14.
//
//

#import <Foundation/Foundation.h>
#import "WDSettingHelper.h"
#import "WDApiModel.h"

/*
 * 8.14 对应列表页cell的viewModel类
 */

@class WDAnswerEntity;
@class TTImageInfosModel;
@class WDListCellDataModel;

@interface WDListCellViewModel : NSObject

@property (nonatomic, strong) WDAnswerEntity *ansEntity;

@property (nonatomic, strong) WDListCellDataModel *dataModel;

@property (nonatomic, assign, readonly) BOOL isInvalidData;  // 是否为无效数据

@property (nonatomic, assign, readonly) BOOL isFollowButtonHidden;

@property (nonatomic, assign, readonly) BOOL isAnswerGetReward;

@property (nonatomic, assign, readonly) BOOL hasValidVideo;

@property (nonatomic, strong, readonly) WDVideoInfoStructModel *videoModel;

- (instancetype)initWithDataModel:(WDListCellDataModel *)dataModel;

// 用户名下面第二行文字内容
- (NSString *)secondLineContent;

// 过滤空格，回车后的回答内容
- (NSString *)answerContentAbstract;

- (NSString *)bottomLabelContent;

- (NSNumber *)diggCount;

- (NSNumber *)commentCount;

- (NSNumber *)forwardCount;

- (NSString *)diggButtonContent;

- (NSString *)commentButtonContent;

- (NSString *)forwardButtonContent;

- (NSString *)totalImageCountsContent;

- (void)enterAnswerDetailPageFromComment;

- (void)forwardCurrentAnswerToUGC;

- (void)cellDidSelectedWithGdExtJson:(NSDictionary *)gdExtJson;

@end
