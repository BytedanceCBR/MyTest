//
//  TTVLoadingState.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/15.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface TTVLoadingState : NSObject<TTVReduxStateProtocol>

@property (nonatomic, assign, getter=isShowed) BOOL showed; // 已经展示
@property (nonatomic, assign) BOOL shouldShow;// 应该展示

@end

NS_ASSUME_NONNULL_END
