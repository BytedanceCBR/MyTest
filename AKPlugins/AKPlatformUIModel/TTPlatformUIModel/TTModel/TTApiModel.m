#import "TTApiModel.h"
#import <objc/runtime.h>

@implementation TTApi
- (NSArray *) classPropertyList:(Class)aClass{
    NSMutableArray *propertyList = [[NSMutableArray alloc] initWithCapacity:10];    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertyCount);
    for (int i=0; i<propertyCount; i++) {
        objc_property_t property = properties[i];
        const char *attrs = property_getName(property);
        NSString* propertyAttributes = [NSString stringWithUTF8String:attrs];
        [propertyList addObject:propertyAttributes];
    }
    return propertyList;
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName{
    return !kIsCheckProperties;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int countOfProperties;
    objc_property_t *properties = class_copyPropertyList(self.class, &countOfProperties);
    
    if (!properties) return;
    
    for (unsigned int i = 0; i < countOfProperties; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id value = [self valueForKey:propertyName];
        if ([value conformsToProtocol:NSProtocolFromString(@"NSCoding")]){
            value = [self valueForKey:propertyName];
        }
        [aCoder encodeObject:value forKey:propertyName];
    }
    free(properties);
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    id object = [[[self class] alloc] init];
    
    unsigned int countOfProperties;
    objc_property_t *properties = class_copyPropertyList(self.class, &countOfProperties);
    if (!properties) return object;
    
    for (unsigned int i = 0; i < countOfProperties; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id value = [aDecoder decodeObjectForKey:propertyName];
        if (value) {
            [object setValue:value forKey:propertyName];
        }
    }
    free(properties);
    
    return object;
}



- (NSString *)description{
    NSMutableString *logString = [[NSMutableString alloc] initWithCapacity:100];
    [logString appendString:[NSString stringWithFormat:@"class %@ start\n\n", NSStringFromClass([self class])]];
    NSArray *selfClassPropertyList = [self classPropertyList:[self class]];
    for (int i = 0; i < selfClassPropertyList.count; i++) {
        [logString appendString:[NSString stringWithFormat:@"........%@:    %@\n", selfClassPropertyList[i],  [[self valueForKey:selfClassPropertyList[i]] description]  ]];
    }
    [logString appendString:[NSString stringWithFormat:@"class %@ end\n\n", NSStringFromClass([self class])]];
    return logString;
}


@end

@implementation ForumFeed

@end


