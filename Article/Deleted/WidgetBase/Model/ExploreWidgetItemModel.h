//
//  ExploreWidgetItemModel.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-11.
//
//

/**
 *  widget每条item的Model
 *
 */
#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"

@interface ExploreWidgetItemModel : NSObject<NSCoding>

@property(nonatomic, strong) NSString * title;
@property(nonatomic, strong) NSNumber * commentCount;
@property(nonatomic, strong) NSNumber * beHotTime;
@property(nonatomic, strong) NSDictionary * rightImgDict;

@property(nonatomic, strong) NSString * abstract;

/**
 *  group id
 */
@property(nonatomic, strong) NSNumber * uniqueID;

- (id)initWithDict:(NSDictionary *)dict;

- (BOOL)hasRightImg;
- (NSArray *)rightImgURLHeaders;

@end
