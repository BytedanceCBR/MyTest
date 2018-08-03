//
//  NSObject+TTFastCoding.m
//  homework
//
//  Created by panxiang on 14-7-17.
//  Copyright (c) 2014年 panxiang. All rights reserved.
//

#import "NSObject+TTFastCoding.h"
#import <objc/runtime.h>
#import "NSObject+TTAdditions.h"

@implementation NSObject (TTFastCoding)

static BOOL IsPrimitiveType (char first) {
	return (first == _C_INT || first == _C_UINT || first == _C_FLT || first == _C_DBL ||
			first == _C_SEL || first == _C_CHR ||  first == _C_UCHR || first == _C_BOOL ||
			first == _C_LNG_LNG || first == _C_ULNG_LNG || first == _C_CLASS ||
			first == _C_LNG || first == _C_ULNG || first == _C_SHT || first == _C_USHT);
}

+ (void)load
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:[NSObject currentUnixTime]] forKey:@"kTrackTime_load"];

}

/**
 * for subclass
 */

- (void)customDecodePropertiesWithCoder:(NSCoder *)aDoder
{
    
}

- (void)customEncodePropertiesWithCoder:(NSCoder *)aDoder
{
    
}

+ (NSArray *)propertiesToSkipDuringFastCoding {
	return [NSArray array];
}

- (void)encodePropertiesWithCoder:(NSCoder *)coder {
	NSArray *skipKeys = [[self class] propertiesToSkipDuringFastCoding];
	
	unsigned int count = 0;
	objc_property_t *properties = class_copyPropertyList([self class], &count);
	
	for (unsigned int n = 0; n < count; n++) {
		objc_property_t property = properties[n];
		
		const char *name = property_getName(property);
		NSString *oname = [NSString stringWithUTF8String:name];
		
		if ([skipKeys containsObject:oname])
			continue;
		
        char * attributeValue = property_copyAttributeValue(property, "T");
        char type = attributeValue[0];
		
		if (IsPrimitiveType(type) || type == _C_ID) {
			SEL selector = NSSelectorFromString(oname);
			NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
			
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:selector];
			[invocation invokeWithTarget:self]; // invokes the getter
			
			void *returnValue = NULL;
			
			if (type == _C_ID) {
                [coder encodeObject:[self valueForKey:oname] forKey:oname];
			}
			else if (type == _C_INT) {
				returnValue = malloc(sizeof(NSInteger));
				[invocation getReturnValue:returnValue];
				[coder encodeInt:*(int *)returnValue forKey:oname];
			}
			else if (type == _C_UINT) {
				returnValue = malloc(sizeof(unsigned int));
				[invocation getReturnValue:returnValue];
				[coder encodeInt:*(unsigned int *)returnValue forKey:oname];
			}
			else if (type == _C_SHT) {
				returnValue = malloc(sizeof(short));
				[invocation getReturnValue:returnValue];
				[coder encodeInt:*(short *)returnValue forKey:oname];
			}
			else if (type == _C_USHT) {
				returnValue = malloc(sizeof(unsigned short));
				[invocation getReturnValue:returnValue];
				[coder encodeInt:*(unsigned short *)returnValue forKey:oname];
			}
			else if (type == _C_LNG) {
				returnValue = malloc(sizeof(long));
				[invocation getReturnValue:returnValue];
				[coder encodeInt64:*(long *)returnValue forKey:oname];
			}
			else if (type == _C_ULNG) {
				returnValue = malloc(sizeof(unsigned long));
				[invocation getReturnValue:returnValue];
				[coder encodeInt64:*(unsigned long *)returnValue forKey:oname];
			}
			else if (type == _C_LNG_LNG) {
				returnValue = malloc(sizeof(long long));
				[invocation getReturnValue:returnValue];
				[coder encodeInt64:*(long long *)returnValue forKey:oname];
			}
			else if (type == _C_ULNG_LNG) {
				returnValue = malloc(sizeof(unsigned long long));
				[invocation getReturnValue:returnValue];
				[coder encodeInt64:*(unsigned long long *)returnValue forKey:oname];
			}
			else if (type == _C_FLT) {
				returnValue = malloc(sizeof(float));
				[invocation getReturnValue:returnValue];
				[coder encodeFloat:*(float *)returnValue forKey:oname];
			}
			else if (type == _C_DBL) {
				returnValue = malloc(sizeof(double));
				[invocation getReturnValue:returnValue];
				[coder encodeDouble:*(double *)returnValue forKey:oname];
			}
			else if (type == _C_CHR) {
				returnValue = malloc(sizeof(char));
				[invocation getReturnValue:returnValue];
				[coder encodeInt:*(char *)returnValue forKey:oname];
			}
			else if (type == _C_UCHR) {
				returnValue = malloc(sizeof(unsigned char));
				[invocation getReturnValue:returnValue];
				[coder encodeInt:*(unsigned char *)returnValue forKey:oname];
			}
			else if (type == _C_SEL) {
				returnValue = malloc(sizeof(SEL));
				[invocation getReturnValue:returnValue];
				[coder encodeObject:[NSValue valueWithBytes:returnValue objCType:@encode(SEL)]
							 forKey:oname];
			}
			else if (type == _C_CLASS) {
				returnValue = malloc(sizeof(Class));
				[invocation getReturnValue:returnValue];
				[coder encodeObject:[NSValue valueWithBytes:returnValue objCType:@encode(Class)]
							 forKey:oname];
			}
			else if (type == _C_BOOL) {
				returnValue = malloc(sizeof(BOOL));
				[invocation getReturnValue:returnValue];
				[coder encodeBool:*(BOOL *)returnValue forKey:oname];
			}
//            else if (type == _C_STRUCT_E) {
//                [coder encodeInt:(NSInteger)[self valueForKey:oname] forKey:oname];
//			}
			else if (type == _C_CHARPTR) {
				NSLog(@"Encoding and decoding character pointers is currently unsupported.");
			}

			
			if (returnValue)
				free(returnValue);
		}
        else
        {
            [self customEncodePropertiesWithCoder:coder];
        }
        
        free(attributeValue);
        attributeValue = NULL;
	}
    free(properties);
}


