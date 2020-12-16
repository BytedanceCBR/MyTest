//
//  FHSuggestionDefines.h
//  Pods
//
//  Created by bytedance on 2020/12/3.
//

#ifndef FHSuggestionDefines_h
#define FHSuggestionDefines_h

typedef enum : NSUInteger {
    FHEnterSuggestionTypeDefault       =   0,// H5
    FHEnterSuggestionTypeHome       =   1,// 首页
    FHEnterSuggestionTypeFindTab       =   2,// 找房Tab
    FHEnterSuggestionTypeList       =   3, // 列表页
    FHEnterSuggestionTypeRenting       =   4,// 租房大类页
    FHEnterSuggestionTypeOldMain       =   5,// 二手房大类页
    FHEnterSuggestionTypeNewMain       =   6, //新房大类页
    FHEnterSuggestionTypeMapSearch      =   7, //地图找房
} FHEnterSuggestionType;

#endif /* FHSuggestionDefines_h */
