//
//  TTVFeedItem+ComputedProperties.h
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import <TTVideoService/VideoFeed.pbobjc.h>

@interface TTVFeedItem (ComputedProperties)

- (BOOL)isListShowPlayVideoButton;
- (BOOL)isPlayInDetailView;
- (BOOL)isVideoPGCCard;
- (BOOL)couldAutoPlay;
- (BOOL)couldContinueAutoPlay;

- (NSDictionary *)mointerInfo;

@end
