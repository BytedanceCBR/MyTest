//
//  TTUGCRichTextPodBridge.h
//  TTUGCFoundation
//
//  Created by SongChai on 2018/8/1.
//

#import <Foundation/Foundation.h>

/*
 * 这个protocol必须实现对应的IMP，参考Example工程。
 */
@protocol TTUGCRichTextPodBridgeProtocol <NSObject>

/*
 * 必须实现。
 * 该方法是在考虑日夜间模式的情况下，将imageName映射成image，若不实现，则所有有富文本🔗之类的都会有问题。
 */
+ (UIImage *)themedImageNamed:(NSString *)imageName;

/*
 * 埋点方法的实现。
 */
+ (void)eventV3:(NSString *)event params:(NSDictionary *)params;

/*
 * 向服务端请求emoji头条表情的排序。
 * completeBlock中的参数是排序的数组，@[@(1),@(2)]这种格式。
 */
+ (void)requestUpdateEmojiConfig:(void(^)(NSArray *, NSDictionary *, NSDictionary *))completeBlock;

@end

@interface TTUGCRichTextPodBridge : NSObject<TTUGCRichTextPodBridgeProtocol>

@property (nonatomic, class, strong) Class<TTUGCRichTextPodBridgeProtocol> bridgeIMP;

@end
