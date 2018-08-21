//
//  TTAPNsRouting.m
//  Article
//
//  Created by zuopengliu on 21/12/2017.
//

#import "TTAPNsRouting.h"



@interface _TTRountingObject_ : NSObject

@property (nonatomic, assign) BOOL supportReg; /** 是否支持正则表达式 */

@property (nonatomic,   copy) NSString *host;

@property (nonatomic,   copy) id block;

+ (instancetype)rountingWithHost:(NSString *)host supportReg:(BOOL)supports block:(id)block;

@end

@implementation _TTRountingObject_

+ (instancetype)rountingWithHost:(NSString *)host supportReg:(BOOL)supports block:(id)block
{
    return [[self alloc] initWithHost:host supportReg:supports block:block];
}

- (instancetype)init
{
    if ((self = [super init])) {
        _supportReg = NO;
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host supportReg:(BOOL)supports block:(id)block
{
    if ((self = [self init])) {
        _host = host;
        _supportReg = supports;
        _block = [block copy];
    }
    return self;
}

#ifdef DEBUG

- (NSString *)debugDescription
{
    NSMutableString *mutString = [NSMutableString stringWithFormat:@"%@ = {", self];
    [mutString appendFormat:@"\n\tsupportReg = %ld", (long)_supportReg];
    [mutString appendFormat:@"\n\thost = %@", _host];
    [mutString appendFormat:@"\n\tblock = %p", _block];
    [mutString appendString:@"\n}"];
    return [mutString copy];
}

#endif

@end



#pragma mark - TTAPNsRouting

@interface TTAPNsRouting ()

@property (nonatomic, strong) NSMutableArray<_TTRountingObject_ *> *hostRoutings;

@end

@implementation TTAPNsRouting

+ (instancetype)sharedRouting
{
    static TTAPNsRouting *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

+ (void)registerHost:(NSString *)host
          matchBlock:(BOOL (^)(NSDictionary *params))handler
{
    [[self sharedRouting] registerHost:host supportReg:NO matchBlock:handler];
}

+ (void)registerHostPattern:(NSString *)hostPattern
                 matchBlock:(BOOL (^)(NSDictionary *params))handler
{
    [[self sharedRouting] registerHost:hostPattern supportReg:YES matchBlock:handler];
}

- (void)registerHost:(NSString *)host
          supportReg:(BOOL)supports
          matchBlock:(BOOL (^)(NSDictionary *params))handler
{
    if (!host || !handler) return;
    
    _TTRountingObject_ *routing = [_TTRountingObject_ rountingWithHost:host supportReg:supports block:^BOOL(NSDictionary *params) {
        if (handler) return handler(params);
        return NO;
    }];
    
    if (routing) {
        @synchronized(self.hostRoutings) {
            [self.hostRoutings addObject:routing];
        };
    }
}

+ (void)unregisterHost:(NSString *)host
{
    [[self sharedRouting] unregisterHost:host supportReg:NO];
}

+ (void)unregisterHostPattern:(NSString *)hostPattern
{
    [[self sharedRouting] unregisterHost:hostPattern supportReg:YES];
}

- (void)unregisterHost:(NSString *)host
            supportReg:(BOOL)supports
{
    if (!host) return;
    
    NSArray *tmpRountings = [self.hostRoutings copy];
    NSMutableArray *newRountings = [tmpRountings mutableCopy];
    [tmpRountings enumerateObjectsUsingBlock:^(_TTRountingObject_ * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ((!supports && [host isEqualToString:obj.host])) {
            [newRountings removeObject:obj];
        } else if (supports) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:host options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray<NSTextCheckingResult *> *result = [regex matchesInString:obj.host options:0 range:NSMakeRange(0, obj.host.length)];
            if (result.count > 0) {
                [newRountings removeObject:obj];
            } else if (obj.supportReg) {
                NSRegularExpression *rountingRegex = [NSRegularExpression regularExpressionWithPattern:obj.host options:NSRegularExpressionCaseInsensitive error:nil];
                NSArray<NSTextCheckingResult *> *rountingResult = [rountingRegex matchesInString:host options:0 range:NSMakeRange(0, host.length)];
                if (rountingResult.count > 0) [newRountings removeObject:obj];
            }
        } else if (obj.supportReg)  {
            NSRegularExpression *rountingRegex = [NSRegularExpression regularExpressionWithPattern:obj.host options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray<NSTextCheckingResult *> *rountingResult = [rountingRegex matchesInString:host options:0 range:NSMakeRange(0, host.length)];
            if (rountingResult.count > 0) [newRountings removeObject:obj];
        }
    }];
    
    @synchronized(self.hostRoutings) {
        self.hostRoutings = [newRountings mutableCopy];
    };
}

#pragma mark - Setter/Getter

- (NSMutableArray<_TTRountingObject_*> *)hostRoutings
{
    if (!_hostRoutings) {
        _hostRoutings = [NSMutableArray array];
    }
    return _hostRoutings;
}

@end

@implementation TTAPNsRouting (HandlePushMessage)

+ (BOOL)handlePushMsg:(NSDictionary *)params
{
    return [[self sharedRouting] handlePushMsg:params];
}

- (BOOL)handlePushMsg:(NSDictionary *)params
{
    if (!params || params.count == 0) return NO;
    
    NSString *schemeUrl = params[kSSAPNsAlertManagerSchemaKey];
    if (!schemeUrl || ![schemeUrl isKindOfClass:[NSString class]]) return NO;
    
    NSString *apnsHost = [[NSURL URLWithString:schemeUrl] host]; /** 非正表表达式 */
    if (!apnsHost || apnsHost.length == 0) return NO;
    
    NSArray<_TTRountingObject_ *> *tmpMapper = [self.hostRoutings copy];
    __block BOOL handled = NO;
    [tmpMapper enumerateObjectsUsingBlock:^(_TTRountingObject_ * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([TTAPNsRouting _isMatchHost:apnsHost rounting:obj]) {
            BOOL (^block)(NSDictionary *) = obj.block;
            if (block && block(params)) {
                handled = YES;
            }
        }
    }];
    return handled;
}

+ (BOOL)_isMatchHost:(NSString *)host rounting:(_TTRountingObject_ *)routing
{
    if (!host || !routing || !routing.host) return NO;
    
    if (!routing.supportReg && [host isEqualToString:routing.host]) {
        return YES;
    } else if (routing.supportReg)  {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:routing.host options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:host options:0 range:NSMakeRange(0, host.length)];
        if (result.count > 0) return YES;
    }
    return NO;
}

@end



@implementation NSDictionary (APNsPushSchemeURL)

- (NSURL *)apns_schemeURL
{
    NSString *schemeUrl = self[kSSAPNsAlertManagerSchemaKey];
    if (!schemeUrl || ![schemeUrl isKindOfClass:[NSString class]]) return nil;
    return [NSURL URLWithString:schemeUrl];
}

@end
