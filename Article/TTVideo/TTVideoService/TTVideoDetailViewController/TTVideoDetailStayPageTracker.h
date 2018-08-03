//
//  TTVideoDetailStayPageTracker.h
//  Article
//
//  Created by 刘廷勇 on 16/5/4.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "ExploreOrderedData+TTBusiness.h"

@interface TTVideoDetailStayPageTracker : NSObject

@property (nonatomic, copy  ) NSString   *clickLabel;
@property (nonatomic, assign) int64_t    uniqueID;
@property (nonatomic, assign) BOOL               viewIsAppear;

- (instancetype)initWithUniqueID:(int64_t)uniqueID
                      clickLabel:(NSString *)clickLabel;

- (void)startStayTrack;

- (void)endStayTrackWithDict:(NSDictionary *)event3Dict;

- (float)currentStayDuration;
//  用来统计广告视频的stay_page
- (void)sendFullStayPageWithADId:(NSString *)ad_id logExtra:(NSString *)logExtra;

@end
