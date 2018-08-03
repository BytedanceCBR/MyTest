//
//  SSRobust.m
//  Article
//
//  Created by SunJiangting on 15-3-16.
//
//

#import "SSRobust.h"

@interface SSInvocationProtection : NSObject
- (id)receivedUnrecognizedSelector;
@end

@implementation SSInvocationProtection

- (id)receivedUnrecognizedSelector {
    return nil;
}

@end

@interface SSShieldDelegate : NSObject <SSShieldDelegate>
+ (instancetype)sharedShieldDelegate;
@end

@implementation SSShieldDelegate

static SSShieldDelegate *_shieldDelegate;
+ (instancetype)sharedShieldDelegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shieldDelegate = [[self alloc] init];
    });
    return _shieldDelegate;
}

- (id)applyShieldWithDictionary:(NSDictionary *)originalData {
    if (![originalData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:originalData.count];
    [originalData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id shield = SSConvertToRobustObject(obj, self) ?: obj;
        [dictionary setValue:shield forKey:key];
    }];
    return [originalData isKindOfClass:[NSMutableDictionary class]] ? dictionary:[dictionary copy];
}

- (NSDictionary *)reversedDictionaryFromShield:(NSDictionary *)shieldObject {
    if (![shieldObject isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[shieldObject count]];
    [shieldObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id shield = SSGetContentFromRobustObject(obj) ?: obj;
        [dictionary setValue:shield forKey:key];
    }];
    return [shieldObject isKindOfClass:[NSMutableDictionary class]] ? dictionary : [dictionary copy];
}

- (id)applyShieldWithArray:(NSArray *)originalData {
    if (![originalData isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:originalData.count];
    [originalData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSObject *shield = SSConvertToRobustObject(obj, self) ?: obj;
        if (shield) {
            [array addObject:shield];   
        }
    }];
    return [originalData isKindOfClass:[NSMutableArray class]]?array:[array copy];
}

- (NSArray *)reversedArrayFromShield:(NSArray *)shieldObject {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[shieldObject count]];
    [shieldObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:SSGetContentFromRobustObject(obj)?:obj];
    }];
    return [shieldObject isKindOfClass:[NSMutableArray class]] ? array : [array copy];
}

- (id)applyShieldWithObject:(NSObject/*AnyObject*/ *)anyObject {
    return anyObject;
}

- (NSObject *)reversedObjectFromShield:(NSObject *)shieldObject {
    return shieldObject;
}

@end

@interface SSShield : NSProxy

@property(nonatomic, strong) NSObject *object;
@property(nonatomic, weak) id <SSShieldDelegate> shieldDelegate;

@end


@implementation SSShield

- (void)dealloc {
    
}

- (instancetype)initWithObject:(NSObject *)object delegate:(id<SSShieldDelegate>)delegate{
    self.object = object;
    self.shieldDelegate = delegate;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = [self.object methodSignatureForSelector:sel];
    if (sel == @selector(hash)) {
        NSLog(@"%@", NSStringFromSelector(sel));   
    }
    if (!signature) {
        signature = [SSInvocationProtection instanceMethodSignatureForSelector:@selector(receivedUnrecognizedSelector)];
        NSLog(@"%@-UnrecognizedSelector:%@", self.object.class, NSStringFromSelector(sel));
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.object.class instancesRespondToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.object];
    } else {
        NSLog(@"%@", NSStringFromSelector(invocation.selector));
    }
}

- (id)copy {
    id newContent = SSGetContentFromRobustObject(self);
    if ([newContent conformsToProtocol:NSProtocolFromString(@"NSCopying")]) {
        newContent = [newContent copy];
    }
    return newContent;
//    return SSConvertToRobustObject(newContent, self.shieldDelegate);
}

- (id)objectForKey:(id)key {
    if ([self.object respondsToSelector:@selector(objectForKey:)]) {
        if ([key respondsToSelector:@selector(realClass)]) {
            key = SSGetContentFromRobustObject(key);
        }
        return SSGetContentFromRobustObject([self.object performSelector:@selector(objectForKey:) withObject:key]);
    }
    return nil;
}

