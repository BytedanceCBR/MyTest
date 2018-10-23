//
//  TTVVideoInformationResponse+TTVComputedProperties.m
//  Article
//
//  Created by pei yun on 2017/6/8.
//
//

#import "TTVVideoInformationResponse+TTVComputedProperties.h"
#import <objc/runtime.h>
#import "TTVDetailCarCard.h"
#import <Mantle/Mantle.h>
#import "NSArray+BlocksKit.h"

@implementation TTVVideoInformationResponse (TTVComputedProperties)

- (NSDictionary *)orderedInfoDict
{
    NSDictionary *dict = objc_getAssociatedObject(self, @selector(orderedInfoDict));
    if (!dict) {
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.orderedInfoArray.count];
        for (NSDictionary *jsonDict in self.orderedInfoArray) {
            if (jsonDict[@"name"]) {
                if (jsonDict[@"ad_data"]) {
                   [mutableDictionary setValue:jsonDict[@"ad_data"] forKey:jsonDict[@"name"]];
                } else if (jsonDict[@"data"]) {
                    [mutableDictionary setValue:jsonDict[@"data"] forKey:jsonDict[@"name"]];
                }
            }
        }
        dict = [mutableDictionary copy];
        objc_setAssociatedObject(self, @selector(orderedInfoDict), dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (id<TTVArticleProtocol>)articleMiddleman
{
   return objc_getAssociatedObject(self, @selector(articleMiddleman));
}

- (void)setArticleMiddleman:(id<TTVArticleProtocol>)articleMiddleman
{
   objc_setAssociatedObject(self, @selector(articleMiddleman), articleMiddleman, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)ttv_requestTime
{
   return [objc_getAssociatedObject(self, @selector(ttv_requestTime)) doubleValue];
}

- (void)setTtv_requestTime:(NSTimeInterval)ttv_requestTime
{
   objc_setAssociatedObject(self, @selector(ttv_requestTime), @(ttv_requestTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<TTVDetailCarCard *> *)carCardArray
{
    NSArray *result = objc_getAssociatedObject(self, _cmd);
    if (!result) {
        result = [MTLJSONAdapter modelsOfClass:[TTVDetailCarCard class] fromJSONArray:self.orderedInfoDict[@"cards"] error:nil];
        result = [result bk_select:^BOOL(TTVDetailCarCard *obj) {
            return obj.card_type == 1;
        }];
        objc_setAssociatedObject(self, _cmd, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

@end
