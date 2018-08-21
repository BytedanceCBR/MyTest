//
//  TTValueTransformer.m
//  TT
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "TTValueTransformer.h"


NSString * const TTTransformerErrorDomain = @"TTTransformerErrorDomain";

const NSInteger TTTransformerErrorInvalidInput = 1;

NSString * const TTTransformerInputValueErrorKey = @"TTTransformerInputValueErrorKey";

@interface TTReversibleValueTransformer : TTValueTransformer
@end

@interface TTValueTransformer ()

@property (nonatomic, copy, readonly) TTValueTransformerBlock forwardBlock;
@property (nonatomic, copy, readonly) TTValueTransformerBlock reverseBlock;

@end

@implementation TTValueTransformer

#pragma mark Lifecycle

+ (instancetype)transformerUsingForwardBlock:(TTValueTransformerBlock)forwardBlock {
	return [[TTValueTransformer alloc] initWithForwardBlock:forwardBlock reverseBlock:nil];
}

+ (instancetype)transformerUsingReversibleBlock:(TTValueTransformerBlock)reversibleBlock {
	return [[TTReversibleValueTransformer alloc] initWithForwardBlock:reversibleBlock reverseBlock:reversibleBlock];
}

+ (instancetype)transformerUsingForwardBlock:(TTValueTransformerBlock)forwardBlock reverseBlock:(TTValueTransformerBlock)reverseBlock {
	return [[TTReversibleValueTransformer alloc] initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

- (id)initWithForwardBlock:(TTValueTransformerBlock)forwardBlock reverseBlock:(TTValueTransformerBlock)reverseBlock {
	NSParameterAssert(forwardBlock != nil);

	self = [super init];
	if (self == nil) return nil;

	_forwardBlock = [forwardBlock copy];
	_reverseBlock = [reverseBlock copy];

	return self;
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
	return NO;
}

+ (Class)transformedValueClass {
	return NSObject.class;
}

- (id)transformedValue:(id)value {
	NSError *error = nil;
	BOOL success = YES;

	return self.forwardBlock(value, &success, &error);
}

- (id)transformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
	NSError *error = nil;
	BOOL success = YES;

	id transformedValue = self.forwardBlock(value, &success, &error);

	if (outerSuccess != NULL) *outerSuccess = success;
	if (outerError != NULL) *outerError = error;

	return transformedValue;
}

@end

@implementation TTReversibleValueTransformer

#pragma mark Lifecycle

- (id)initWithForwardBlock:(TTValueTransformerBlock)forwardBlock reverseBlock:(TTValueTransformerBlock)reverseBlock {
	NSParameterAssert(reverseBlock != nil);
	return [super initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)reverseTransformedValue:(id)value {
	NSError *error = nil;
	BOOL success = YES;

	return self.reverseBlock(value, &success, &error);
}

- (id)reverseTransformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
	NSError *error = nil;
	BOOL success = YES;

	id transformedValue = self.reverseBlock(value, &success, &error);

	if (outerSuccess != NULL) *outerSuccess = success;
	if (outerError != NULL) *outerError = error;

	return transformedValue;
}

@end
