//
//  ImageListData.h
//  Gallery
//
//  Created by Hu Dianwei on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Common_ListData_h
#define Common_ListData_h

#define ssGetListDataFinishedNotification   @"ssGetListDataFinishedNotification"
#define kListDataConditionCachedKey        @"kListDataConditionCachedKey"
// condition keys
#define kListDataConditionAppandDictKey    @"kListDataConditionAppandDictKey"
#define kListDataConditionSortTypeKey      @"kListDataConditionSortTypeKey"
#define kListDataConditionRangeTypeKey     @"kListDataConditionRangeTypeKey"
#define kListDataConditionRankKey          @"kListDataConditionRankKey"
#define kListDataConditionTagKey           @"kListDataConditionTagKey"

#define kListDataConditionWillCustomRankKey @"kListDataConditionWillCustomRankKey" // subclass will calculate rank key, will not use SSGetRemoteDataOperation logic

#define kListDataConditionKeywordKey        @"kListDataConditionKeywordKey"
#define kListDataConditionSearchFromKey           @"kListDataConditionSearchFromKey"

#define kListDataURLArrayKey               @"kListDataURLArrayKey"    // gallery deprecate this parameter. 
#define kListDataTypeKey                   @"kListDataTypeKey"
#define kListDataConditionCategoryIDKey     @"kListDataConditionCategoryIDKey"
#define kListDataConditionEmbededTipDataKey @"kListDataConditionEmbededTipDataKey"
#define kListDataConditionOpManagerKey      @"kListDataConditionOpManagerKey"

////离线下载获取列表数据后userInfo中的condition key
//#define kListDataAirDownloadGetDataConditionKey @"kListDataAirDownloadGetDataConditionKey"

//condition keys for update //动态列表传递以下额外参数(目前动态，必须传递updateType, 可选传递TagKey)
#define kListDataConditionUpdateTypeKey @"kListDataConditionUpdateTypeKey"
//condition keys for user update
#define kListDataConditionUserUpdateUserID @"kListDataConditionUserUpdateUserID"

#define kSSDataOperationEmbededTipContextKey @"kSSDataOperationEmbededTipContextKey"


#define kListDataAppandDictTimestampKey @"kListDataAppandDictTimestampKey"

#define kListDataCustomRemoteCountKey @"kListDataCustomRemoteCountKey" //设置获取列表条数

#define ListDataDefaultRemoteNormalLoadCount 20

#define ListDataEssayRemoteNormalLoadCount 50
#define ListDataGalleryRemoteNormalLoadCount 40 //gallery recent load count
#define ListDataGalleryRemoteHotLoadCount 40    //gallery hot ，(eg: all_gallery fist tab)

#define ListDataVideoRemoteNormalLoadCount 50

#define ListDataRemoteFavouriteLoadCount   300
#define ListDataRemoteTopLoadCount         300
#define ListDataOfflineCount               200

#define ListCachedDataLoadCount                300

//Update
#define UpdateListDataLocalLoadCount 20             //动态列表， 本地一次读取条数
#define UpdateListDataLocalOffLineLoadCount 20      //动态列表， 离线时，本地一次读取条数
#define UpdateListDataRemoteLoadCount 20            //动态列表， 从网络一次读取条数
#define UpdateListDataCachedListCont        20      //动态列表， 缓存数量

#pragma operation related
// passed-in
#define kSSDataOperationConditionKey    @"kSSDataOperationConditionKey"
#define kSSDataOperationForceFromRemoteIfNoDataKey  @"kSSDataOperationForceFromRemoteIfNoDataKey"   //头条3.6添加， 目前只有头条用，头条默认改为如果没有非fromRemote,即使列表为空，也不会请求， 有了该key之后, 为空会请求remote，（只用于当前正在显示的频道）
#define kSSDataOperationFromLocalKey    @"kSSDataOperationFromLocalKey"
#define kSSDataOperationFromRemoteKey   @"kSSDataOperationFromRemoteKey"
#define kSSDataOperationLoadMoreKey     @"kSSDataOperationLoadMoreKey"
#define kSSDataOperationReloadFromKey   @"kSSDataOperationReloadFromKey"//刷新的来源， value传 ListDataOperationReloadFromType
#define kListDataClearKey               @"kListDataClearKey"
#define kOperationPriorityKey           @"kOperationPriorityKey" // the operation queue priority
//#define kSSDataOperationHelperKey       @"kSSDataOperationHelperKey"



// generated
#define kSSDataOperationLoadFinishedKey @"kSSDataOperationLoadFinishedKey"
#define kSSDataOperationCanLoadMoreKey  @"kSSDataOperationCanLoadMoreKey"
#define kSSDataOperationOriginalListKey @"kSSDataOperationOriginalListKey"
#define kSSDataOperationOrderedListKey  @"kSSDataOperationOrderedListKey"
#define kSSDataOperationRequestInfoKey  @"kSSDataOperationRequestInfoKey"
#define kSSDataOperationInsertedDataKey @"kSSDataOperationInsertedDataKey"

#define kSSDataOperationMinimunOrderedIndexKey @"kSSDataOperationMinimunOrderedIndexKey"

//intermeidate
#define kSSDataOperationRemoteDataKey   @"kSSDataOperationRemoteDataKey"

