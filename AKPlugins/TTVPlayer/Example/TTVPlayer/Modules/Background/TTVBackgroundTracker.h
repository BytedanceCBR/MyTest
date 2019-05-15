//
//  TTVBackgroundTracker.h
//  Article
//
//  Created by panxiang on 2018/12/11.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContext.h"

@interface TTVBackgroundTracker : NSObject<TTVPlayerTracker>
@property (nonatomic, strong) TTVPlayerStore *store;
@end


