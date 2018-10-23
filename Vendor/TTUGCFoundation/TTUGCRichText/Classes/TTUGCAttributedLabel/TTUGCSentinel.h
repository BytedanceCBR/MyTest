//
//  TTUGCSentinel.h
//  Article
//
//  Created by Jiyee Sheng on 05/16/2017.
//
//

#import <Foundation/Foundation.h>

@interface TTUGCSentinel : NSObject

@property (nonatomic, assign, readonly) int32_t value;

- (int32_t)increase;

@end
