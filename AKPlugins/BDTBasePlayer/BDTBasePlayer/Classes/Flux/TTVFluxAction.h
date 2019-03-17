//
//  TTVFluxAction.h
//  Pods
//
//  Created by xiangwu on 2017/3/3.
//
//

#import <Foundation/Foundation.h>

@interface TTVFluxAction : NSObject

@property (nonatomic, assign, readonly) NSInteger actionType;
@property (nonatomic, strong, readonly) id payload;

- (instancetype)initWithActionType:(NSInteger)actionType payload:(id)payload;

@end
