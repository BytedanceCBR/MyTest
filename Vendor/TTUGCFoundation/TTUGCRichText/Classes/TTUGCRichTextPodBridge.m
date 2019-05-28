//
//  TTUGCRichTextPodBridge.m
//  TTUGCFoundation
//
//  Created by SongChai on 2018/8/1.
//

#import "TTUGCRichTextPodBridge.h"

@implementation TTUGCRichTextPodBridge

static Class<TTUGCRichTextPodBridgeProtocol> _bridgeIMP;

+ (Class<TTUGCRichTextPodBridgeProtocol>)bridgeIMP {
    return _bridgeIMP;
}

+ (void)setBridgeIMP:(Class<TTUGCRichTextPodBridgeProtocol>)bridgeIMP {
    _bridgeIMP = bridgeIMP;
}

+ (UIImage *)themedImageNamed:(NSString *)imageName {
    if ([_bridgeIMP respondsToSelector:@selector(themedImageNamed:)]) {
        return [_bridgeIMP themedImageNamed:imageName];
    }
    return [UIImage imageNamed:imageName];
}

+ (void)eventV3:(NSString *)event params:(NSDictionary *)params {
    if ([_bridgeIMP respondsToSelector:@selector(eventV3:params:)]) {
        [_bridgeIMP eventV3:event params:params];
    }
}

+ (void)requestUpdateEmojiConfig:(void (^)(NSArray *, NSDictionary *, NSDictionary *))completeBlock {
    if ([_bridgeIMP respondsToSelector:@selector(requestUpdateEmojiConfig:)]) {
        [_bridgeIMP requestUpdateEmojiConfig:completeBlock];
    }
}

@end
