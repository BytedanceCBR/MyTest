//
//  TTVGestureManager.h
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"

@interface TTVGestureManager : NSObject<TTVPlayerContext>
@property (nonatomic ,assign)BOOL isNoneFullScreenPlayerGestureEnabled;
@property (nonatomic ,assign)BOOL videoPlayerDoubleTapEnable;
- (void)enableProgressHub:(BOOL)enable;


- (instancetype)initWithStore:(TTVPlayerStore *)store;
@end

@interface TTVPlayer (GestureManager)
- (TTVGestureManager *)gestureManager;
@end
