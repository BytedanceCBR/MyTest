//
//  TTVDetailNatantADPlayerTracker.h
//  Article
//
//  Created by rongyingjie on 2017/10/31.
//

#import <Foundation/Foundation.h>
#import "TTVADPlayerTracker.h"

@interface TTVDetailNatantADPlayerTracker : TTVADPlayerTracker
//用来表示自动播放打点的标识位，自动播放结束后内部会自动置为NO
@property(nonatomic, assign)BOOL isAutoPlay;

@end
