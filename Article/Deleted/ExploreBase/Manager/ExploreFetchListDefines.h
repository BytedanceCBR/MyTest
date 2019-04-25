//
//  ExploreFetchListDefines.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-10.
//
//

#ifndef ExploreFetchListDefines_h
#define ExploreFetchListDefines_h


////////////request key////////////
//列表类型
#define kExploreFetchListListTypeKey     @"kExploreFetchListListTypeKey"
#define kExploreFetchListListLocationKey @"kExploreFetchListListLocationKey"
#define kExploreFetchListFromRemoteKey   @"kExploreFetchListFromRemoteKey"
#define kExploreFetchListFromLocalKey    @"kExploreFetchListFromLocalKey"
#define kExploreFetchListGetMoreKey      @"kExploreFetchListGetMoreKey"

#define kExploreFetchListItemsKey        @"kExploreFetchListItemsKey"
#define kExploreFetchListIsDisplayViewKey @"kExploreFetchListIsDisplayViewKey"

#define kExploreFetchListInsertedPersetentDataKey    @"kExploreFetchListInsertedPersetentDataKey"

#define kExploreFetchListIsResponseFromRemoteKey   @"kExploreFetchListIsResponseFromRemoteKey"

#define kExploreFetchListSilentFetchFromRemoteKey   @"kExploreFetchListSilentFetchFromRemoteKey"

#define kExploreFetchListRefreshTypeKey   @"kExploreFetchListRefreshTypeKey"


/**
 *  存放operation
 */
#define kExploreListOpManagerKey          @"kExploreListOpManagerKey"


////////////request condition key////////////

#define kExploreFetchListConditionKey       @"kExploreFetchListConditionKey"
#define kExploreFetchListConditionReloadFromTypeKey       @"kExploreFetchListConditionReloadFromTypeKey"

#define kExploreFetchListConditionIsStrictKey @"strict"

/**
 *  混排列表API类型
 */
#define kExploreFetchListConditionApiType   @"kExploreFetchListConditionApiType"
/**
 *  存放beHotTime
 */
#define kExploreFetchListConditionBeHotTimeKey  @"kExploreFetchListConditionBeHotTimeKey"
/**
 *  列表的唯一ID， 即可能是category id , 未来可以是entry id
 */
#define kExploreFetchListConditionListUnitIDKey @"kExploreFetchListConditionListUnitIDKey"
/**
 *  列表关心ID
 */
#define kExploreFetchListConditionListConcernIDKey @"kExploreFetchListConditionListConcernIDKey"
/**
 *  请求来源:1.频道 2.关心主页
 */
#define kExploreFetchListConditionListReferKey @"kExploreFetchListConditionListReferKey"
/**
 *  列表视频ID，用于影评详情页中的视频Tab
 */
#define kExploreFetchListConditionListMovieCommentVideoIDKey @"kExploreFetchListConditionListMovieCommentVideoIDKey"
#define kExploreFetchListConditionListMovieCommentVideoAPIOffsetKey @"kExploreFetchListConditionListMovieCommentVideoAPIOffsetKey"
// 影评详情页中的全部TabID
#define kExploreFetchListConditionListMovieCommentEntireIDKey @"kExploreFetchListConditionListMovieCommentEntireIDKey"

/**
 *  垂类通用视频API offset参数
 */
#define kExploreFetchListConditionVerticalVideoAPIOffsetKey @"kExploreFetchListConditionVerticalVideoAPIOffsetKey"
/**
 *  列表所在tab，用来区分列表来自 [首页] 还是 [视频tab] value是TTCategoryModelTopType类型
 */
#define kExploreFetchListConditionListFromTabKey @"kExploreFetchListConditionListFromTabKey"
/**
 *  小视频数据请求入口
 */
#define kExploreFetchListConditionListShortVideoListEntranceKey @"kExploreFetchListConditionListShortVideoListEntranceKey"

#define kExploreFetchListConditionSearchKeywordKey @"kExploreFetchListConditionSearchKeywordKey"
#define kExploreFetchListConditionSearchFromTypeKey @"kExploreFetchListConditionSearchFromTypeKey"
/**
 *  load more的次数， 用于 使用offset 请求的api,如搜索
 */
#define kExploreFetchListConditionLoadMoreCountKey   @"kExploreFetchListConditionLoadMoreCountKey"
/**
 * 请求的调用来源，如频道详情页
 */
#define kExploreFetchListConditionFromKey   @"kExploreFetchListConditionFromKey"
/**
 * 请求附加参数（服务端在schema中返回，频道详情页请求api时带回）
 */
#define kExploreFetchListConditionExtraKey @"kExploreFetchListConditionExtraKey"

////////////response key////////////

#define kExploreFetchListResponseHasMoreKey @"kExploreFetchListResponseHasMoreKey"
#define kExploreFetchListResponseFinishedkey     @"kExploreFetchListResponseFinishedkey"

#define kExploreFetchListResponseHasNewKey  @"kExploreFetchListResponseHasNewKey"

/**
 *  新增消重后的item数量
 */
#define kExploreFetchListResponseMergeUniqueIncreaseCountKey     @"kExploreFetchListResponseMergeUniqueIncreaseCountKey"
/**
 *  服务端返回的原始dicts
 */
