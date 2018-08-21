//
//  LastRead.h
//  Article
//
//  Created by 王双华 on 16/7/26.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"

NS_ASSUME_NONNULL_BEGIN

@interface LastRead : ExploreOriginalData

@property (nullable, nonatomic, retain) NSDate *refreshDate;
@property (nullable, nonatomic, retain) NSDate *lastDate;
@property (nullable, nonatomic, retain) NSNumber *showRefresh;

- (void)updateWithShowRefresh:(BOOL)showRefresh;
- (void)updateWithLastReadDate:(NSDate *)lastReadDate refreshDate:(NSDate *)refreshDate;

@end

NS_ASSUME_NONNULL_END
