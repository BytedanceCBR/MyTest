//
//  TTVPlayerModel.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"
#import "TTVPlayerModel.h"
#import "TTVPlayerTipCreator.h"

@interface TTVVideoPlayerModel : TTVPlayerModel

/**
 paster请求参数,在feed中传"feed" 其他传"textlink"
 */
@property(nonatomic, copy) NSString *pasterAdFrom;

/**
 是否打开贴片广告功能  默认 YES
 */
@property(nonatomic, assign) BOOL enablePasterAd;
@end


