//
//  TTVPartFactory.h
//  ScreenRotate
//
//  Created by lisa on 2019/3/26.
//  Copyright © 2019 zuiye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerCustomPartDelegate.h"
#import "TTVPlayerDefine.h"
#import "TTVPlayerPartProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVPartFactory : NSObject<TTVPlayerCustomPartDelegate>

@property (nonatomic, weak) NSObject<TTVPlayerCustomPartDelegate> *customPartDelegate;
@property (nonatomic, strong) TTVPlayerControlViewFactory * controlFactory;
/**
 通过 key 以及 注册到，是生成 custom 传入的 part 还是内置的 part

 @param key part 对应的 key
 @return part
 */
- (NSObject<TTVPlayerPartProtocol> *)createPartForKey:(TTVPlayerPartKey)key;

@end

NS_ASSUME_NONNULL_END
