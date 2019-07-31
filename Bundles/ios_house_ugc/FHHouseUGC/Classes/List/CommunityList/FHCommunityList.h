#ifndef FHCommunityList_h
#define FHCommunityList_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FHCommunityListType) {
    FHCommunityListTypeFollow,
    FHCommunityListTypeChoose
};

typedef NS_ENUM(NSInteger, FHUGCCommunityDistrictId) {
    FHUGCCommunityDistrictTabIdFollow = -2,
    FHUGCCommunityDistrictTabIdRecommend = -1
};

#endif