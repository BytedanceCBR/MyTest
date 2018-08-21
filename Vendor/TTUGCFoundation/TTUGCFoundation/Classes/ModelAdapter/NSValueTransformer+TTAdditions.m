//
//  NSValueTransformer+TTAdditions.m
//  TT
//
//  Created by Justin Spahr-Summers on 2012-09-27.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSValueTransformer+TTAdditions.h"
#import "TTValueTransformer.h"

NSString * const TTURLValueTransformerName = @"TTURLValueTransformerName";
NSString * const TTBooleanValueTransformerName = @"TTBooleanValueTransformerName";

@implementation NSValueTransformer (TTAdditions)

#pragma mark Category Loading

+ (void)load {
	@autoreleasepool {
		TTValueTransformer *URLValueTransformer = [TTValueTransformer
			transformerUsingForwardBlock:^ id (NSString *str, BOOL *success, NSError **error) {
				if (str == nil) return nil;

				if (![str isKindOfClass:NSString.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert string to URL", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSString, got: %@.", @""), str],
							TTTransformerInputValueErrorKey : str
						};

						*error = [NSError errorWithDomain:TTTransformerErrorDomain code:TTTransformerErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}

				NSURL *result = [NSURL URLWithString:str];

				if (result == nil) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert string to URL", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Input URL string %@ was malformed", @""), str],
							TTTransformerInputValueErrorKey : str
						};

						*error = [NSError errorWithDomain:TTTransformerErrorDomain code:TTTransformerErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}

				return result;
			}
			reverseBlock:^ id (NSURL *URL, BOOL *success, NSError **error) {
				if (URL == nil) return nil;

				if (![URL isKindOfClass:NSURL.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert URL to string", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSURL, got: %@.", @""), URL],
							TTTransformerInputValueErrorKey : URL
						};

						*error = [NSError errorWithDomain:TTTransformerErrorDomain code:TTTransformerErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}
				return URL.absoluteString;
			}];

		[NSValueTransformer setValueTransformer:URLValueTransformer forName:TTURLValueTransformerName];
		
		TTValueTransformer *booleanValueTransformer = [TTValueTransformer
			transformerUsingReversibleBlock:^ id (NSNumber *boolean, BOOL *success, NSError **error) {
				if (boolean == nil) return nil;

				if (![boolean isKindOfClass:NSNumber.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert number to boolean-backed number or vice-versa", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSNumber, got: %@.", @""), boolean],
							TTTransformerInputValueErrorKey : boolean
						};

						*error = [NSError errorWithDomain:TTTransformerErrorDomain code:TTTransformerErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}
				return (NSNumber *)(boolean.boolValue ? kCFBooleanTrue : kCFBooleanFalse);
			}];

		[NSValueTransformer setValueTransformer:booleanValueTransformer forName:TTBooleanValueTransformerName];
	}
}

#pragma mark Customizable Transformers
+ (NSValueTransformer<TTTransformerProtocol> *)tt_validatingTransformerForClass:(Class)modelClass {
	NSParameterAssert(modelClass != nil);

	return [TTValueTransformer transformerUsingReversibleBlock:^ id (id value, BOOL *success, NSError **error) {
		if (value != nil && ![value isKindOfClass:modelClass]) {
			if (error != NULL) {
				NSDictionary *userInfo = @{
					NSLocalizedDescriptionKey: NSLocalizedString(@"Value did not match expected type", @""),
					NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected %1$@ to be of class %2$@ but got %3$@", @""), value, modelClass, [value class]],
					TTTransformerInputValueErrorKey : value
				};

				*error = [NSError errorWithDomain:TTTransformerErrorDomain code:TTTransformerErrorInvalidInput userInfo:userInfo];
			}
			*success = NO;
			return nil;
		}

		return value;
	}];
}

@end
