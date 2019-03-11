//
//  TTVPlayerStateStore.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVFluxStore.h"
#import "TTVPlayerStateModel.h"
#import "TTVPlayerStateAction.h"
#import "TTVFluxDispatcher.h"
@interface TTVPlayerStateStore : TTVFluxStore
@property (nonatomic, strong, readonly) TTVPlayerStateModel *state;
- (void)sendAction:(TTVPlayerEventType)event payload:(id)payload;
@end
