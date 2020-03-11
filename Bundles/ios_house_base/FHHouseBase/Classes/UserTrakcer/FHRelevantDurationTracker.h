//
//  FHRelevantDurationTracker.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHRelevantDurationTracker : NSObject

+ (instancetype)sharedTracker;

- (void)appendRelevantDurationWithGroupID:(NSString *)groupID
                                   itemID:(NSString *)itemID
                                enterFrom:(NSString *)enterFrom
                             categoryName:(NSString *)categoryName
                                 stayTime:(NSInteger)stayTime
                                    logPb:(NSDictionary *)logPb;
- (void)appendRelevantDurationWithGroupID:(NSString *)groupID
                                   itemID:(NSString *)itemID
                                enterFrom:(NSString *)enterFrom
                             categoryName:(NSString *)categoryName
                                 stayTime:(NSInteger)stayTime
                                    logPb:(NSDictionary *)logPb
                                 answerID:(nullable NSString *)answerID
                               questionID:(NSString *)questionID
                        enterFromAnswerID:(nullable NSString *)enterFromAnswerID
                          parentEnterFrom:(nullable NSString *)parentEnterFrom;

- (void)beginRelevantDurationTracking;
- (void)sendRelevantDuration;

@end

NS_ASSUME_NONNULL_END
