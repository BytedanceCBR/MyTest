//
//  TTVPlayerContext.h
//  Article
//
//  Created by panxiang on 2017/9/20.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerProtocol.h"

@interface TTVPlayerContext : NSObject<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@end
