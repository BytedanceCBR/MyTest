//
//  FHSearchChannelTypes.h
//  FHHouseBase
//
//  Created by 张静 on 2019/7/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString const *CHANNEL_ID ;
extern NSString const *CHANNEL_ID_CIRCEL_SEARCH ;
extern NSString const *CHANNEL_ID_SUBWAY_SEARCH;
extern NSString const *CHANNEL_ID_MAP_FIND_HOUSE; //地图找房 ✅

extern NSString const *CHANNEL_ID_RELATED_COURT; //相关新房 / 周边新盘 ✅
//r.GET("/f100/api/related_court", views.RelatedCourt)

extern NSString const *CHANNEL_ID;
extern NSString const *CHANNEL_ID_RECOMMEND; //首页二手房推荐 ✅
extern NSString const *CHANNEL_ID_RECOMMEND_RENT; //首页租房推荐 ✅
extern NSString const *CHANNEL_ID_RELATED_HOUSE; //相关二手房 ✅
extern NSString const *CHANNEL_ID_RELATED_RENT; //相关租房 ✅
extern NSString const *CHANNEL_ID_RELATED_NEIGHBORHOOD; //相关小区 ✅
extern NSString const *CHANNEL_ID_SEARCH_COURT; //新房搜索 ✅
extern NSString const *CHANNEL_ID_SEARCH_HOUSE; //二手房搜索 ✅
extern NSString const *CHANNEL_ID_SEARCH_HOUSE_WITH_BANNER; //二手房大类页 ✅
extern NSString const *CHANNEL_ID_SEARCH_NEIGHBORHOOD; //小区搜索 ✅
extern NSString const *CHANNEL_ID_SEARCH_RENT; //租房搜索 ✅
extern NSString const *CHANNEL_ID_SEARCH_RENT_WITH_BANNER; //租房大类页 ✅

extern NSString const *CHANNEL_ID_SUGGESTION; //suggestion ✅
extern NSString const *CHANNEL_ID_SAME_NEIGHBORHOOD_HOUSE; //同小区房源 ✅
extern NSString const *CHANNEL_ID_SAME_NEIGHBORHOOD_RENT; //同小区租房 ✅

extern NSString const *CHANNEL_ID_RECOMMEND_SEARCH; //猜你想找 ✅
//extern NSString const *CHANNEL_ID_GUESS_SEARCH; //猜你想搜 ❎
extern NSString const *CHANNEL_ID_RENT_COMMUTING; //通勤找房 ✅
extern NSString const *CHANNEL_ID_SEARCH_NEIGHBORHOOD_DEAL; //查成交 ✅
extern NSString const *CHANNEL_ID_RECOMMEND_COURT; //新房首页推荐 ✅
extern NSString const *CHANNEL_ID_RECOMMEND_COURT_OLD; //二手房推荐新房
extern NSString const *CHANNEL_ID_HELP_ME_FIND_HOUSE; // 帮我找房
extern NSString const *CHANNEL_ID_SUBWAY_HOUSE_HOUSE_LIST; // 地铁找房房源列表
extern NSString const *CHANNEL_ID_MAP_FIND_RENT; //租房地图找房列表页

extern NSString const *CHANNEL_ID_REALTOR_DETAIL_HOUSE; //租房地图找房列表页

//r.GET("/f100/api/recommend", views.Recommend)✅
//r.GET("/f100/api/v2/recommend", views.RecommendV2)✅
//r.GET("/f100/api/search_rent", views.SearchRent)
//r.GET("/f100/api/search", views.SearchWarpper)
//r.GET("/f100/api/map_search", views.SearchByMap) ✅
//r.GET("/f100/api/related_house", views.RelatedHouse) ✅
//r.GET("/f100/api/same_neighborhood_house", views.SameNeighborhoodHouses) ✅
//r.GET("/f100/api/recommend_search", views.RecommendSearch) ✅
//r.GET("/f100/api/search_neighborhood", views.SearchNeighborhood)✅
//r.GET("/f100/api/related_neighborhood", views.RelatedNeighborhood) ✅
//r.GET("/f100/api/search_neighborhood_deal", views.SearchNeighborhoodDeal) ✅
//r.GET("/f100/api/search_court", views.SearchCourt) ✅
//r.GET("/f100/api/related_rent", views.RelatedRent) ✅
//r.GET("/f100/api/same_neighborhood_rent", views.SameNeighborhoodRent) ❎
//r.GET("/f100/api/search_fake_house", views.SearchFake) ❎

@interface FHSearchChannelTypes : NSObject

@end

NS_ASSUME_NONNULL_END
