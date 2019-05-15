//
//  TTVTrackManager.h
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"

@interface TTVTrackManager : NSObject<TTVPlayerContext>

@property(nonatomic, assign) BOOL enableCoreTrack;

@property(nonatomic, assign) BOOL isAutoPlay;

- (NSDictionary *_Nullable)extensionParamsForPlayerCoreTrackType:(NSString *)trackType;

- (void)removeExtensionParam:(NSString *)paramKey forTrackType:(NSString *)trackType;

- (void)removeAllExtensionParamsForTrackType:(NSString *)trackType;

- (void)addExtensionParams:(NSDictionary *_Nullable)params forTrackType:(NSString *)trackType;

@end

@interface TTVPlayer (TTVTrackManager)
- (TTVTrackManager *)trackManager;
@end
