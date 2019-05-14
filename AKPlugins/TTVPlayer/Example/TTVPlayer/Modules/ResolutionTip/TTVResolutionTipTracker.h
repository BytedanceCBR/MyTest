//
//  TTVResolutionTipTracker.h
//  Article
//
//  Created by panxiang on 2018/11/15.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayerContext.h"
@interface TTVResolutionTipTracker : NSObject<TTVPlayerTracker>
@property (nonatomic, strong) TTVPlayerStore *store;
@end

