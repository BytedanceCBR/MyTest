//
//  FHMapSearchTypes.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#ifndef FHMapSearchTypes_h
#define FHMapSearchTypes_h

typedef NS_ENUM(NSInteger , FHMapSearchType) {
    FHMapSearchTypeUnknown  = 0,
    FHMapSearchTypeNewHouse = 1,
    FHMapSearchTypeOldHouse = 2,
    FHMapSearchTypeNeighborhood = 4, //地图拖放到小区级别
    FHMapSearchTypeDistrict = 5, // 地图显示 区县级别
    FHMapSearchTypeArea = 6 , // 地图显示 商圈等级别
};

#endif /* FHMapSearchTypes_h */
