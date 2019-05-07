//
//  TTVPlayer+Part.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/1.
//

#import "TTVPlayer+Part.h"
#import <objc/runtime.h>

@interface TTVPlayer (Part)
@property (nonatomic, strong) TTVPlayerPartManager * partManager;
@end

@implementation TTVPlayer (Part)

- (TTVPlayerPartManager *)createPartManager {
    self.partManager = [[TTVPlayerPartManager alloc] init];
    return self.partManager;
}
- (TTVPlayerPartManager *)partManager {
    return objc_getAssociatedObject(self, @selector(partManager));
}
- (void)setPartManager:(TTVPlayerPartManager *)partManager {
    objc_setAssociatedObject(self, @selector(partManager), partManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - <TTVPartManagerProtocol>
- (void)addPart:(NSObject<TTVPlayerPartProtocol> *)part {
    [self.partManager addPart:part];
}
- (void)removePart:(NSObject<TTVPlayerPartProtocol> *)part {
    [self.partManager removePart:part];
}
- (void)addPartFromConfigForKey:(TTVPlayerPartKey)key {
    [self.partManager addPartFromConfigForKey:key];
}
- (void)removePartForKey:(TTVPlayerPartKey)key {
    [self.partManager removePartForKey:key];
}
- (void)removeAllParts {
    [self.partManager removeAllParts];
}
- (NSArray<NSObject<TTVPlayerPartProtocol>*> *)allParts {
    return [self.partManager allParts];
}
- (NSObject<TTVPlayerPartProtocol> *)partForKey:(TTVPlayerPartKey)key {
    return [self.partManager partForKey:key];
}

@end
