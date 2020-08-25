//
//  FHDetailNewMediaHeaderDataHelper.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/23.
//
//负责头图部分的数据处理，包括轮播图数据，大图展示数据，图片相册数据
#import <Foundation/Foundation.h>
@class FHMultiMediaItemModel;
NS_ASSUME_NONNULL_BEGIN
@class FHDetailNewMediaHeaderDataHelperData,FHDetailNewMediaHeaderModel;

@interface FHDetailNewMediaHeaderDataHelper : NSObject
+ (FHDetailNewMediaHeaderDataHelperData *)generateModel:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel;


@end

@interface FHDetailNewMediaHeaderDataHelperData : NSObject

@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *itemArray;
@property (nonatomic, copy) NSArray *imageList;


@end

NS_ASSUME_NONNULL_END
