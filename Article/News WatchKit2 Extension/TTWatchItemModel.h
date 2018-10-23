//
//  WatchItemModel.h
//  Article
//
//  Created by 邱鑫玥 on 16/8/18.
//
//

#import <Foundation/Foundation.h>

@interface TTWatchItemModel : NSObject

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
//- (TTImageInfosModel *)rightImgModel;

- (NSString *)imageURLString;

@end