#define kExploreFetchListResponseRemoteDataKey     @"kExploreFetchListResponseRemoteDataKey"
/**
 *  服务端返回的持久化的dicts（文章，段子，持久化广告）
 */
#define kExploreFetchListResponseRemotePersistantDataKey     @"kExploreFetchListResponseRemotePersistantDataKey"
/**
 *  服务端返回的内嵌型dicts（用户推荐。。。）
 */
#define kExploreFetchListResponseRemoteEmbedDataKey @"kExploreFetchListResponseRemoteEmbedDataKey"

#define kExploreFetchListResponseArticleInCardDataKey   @"kExploreFetchListResponseArticleInCardDataKey"

#define kExploreFetchListResponseStockDataInCardDataKey   @"kExploreFetchListResponseStockDataInCardDataKey"

#define kExploreFetchListResponseBookDataInCardDataKey   @"kExploreFetchListResponseBookDataInCardDataKey"

#define kExploreFetchListResponseShortVideoDataInCardDataKey @"kExploreFetchListResponseShortVideoDataInCardDataKey"

#define kExploreFetchListResponseRemoteDataShouldPersistKey @"kExploreFetchListResponseRemoteDataShouldPersistKey"

#define kExploreFetchListRemoteLoadCount 20
#define kExploreFetchListSearchRemoteLoadCount 20
/**
 *  关注频道当前是否有红点
 */
#define kExploreFollowCategoryHasRedPointKey @"kExploreFollowCategoryHasRedPointKey"
/**
 *  当前频道是否为空
 */
#define kExploreCurrentCategoryListItemCountKey @"kExploreCurrentCategoryListItemCountKey"
/**
 *  新增被取消置顶的item数量
 */
#define kExploreFetchListResponseCancelStickCountKey @"kExploreFetchListResponseCancelStickCountKey"

/**
 *  请求额外参数，类型字典
 */
#define kExploreFetchListExtraGetParametersKey @"kExploreFetchListExtraGetParametersKey"

//////////混排列表refesh(或者load more)耗时中各个关键点时间戳对应的key/////////
#define kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey @"kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey"

#define kExploreFetchListTriggerRequestTimeStampKey @"kExploreFetchListTriggerRequestTimeStampKey"

#define kExploreFetchListGetLocalDataOperationBeginTimeStampKey @"kExploreFetchListGetLocalDataOperationBeginTimeStampKey"
#define kExploreFetchListGetLocalDataOperationEndTimeStampKey @"kExploreFetchListGetLocalDataOperationEndTimeStampKey"

#define kExploreFetchListGetRemoteDataOperationBeginTimeStampKey @"kExploreFetchListGetRemoteDataOperationBeginTimeStampKey"
#define kExploreFetchListRemoteRequestBeginTimeStampKey @"kExploreFetchListRemoteRequestBeginTimeStampKey"
#define kExploreFetchListGetRemoteDataOperationEndTimeStampKey @"kExploreFetchListGetRemoteDataOperationEndTimeStampKey"

#define kExploreFetchListPreInsertOperationBeginTimeStampKey @"kExploreFetchListPreInsertOperationBeginTimeStampKey"
#define kExploreFetchListPreInsertOperationEndTimeStampKey @"kExploreFetchListPreInsertOperationEndTimeStampKey"

#define kExploreFetchListInsertDataOperationBeginTimeStampKey @"kExploreFetchListInsertDataOperationBeginTimeStampKey"
#define kExploreFetchListInsertDataOperationEndTimeStampKey @"kExploreFetchListInsertDataOperationEndTimeStampKey"

#define kExploreFetchListSaveRemoteOperationBeginTimeStampKey @"kExploreFetchListSaveRemoteOperationBeginTimeStampKey"
#define kExploreFetchListSaveRemoteOperationEndTimeStampKey @"kExploreFetchListSaveRemoteOperationEndTimeStampKey"

#define kExploreFetchListPostSaveOperationBeginTimeStampKey @"kExploreFetchListPostSaveOperationBeginTimeStampKey"
#define kExploreFetchListPostSaveOperationEndTimeStampKey @"kExploreFetchListPostSaveOperationEndTimeStampKey"

#define kExploreFetchListManagerCallbackOperationBeginTimeStampKey @"kExploreFetchListManagerCallbackOperationBeginTimeStampKey"
#define kExploreFetchListManagerCallbackOperationEndTimeStampKey @"kExploreFetchListManagerCallbackOperationEndTimeStampKey"

#define kExploreFetchListFinishRequestTimeStampKey @"kExploreFetchListFinishRequestTimeStampKey"

#define kExploreFetchListHasPostNewUserActionKey @"kExploreFetchListHasPostNewUserActionKey"

// 是否展现好友正在读标签
#define kExploreFetchListShowFriendLabelKey   @"kExploreFetchListShowFriendLabelKey"

/**
 *  混排列表api类型
 */
typedef NS_ENUM(NSUInteger, ExploreFetchListApiType) {
    /**
     *   stream api
     */
    ExploreFetchListApiTypeStream = 0,
    /**
     *  垂直通用视频api（如：关心主页视频tab）
     */
    ExploreFetchListApiTypeVerticalVideo
};

#endif

