//
//  TTUGCTrackerHelper.h
//  Article
//
//  Created by SongChai on 2017/7/14.
//

@interface TTUGCTrackerHelper : NSObject

+ (NSDictionary *)trackExtraFromBaseCondition:(NSDictionary *)condition;

+ (NSDictionary *)logPbFromBaseCondition:(NSDictionary *)condition;

+ (NSString *)schemaTrackForPersonalHomeSchema:(NSString *)schema
                                  categoryName:(NSString *)category
                                      fromPage:(NSString *)from
                                       groupId:(NSString *)group
                                 profileUserId:(NSString *)profile;

@end
