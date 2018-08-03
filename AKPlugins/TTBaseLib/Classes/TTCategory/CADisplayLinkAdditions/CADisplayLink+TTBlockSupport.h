//
//  CADisplayLink+TTBlockSupport.h
//  Article
//
//  Created by 王霖 on 16/10/13.
//
//

#import <QuartzCore/QuartzCore.h>

@interface CADisplayLink (TTBlockSupport)

@property (nonatomic, copy)void (^ _Nullable block)();

+ (nullable instancetype)ttDisplayLinkWithBlock:(nonnull void(^)())block;

@end
