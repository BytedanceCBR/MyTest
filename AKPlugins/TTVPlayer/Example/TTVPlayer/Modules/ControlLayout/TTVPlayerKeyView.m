//
//  TTVPlayerKeyView.m
//  Article
//
//  Created by panxiang on 2018/11/28.
//

#import "TTVPlayerKeyView.h"

@interface TTVPlayerKeyView ()
@property (nonatomic, strong) NSMapTable *viewMap;
@end

@implementation TTVPlayerKeyView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewMap = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableWeakMemory];
    }
    return self;
}

- (UIView *)viewForViewKey:(NSString *)key {
    UIView *ret = [self.viewMap objectForKey:key];
    if (![ret isKindOfClass:[UIView class]]) {
        return nil;
    }
    return ret;
}

- (void)didAddSubview:(UIView *)subview {
    if (subview.ttvPlayerLayoutViewKey) {
        [self.viewMap setObject:subview forKey:subview.ttvPlayerLayoutViewKey];
    }
}

- (void)willRemoveSubview:(UIView *)subview {
    if (subview.ttvPlayerLayoutViewKey) {
        [self.viewMap removeObjectForKey:subview.ttvPlayerLayoutViewKey];
    }
}
@end
