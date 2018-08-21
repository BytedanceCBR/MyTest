//
//  TTRNBridge+Cell.h
//  Article
//
//  Created by Chen Hong on 16/8/15.
//
//

#import "TTRNBridge.h"

@interface TTRNBridge (Cell)

- (void)dislikeConfirmed;

@end

@interface TTRNBridge ()

@property (nonatomic, copy) RCTResponseSenderBlock dislikeCallback;

@end
