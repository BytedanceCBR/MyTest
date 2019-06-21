//
//  TTPlacemarkItem+GoogleAPI.h
//  TTPostThread
//
//  Created by Vic on 2018/11/25.
//

#import "TTPlacemarkItem.h"

typedef NS_ENUM(NSInteger, PlacemarkItemType) {
    PlacemarkItemTypeChina = 0,
    PlacemarkItemTypeForeign = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface TTPlacemarkItem (GoogleAPI)

@property (nonatomic) PlacemarkItemType type;

@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *locationTags;

/** 检测地点信息是否为地区 */
- (BOOL)iskindOfLocality;

@end

NS_ASSUME_NONNULL_END
