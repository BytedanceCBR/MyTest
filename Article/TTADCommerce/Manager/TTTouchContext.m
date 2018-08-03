//
//  TTTouchContext.m
//  Article
//
//  Created by carl on 2017/3/2.
//
//

#import "TTTouchContext.h"

@implementation TTTouchContext

- (instancetype)initWithTargetView:(UIView *)targetView {
    if (self) {
        self.targetView = targetView;
        self.touchPoint = targetView.center;
    }
    return self;
}

- (instancetype)toView:(UIView *)view {
    if (!self.targetView) {
        return nil;
    }
    if (![view isKindOfClass:[UIView class]]) {
        return nil;
    }
    CGPoint newPoint = [view convertPoint:self.touchPoint fromView:self.targetView];
    TTTouchContext *newContext = [TTTouchContext new];
    newContext.targetView = view;
    newContext.touchPoint = newPoint;
    return newContext;
}

- (NSDictionary *)touchInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setValue:@(self.touchPoint.x) forKey:@"click_x"];
    [dict setValue:@(self.touchPoint.y) forKey:@"click_y"];
    return dict;
}

+ (NSString *)format2JSON:(NSDictionary *)dict {
    if (![NSJSONSerialization isValidJSONObject:dict]) {
        return nil;
    }
    NSError *jsonSeria;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonSeria];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (jsonSeria) {
        LOGE(@"%s %@", __PRETTY_FUNCTION__, jsonSeria);
    }
    return json;
}

@end
