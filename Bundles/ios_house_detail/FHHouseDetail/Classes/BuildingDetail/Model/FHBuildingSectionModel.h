//
//  FHBuildingSectionModel.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/3.
//

#import <Foundation/Foundation.h>
#import "FHBuildingDetailModel.h"
typedef NS_ENUM(NSUInteger, FHBuildingSectionType) {
    FHBuildingSectionTypeHeader = 1,
    FHBuildingSectionTypeInfo,
    FHBuildingSectionTypeFloor,
    FHBuildingSectionTypeEmpty,
    FHBuildingSectionTypeImage
};



NS_ASSUME_NONNULL_BEGIN

@interface FHBuildingSectionModel : NSObject

@property (nonatomic, assign) FHBuildingSectionType sectionType;

@property (nonatomic, copy) NSString *className;

@property (nonatomic, copy) NSString *sectionTitle;

@end


NS_ASSUME_NONNULL_END
