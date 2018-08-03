//
//  NewsFetchListRefreshTipManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-10-31.
//
//

#import <Foundation/Foundation.h>

@protocol NewsFetchListRefreshTipManagerDelegate;

@interface NewsFetchListRefreshTipManager : NSObject

@property(nonatomic, weak)id<NewsFetchListRefreshTipManagerDelegate>delegate;

- (void)cancel;
- (void)fetchListRefreshTipWithMinBehotTime:(NSTimeInterval)minBehotTime categoryID:(NSString *)categoryID count:(NSUInteger)count;

@end

@protocol NewsFetchListRefreshTipManagerDelegate <NSObject>

- (void)refreshTipManager:(NewsFetchListRefreshTipManager *)manager fetchedTip:(NSString *)tip categoryID:(NSString *)categoryID count:(NSInteger)count;


@end

