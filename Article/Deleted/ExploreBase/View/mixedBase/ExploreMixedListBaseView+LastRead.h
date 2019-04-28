//
//  ExploreMixedListBaseView+LastRead.h
//  Article
//
//  Created by 王双华 on 16/7/26.
//
//

#import "ExploreMixedListBaseView.h"

#define kExploreMixedListBaseViewLastReadIncreaseInterval   0.5

@interface ExploreMixedListBaseView (LastRead)

- (void)insertLastReadToTopWithOrderIndex:(NSNumber *)orderIndex lastReadDate:(NSDate *)lastReadDate refreshDate:(NSDate *)refreshDate shouldShowRefreshButton:(BOOL)show;

- (NSString *)getUniqueIDForLastRead;
@end

