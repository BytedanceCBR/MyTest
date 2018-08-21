//
//  TTSubEntranceManager.h
//  Article
//
//  Created by Chen Hong on 15/6/23.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SubEntranceType) //subEntrance type
{
    SubEntranceTypeHead  =  0,
    SubEntranceTypeStick =  1,
};

@interface TTSubEntranceManager : NSObject

+ (SubEntranceType)subEntranceTypeForCategory:(NSString *)category;
+ (void)setSubEntranceType:(SubEntranceType)type forCategory:(NSString *)category;

+ (NSArray *)subEntranceObjArrayForCategory:(NSString *)category concernID:(NSString *)concernID;
+ (void)setSubEntranceObjArray:(NSArray *)array forCategory:(NSString *)category concernID:(NSString *)concernID;

+ (NSTimeInterval)subEntranceLastRefreshTimeIntervalForCategory:(NSString *)category concernID:(NSString *)concernID;
+ (void)setSubEntranceRefreshTimeInterval:(NSTimeInterval)interval forCategory:(NSString *)category concernID:(NSString *)concernID;

@end