typedef enum DataSortType
{
    DataSortTypeNone      =   0,
    DataSortTypeHot       =   1,
    DataSortTypeTop       =   2,
    DataSortTypeRecent    =   3,
    DataSortTypeFavorite  =   4,
    DataSortTypeMyUGC     =   5,    // 我发表的，essay
    DataSortTypeSearch    =   6,
    DataSortTypeUGC       =   7,    // 用户原创
    DataSortTypePGCList   =   8,    //PGC profile页
    DataSortTypeHotDataList = 9,    //榜单页
    DataSortTypeRecommend =   10, // 推荐列表
} DataSortType;

typedef enum DataCacheType
{
    DataCacheTypeNone = 0,
    DataCacheTypeCached = 1
} DataCacheType;

typedef enum DataRangeType
{
    DataRangeNone     =        0,
    DataRangeDaily    =        1,
    DataRangeWeekly   =        2,
    DataRangeMonthly  =        3,
    DataRangeHistory  =        4
} DataRangeType;

//对于category是category type， 对于group 为group type
typedef NS_ENUM(NSUInteger, ListDataType) //item type
{
    ListDataTypeNone = 0,
    ListDataTypeImage =     1,
    ListDataTypeVideo =     2,
    ListDataTypeEssay =     3,
    ListDataTypeArticle =   4,
    ListDataTypeWeb = 5,
    ListDataTypeSubscribeEntry = 6,//4.3新增，为订阅频道
};

typedef enum UpdateType
{
    UpdateTypeNone = 0,
    UpdateTypeActivity = 11,
    UpdateTypeNotification = 12,
    UpdateTypeRepin = 13,
    UpdateTypeUserActivity = 21,
    UpdateTypeUserNotification = 22,
    UpdateTypeUserRepin = 23,
    UpdateTypeUserComment = 24,
    
    // only used by zone
    UpdateTypeZoneNotification = 25,
}UpdateType;

//刷新的来源
typedef enum ListDataOperationReloadFromType{
    ListDataOperationReloadFromTypeNone = 0,        //非刷新，或者不需要统计
    ListDataOperationReloadFromTypeUserManual,      //用户手动刷新
    ListDataOperationReloadFromTypeAuto,            //自动刷新
    ListDataOperationReloadFromTypeAirdownload,     //离线下载
    ListDataOperationReloadFromTypeTip,             //点击tip
    ListDataOperationReloadFromTypeLastRead,        //点击"上次看到这里"
    //5.7新增
    ListDataOperationReloadFromTypeAutoFromBackground, //从后台切到前台的自动刷新
    ListDataOperationReloadFromTypePull,            //用户下拉刷新
    ListDataOperationReloadFromTypeTab,             //点击底部tab刷新（底部tab无数字）
    ListDataOperationReloadFromTypeTabWithTip,      //点击底部tab刷新（底部tab有数字）
    ListDataOperationReloadFromTypeClickCategory,   //点击顶部频道刷新（底部tab无数字）
    ListDataOperationReloadFromTypeClickCategoryWithTip,//点击顶部频道刷新（底部tab有数字）
    ListDataOperationReloadFromTypeLoadMore,        //加载更多
    ListDataOperationReloadFromTypePreLoadMore,      //预加载更多
    ListDataOperationReloadFromTypeLoadMoreDraw,        //详情页主动加载更多
    ListDataOperationReloadFromTypePreLoadMoreDraw,      //详情页预加载更多
    ListDataOperationReloadFromTypeCardItem,            //点击水平卡片上任意视频
    ListDataOperationReloadFromTypeCardMore,            //点击水平上的更多
    ListDataOperationReloadFromTypeCardDraw,            //滑动列表卡片刷新
}ListDataOperationReloadFromType;

//搜索来源
typedef enum ListDataSearchFromType{
    ListDataSearchFromTypeTab = 1,                  //搜索框，即用户主动搜索(默认)
    ListDataSearchFromTypeHotword,                  //来源自热词
    ListDataSearchFromTypeContent,                  //详情页关键字
    ListDataSearchFromTypeTag,                      //标签
    ListDataSearchFromTypeHistory,                  // 搜索历史
    ListDataSearchFromTypeSuggestion,               // 搜索提示
    ListDataSearchFromTypeForum,                    // 搜索话题 4.6add，5.8.x废弃
    ListDataSearchFromTypeVideo,                    // 搜索视频 5.0add
    ListDataSearchFromTypeWeitoutiao,               // 来源微头条
    ListDataSearchFromTypeConcern,                  // 来源关心 5.1add
    ListDataSearchFromTypeWebViewMenuItem,          // 来源webview长按选中 5.5add
    ListDataSearchFromDetail,                       // 详情页顶部搜索框
    ListDataSearchFromTypeFeed,                         // Feed顶部搜索框
    ListDataSearchFromTypeSubscribe,                    // 订阅频道查看更多
    ListDataSearchFromTypeMineTab,                  //我的Tab收藏历史搜索
    ListDataSearchFromTypeAddFriend,                //添加好友
    ListDataSearchFromTypeHotsoonVideo,             //小视频tab右上角搜索 6.4.4 add
}ListDataSearchFromType;

#endif
