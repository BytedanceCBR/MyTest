//
//  ExploreItemActionManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-16.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOrderedData+TTBusiness.h"
#import "DetailActionRequestManager.h"
#import "TTGroupModel.h"

typedef void(^ExploreItemActionFinishBlock) (id userInfo ,NSError * error);

typedef NS_ENUM(NSInteger, TTDislikeSourceType) {
    TTDislikeSourceTypeFeed,
    TTDislikeSourceTypeDetail,
    TTDislikeSourceTypeDetailReport
};

#define kHasTipFavLoginUserDefaultKey @"kHasTipFavLoginUserDefaultKey"
static inline void setHasTipFavLoginUserDefaultKey (bool hasTip) {
    [[NSUserDefaults standardUserDefaults] setBool:hasTip forKey:kHasTipFavLoginUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL hasTipFavLoginUserDefaultKey () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasTipFavLoginUserDefaultKey];
}


@interface ExploreItemActionManager : NSObject

/**
 *  从数据库中取消收藏并删除ordered data， 不做其他任何工作
 *
 *  @param orderedData
 */
+ (void)removeOrderedData:(ExploreOrderedData *)orderedData;

/**
 *  仅发送item_action,不做其他处理
 *
 *  @param originalData 不能为空
 *  @param adID         广告ID,没有传nil
 *  @param type         Action类型
 *  @param userInfo     额外信息，目前只有新版dislike传递filter_words
 *  @param finishBlock  完成的Block
 */
- (void)sendActionForOriginalData:(ExploreOriginalData *)originalData adID:(NSNumber *)adID actionType:(DetailActionRequestType)type finishBlock:(ExploreItemActionFinishBlock)finishBlock;
/**
 *  取消收藏,内部会处理Model状态并发送item action
 *
 *  @param originalData 不能为空
 *  @param adID         广告ID，没有传nil
 *  @param finishBlock  完成的Block
 */
- (void)unfavoriteForOriginalData:(ExploreOriginalData *)originalData adID:(NSNumber *)adID finishBlock:(ExploreItemActionFinishBlock)finishBlock;
/**
 *  取消收藏,内部会处理Model状态并发送item action
 *
 *  @param orderedDataGroup 被批量删除的数组
 *  @param finishBlock  完成的Block
 */
- (void)unfavoriteForOrderedDataGroup:(NSArray<ExploreOrderedData *> *)orderedDataGroup finishBlock:(ExploreItemActionFinishBlock)finishBlock;
/**
 *  收藏，内部处理Model状态， tip提示，并发送item Action
 *
 *  @param originalData 不能为空
 *  @param adID         广告ID, 没有传nil
 *  @param finishBlock  完成的Block
 */
- (void)favoriteForOriginalData:(ExploreOriginalData *)originalData adID:(NSNumber *)adID finishBlock:(ExploreItemActionFinishBlock)finishBlock;

- (void)startSendDislikeActionType:(DetailActionRequestType)type
                        groupModel:(TTGroupModel *)groupModel
                       filterWords:(NSArray*)filterWords
                            cardID:(NSString*)cardID
                       actionExtra:(NSString*)actionExtra
                              adID:(NSNumber *)adID
                           adExtra:(NSDictionary *)adExtra
                          widgetID:(NSString *)widgetID
                          threadID:(NSString *)threadID
                       finishBlock:(ExploreItemActionFinishBlock)finishBlock;

/**
 *  发送dislike请求，参数中含有source
 *
 *  @param type
 *  @param source
 *  @param groupModel
 *  @param filterWords
 *  @param cardID
 *  @param actionExtra
 *  @param adID
 *  @param adExtra
 *  @param widgetID
 *  @param threadID
 *  @param finishBlock
 */
- (void)startSendDislikeActionType:(DetailActionRequestType)type
                            source:(TTDislikeSourceType)source
                        groupModel:(TTGroupModel *)groupModel
                       filterWords:(NSArray*)filterWords
                            cardID:(NSString*)cardID
                       actionExtra:(NSString*)actionExtra
                              adID:(NSNumber *)adID
                           adExtra:(NSDictionary *)adExtra
                          widgetID:(NSString *)widgetID
                          threadID:(NSString *)threadID
                       finishBlock:(ExploreItemActionFinishBlock)finishBlock;

- (void)favoriteForGroupModel:(TTGroupModel *)groupModel adID:(NSNumber *)adID isFavorite:(BOOL)isFavorite finishBlock:(ExploreItemActionFinishBlock)finishBlock;

@end


