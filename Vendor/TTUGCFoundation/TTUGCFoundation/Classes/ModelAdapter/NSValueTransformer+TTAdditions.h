//
//  NSValueTransformer+TTAdditions.h
//  TT
//
//  Created by Justin Spahr-Summers on 2012-09-27.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TTValueTransformer.h"

extern NSString * const TTURLValueTransformerName;
extern NSString * const TTBooleanValueTransformerName;

@interface NSValueTransformer (TTAdditions)

+ (NSValueTransformer<TTTransformerProtocol> *)tt_validatingTransformerForClass:(Class)modelClass;

@end