- (void)decodePropertiesWithCoder:(NSCoder *)coder {
//    @try {
    objc_property_t *properties = nil;
    unsigned int count = 0;
    properties = class_copyPropertyList([self class], &count);
    
    NSArray *skipKeys = [[self class] propertiesToSkipDuringFastCoding];
    
    for (unsigned int n = 0; n < count; n++) {
        objc_property_t property = properties[n];
        
        const char *name = property_getName(property);
        NSString *oname = [NSString stringWithUTF8String:name];
        
        if ([skipKeys containsObject:oname])
            continue;
        
        NSString *setter = [NSString stringWithFormat:@"set%c%s:", toupper(name[0]), name+1];
        
        char * attributeValue = property_copyAttributeValue(property, "T");
        char type = attributeValue[0];
        
        SEL selector = NSSelectorFromString(setter);
        NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = nil;
        if (signature) {
            invocation = [NSInvocation invocationWithMethodSignature:signature];//signature 为空就会崩溃 ,属性为readOnly的时候signature就是nil
        }
        else
        {
            continue;
        }
        [invocation setSelector:selector];
        
        if (IsPrimitiveType(type)) {
            void *value = NULL;
            
            if (type == _C_INT) {
                value = malloc(sizeof(NSInteger));
                *(int *)value = [coder decodeIntForKey:oname];
            }
            else if (type == _C_UINT) {
                value = malloc(sizeof(unsigned int));
                *(unsigned int *)value = (unsigned int) [coder decodeIntForKey:oname];
            }
            else if (type == _C_SHT) {
                value = malloc(sizeof(short));
                *(short *)value = (short) [coder decodeIntForKey:oname];
            }
            else if (type == _C_USHT) {
                value = malloc(sizeof(unsigned short));
                *(unsigned short *)value = (unsigned short) [coder decodeIntForKey:oname];
            }
            else if (type == _C_LNG) {
                value = malloc(sizeof(long));
                *(long *)value = (long) [coder decodeInt64ForKey:oname];
            }
            else if (type == _C_ULNG) {
                value = malloc(sizeof(unsigned long));
                *(unsigned long *)value = (unsigned long) [coder decodeInt64ForKey:oname];
            }
            else if (type == _C_LNG_LNG) {
                value = malloc(sizeof(long long));
                *(long long *)value = [coder decodeInt64ForKey:oname];
            }
            else if (type == _C_ULNG_LNG) {
                value = malloc(sizeof(unsigned long long));
                *(unsigned long long *)value = (unsigned long long) [coder decodeInt64ForKey:oname];
            }
            else if (type == _C_FLT) {
                value = malloc(sizeof(float));
                *(float *)value = [coder decodeFloatForKey:oname];
            }
            else if (type == _C_DBL) {
                value = malloc(sizeof(double));
                *(double *)value = [coder decodeDoubleForKey:oname];
            }
            else if (type == _C_CHR) {
                value = malloc(sizeof(char));
                *(char *)value = (char) [coder decodeIntForKey:oname];
            }
            else if (type == _C_UCHR) {
                value = malloc(sizeof(unsigned char));
                *(unsigned char *)value = (unsigned char) [coder decodeIntForKey:oname];
            }
            else if (type == _C_SEL) {
                NSValue *ovalue = [coder decodeObjectForKey:oname];
                
                value = malloc(sizeof(SEL));
                [ovalue getValue:value];
            }
            else if (type == _C_CLASS) {
                NSValue *ovalue = [coder decodeObjectForKey:oname];
                
                value = malloc(sizeof(Class));
                [ovalue getValue:value];
            }
            else if (type == _C_BOOL) {
                value = malloc(sizeof(BOOL));
                *(BOOL *)value = [coder decodeBoolForKey:oname];
            }
            //            else if (type == _C_STRUCT_E)
            //            {
            //                [self setValue:[coder decodeIntegerForKey:oname] forKey:oname];
            //            }
            else if (type == _C_CHARPTR) {
                NSLog(@"Encoding and decoding character pointers is currently unsupported.");
            }
            
            if (value) {
                [invocation setArgument:value atIndex:2];
                [invocation invokeWithTarget:self];
                
                free(value);
            }
        }
        else if (type == _C_ID) {
            [self setValue:[coder decodeObjectForKey:oname] forKey:oname];
        }
        else
        {
            [self customDecodePropertiesWithCoder:coder];
        }
        
        free(attributeValue);
        attributeValue = NULL;
    }
    free(properties);
//    }
//    @catch (NSException *exception) {
//        NSLog(@"decodePropertiesWithCoder %@",exception);
//    }
//    @finally {
//        free(properties);
//    }

}


@end
