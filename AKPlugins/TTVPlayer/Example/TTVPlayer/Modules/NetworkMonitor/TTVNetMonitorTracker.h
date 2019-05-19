//
//  TTVNetMonitorTracker.h
//  Article
//
//  Created by panxiang on 2018/11/15.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"

@protocol TTVNetMonitorTracker <NSObject>
@property (nonatomic, strong) TTVPlayerStore *store;
@end
@interface TTVNetMonitorTracker : NSObject
@property (nonatomic, strong) TTVPlayerStore *store;
@end

