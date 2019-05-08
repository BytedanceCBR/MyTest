//
//  TTVDemanderTrackerManager.h
//  Article
//
//  Created by panxiang on 2017/6/16.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerTracker.h"

@class TTVPlayerStateStore;
@class TTVADPlayerTracker;
@class TTVDataPlayerTracker;
@class TTVPlayerUrlTracker;
@interface TTVDemanderTrackerManager : NSObject<TTVPlayerTracker ,TTVPlayerContext>
@property(nonatomic, copy) NSString *videoSubjectID;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property(nonatomic, copy)NSString *trackLabel;
@property(nonatomic, copy) NSString *itemID;
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, copy) NSString *categoryID;
@property(nonatomic, assign) NSInteger aggrType;
@property(nonatomic, copy) NSString *adID;
@property(nonatomic, copy) NSString *logExtra;
@property(nonatomic, copy) NSDictionary *logPb;
@property(nonatomic, copy) NSString *categoryName;
@property(nonatomic, copy) NSString *enterFrom;
@property(nonatomic, copy) NSString *authorId;

- (void)addExtra:(NSDictionary *)extra forEvent:(NSString *)event;
- (void)configureData;
- (void)sendEndTrack;
- (void)registerTracker:(TTVPlayerTracker *)tracker;
@end
