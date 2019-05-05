//
//  TTVVideoPlayerViewShareCointainerView.h
//  Article
//
//  Created by lishuangyang on 2017/10/12.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStateStore.h"

typedef void (^TTVideoPlayerShareContainerViewShareActionBlock) (NSString *shareActionType);

@interface TTVVideoPlayerViewShareCointainerView : UIView

@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, copy)TTVideoPlayerShareContainerViewShareActionBlock shareCointainerViewShareAction;
@end
