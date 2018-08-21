//
//  TTValueTransformer.h
//  TT
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TTTransformerErrorDomain;
extern const NSInteger TTTransformerErrorInvalidInput;
extern NSString * const TTTransformerInputValueErrorKey;

@protocol TTTransformerProtocol <NSObject>

@required
- (id)transformedValue:(id)value success:(BOOL *)success error:(NSError **)error;

@optional
- (id)reverseTransformedValue:(id)value success:(BOOL *)success error:(NSError **)error;
@end


typedef id (^TTValueTransformerBlock)(id value, BOOL *success, NSError **error);

@interface TTValueTransformer : NSValueTransformer <TTTransformerProtocol>

/// 仅有正向转译
+ (instancetype)transformerUsingForwardBlock:(TTValueTransformerBlock)transformation;

/// 正向转译和反向转译一致
+ (instancetype)transformerUsingReversibleBlock:(TTValueTransformerBlock)transformation;

/// 分别传入正向转译和反向转译
+ (instancetype)transformerUsingForwardBlock:(TTValueTransformerBlock)forwardTransformation reverseBlock:(TTValueTransformerBlock)reverseTransformation;

@end
