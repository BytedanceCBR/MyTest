//
//  TTVPlayerTracker.h
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerProtocol.h"

@class TTVPlayerStateStore;

@protocol TTVPlayerTracker <NSObject>
@property(nonatomic, copy)NSString *trackLabel;
@property(nonatomic, copy) NSString *itemID;
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, copy) NSString *videoSubjectID;
@property(nonatomic, copy) NSString *categoryID;
@property(nonatomic, assign) NSInteger aggrType;
@property(nonatomic, copy) NSString *adID;
@property(nonatomic, copy) NSString *logExtra;
@property(nonatomic, copy) NSDictionary *logPb;
@property(nonatomic, copy) NSString *enterFrom;
@property(nonatomic, copy) NSString *categoryName;
@property(nonatomic, copy) NSString *authorId;


@end

@interface TTVPlayerTracker : NSObject<TTVPlayerContext ,TTVPlayerTracker>

@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property(nonatomic, assign ,readonly)BOOL isReplaying;
@property(nonatomic, assign ,readonly)BOOL isRetry;

/**
 public method
 */
- (void)sendEndTrack;

/**
 call by subclass
 */
- (void)ttv_kvo;
/**
 主动播放
 */
- (BOOL)ttv_sendEvenWhenPlayActively;
- (NSString *)ttv_dataTrackLabel;
- (NSString *)ttv_enterFullscreenType;
- (NSString *)ttv_fullscreenAction;
- (NSString *)ttv_exitFullscreenAction;
- (NSMutableDictionary *)ttv_dictWithEvent:(NSString *)event
                                 label:(NSString *)label;
- (void)addExtra:(NSDictionary *)extra forEvent:(NSString *)event;
- (NSMutableDictionary *)extraFromEvent:(NSString *)event;
- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state;
@end
