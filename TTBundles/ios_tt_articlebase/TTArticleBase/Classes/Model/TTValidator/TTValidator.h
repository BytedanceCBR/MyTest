//
//  TTValidator.h
//  Article
//
//  Created by SunJiangting on 15-4-28.
//
//

#import <Foundation/Foundation.h>

@protocol TTValidator <NSObject>

- (BOOL)isValidObject:(id)object;

@end

@interface TTValidator : NSObject <TTValidator>

@end