- (id)valueForKey:(id)key {
    if ([self.object respondsToSelector:@selector(valueForKey:)]) {
        if ([key respondsToSelector:@selector(realClass)]) {
            key = SSGetContentFromRobustObject(key);
        }
        return [self.object performSelector:@selector(valueForKey:) withObject:key];
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(realClass)) {
        return YES;
    }
    return [self.object respondsToSelector:aSelector];
}


- (id)mutableCopy {
    id newContent = SSGetContentFromRobustObject(self);
    if ([self.object conformsToProtocol:NSProtocolFromString(@"NSMutableCopying")]) {
        newContent = [newContent mutableCopy];
    }
    return newContent;
//    return SSConvertToRobustObject(newContent, self.shieldDelegate);
}

- (Class)class {
    return self.object.class;
}

- (NSString *)description {
    return self.object.description;
}

- (NSString *)debugDescription {
    return self.object.debugDescription;
}

- (Class)realClass {
    return SSShield.class;
}

- (BOOL)isEqual:(id)object {
    NSObject *originalObject = SSGetContentFromRobustObject(self.object);
    NSObject *compareObject = SSGetContentFromRobustObject(object);
    return [originalObject isEqual:compareObject];
}

- (Class)superclass {
    return self.object.superclass;
}

- (NSUInteger)hash {
    NSObject *originalObject = SSGetContentFromRobustObject(self.object);
    return originalObject.hash;
}

- (BOOL)isProxy {
    return YES;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.object conformsToProtocol:aProtocol];
}

@end

static BOOL _openRobustObject = NO;

void SSOpenRobustObject() {
    @synchronized(SSShield.class) {
        if (!_openRobustObject) {
            _openRobustObject = YES;
        }
    }
}

void SSCloseRobustObject() {
    @synchronized(SSShield.class) {
        if (_openRobustObject) {
            _openRobustObject = NO;
        }
    }
}

BOOL SSIsRobustObject() {
    @synchronized(SSShield.class) {
        return _openRobustObject;
    }
}

extern id SSConvertToRobustObject(id/*NSObject*/ object, id<SSShieldDelegate> delegate) {
    if (!SSIsRobustObject() || [object respondsToSelector:@selector(realClass)] || !object) {
        return object;
    }
    delegate = delegate?:[SSShieldDelegate sharedShieldDelegate];
    id result = object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        if ([delegate respondsToSelector:@selector(applyShieldWithDictionary:)]) {
            result = [delegate applyShieldWithDictionary:object];
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        if ([delegate respondsToSelector:@selector(applyShieldWithArray:)]) {
            result = [delegate applyShieldWithArray:object];
        }
    } else {
        if ([delegate respondsToSelector:@selector(applyShieldWithObject:)]) {
            result = [delegate applyShieldWithObject:object];
        }
    }
    return [[SSShield alloc] initWithObject:result delegate:delegate];
}

extern id SSGetContentFromRobustObject(id shieldObject) {
    if (![shieldObject respondsToSelector:@selector(realClass)]) {
        return shieldObject;
    }
    SSShield *shield = (SSShield *)shieldObject;
    id<SSShieldDelegate> delegate = shield.shieldDelegate;
    if (!delegate) {
        delegate = [SSShieldDelegate sharedShieldDelegate];
    }
    id object = shield.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        if ([delegate respondsToSelector:@selector(reversedDictionaryFromShield:)]) {
            object = [delegate reversedDictionaryFromShield:object];
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        if ([delegate respondsToSelector:@selector(reversedArrayFromShield:)]) {
            object = [delegate reversedArrayFromShield:object];
        }
    } else {
        if ([delegate respondsToSelector:@selector(reversedObjectFromShield:)]) {
            object = [delegate reversedObjectFromShield:object];
        }
    }
    return object;
}

#import <objc/runtime.h>

@implementation SSProperty

