//
//  FHHouseSimilarManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseSimilarManager : NSObject

+(instancetype)sharedInstance;

- (void)requestForSimilarHouse:(NSDictionary *)parmasIds;

- (NSArray *)getCurrentSimilarArray;

- (void)resetSimilarArray;

- (BOOL)checkTimeIsInvalid;

@end

NS_ASSUME_NONNULL_END