- (instancetype)initWithObjcProperty:(objc_property_t)property {
    if (!property) {
        return nil;
    }
    self = [super init];
    if (self) {
        unsigned int propertyCount = 0;
        NSString *type = nil;
        objc_property_attribute_t *property_attribute_t = property_copyAttributeList(property, &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            objc_property_attribute_t attribute_t = property_attribute_t[i];
            size_t len = strlen(attribute_t.name);
            if (len == 0) {
                continue;
            }
            if (attribute_t.name[0] == 'T') {
                type = [NSString stringWithUTF8String:attribute_t.value];
            }
            if (attribute_t.name[0] == '&') {
                _policy |= SSPropertyPolicyRetain;
            }
            if (attribute_t.name[0] == 'C') {
                _policy |= SSPropertyPolicyCopy;
            }
            if (attribute_t.name[0] == 'N') {
                _policy |= SSPropertyPolicyNonatomic;
            }
            if (attribute_t.name[0] == 'R') {
                _readonly = YES;
            }
        }
        if (property_attribute_t) {
            free(property_attribute_t);
        }
        NSMutableString *tempType = [type mutableCopy];
        if ([tempType hasPrefix:@"@"]) {
            // @类型的变量
            [tempType deleteCharactersInRange:NSMakeRange(0, 1)];
            [tempType replaceOccurrencesOfString:@"\"" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, tempType.length)];
            _type = NSClassFromString(tempType);
        }
        
        _name = [[NSString stringWithUTF8String:property_getName(property)] copy];
        if (!(self.policy & SSPropertyPolicyNonatomic)) {
            _policy |= SSPropertyPolicyAtomic;
        }
        if (!(self.policy & SSPropertyPolicyRetain) && !(self.policy & SSPropertyPolicyCopy)) {
            _policy |= SSPropertyPolicyAssign;
        }
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [@"@property(" mutableCopy];
    if (self.policy & SSPropertyPolicyNonatomic) {
        [description appendString:@"nonatomic"];
    } else {
        [description appendString:@"atomic"];
    }
    if (self.policy & SSPropertyPolicyRetain) {
        [description appendString:@", strong"];
    } else if (self.policy & SSPropertyPolicyCopy) {
        [description appendString:@", copy"];
    } else {
        [description appendString:@", assign"];
    }
    if (self.readonly) {
        [description appendString:@", readonly"];
    }
    [description appendFormat:@") %@ *%@;", self.type, self.name];
    return [description copy];
}
@end

void _SSClassGetProperities(Class class, NSMutableDictionary *mutableDictionary);

extern SSProperty * SSGetPropertyFromClass(Class pClass, NSString *propertyName) {
    if (!pClass) {
        return nil;
    }
    NSUInteger location = [propertyName rangeOfString:@"."].location;
    if (location != NSNotFound) {
        NSString *realPropertyName = [propertyName substringToIndex:location];
        NSString *restKeyPath = [propertyName substringFromIndex:(location + 1)];
        // 如果有keypath的情况，先找到.之前的Class。然后找到property
        SSProperty *property = SSGetPropertyFromClass(pClass, realPropertyName);
        if (property) {
            return SSGetPropertyFromClass(property.type, restKeyPath);
        }
    } else {
        objc_property_t objcProperty = class_getProperty(pClass, [propertyName UTF8String]);
        if (objcProperty) {
            SSProperty *property = [[SSProperty alloc] initWithObjcProperty:objcProperty];
            return property;
        }
    }
    return nil;
}

NSDictionary *SSGetPropertiesFromClass(Class pClass) {
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:5];
    _SSClassGetProperities(pClass, properties);
    return [properties copy];
}

void _SSClassGetProperities(Class class, NSMutableDictionary *mutableDictionary) {
    if (!class) {
        return;
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        SSProperty *p = [[SSProperty alloc] initWithObjcProperty:property];
        if (propertyName) {
            [mutableDictionary setValue:p forKey:propertyName];
        }
    }
    free(properties);
    _SSClassGetProperities(class_getSuperclass(class), mutableDictionary);
}

extern BOOL TTClassIsSubClassOfClass(Class _class, Class parentClass) {
    if (!parentClass || !_class) {
        return NO;
    }
    while (_class && _class != parentClass) {
        _class = class_getSuperclass(_class);
    }
    return !!(_class);
}
