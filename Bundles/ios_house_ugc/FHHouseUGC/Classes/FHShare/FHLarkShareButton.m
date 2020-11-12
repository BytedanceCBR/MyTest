//
//  FHLarkShareButton.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/12.
//

#import "FHLarkShareButton.h"
#import <LarkOpenShareSDK/LarkApiObject.h>
#import <LarkOpenShareSDK/LarkShareApi.h>
#import <NSDictionary+BTDAdditions.h>
#import <NSString+BTDAdditions.h>
#import <NSURL+BTDAdditions.h>

@interface FHLarkShareButton ()
@property(nonatomic,assign) CGPoint touchBeginPosition;
@property(nonatomic,assign) CGFloat originX;
@property(nonatomic,assign) CGFloat originY;
@end

@implementation FHLarkShareButton

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.touchBeginPosition = [[touches anyObject] locationInView:self];
    self.originX = self.frame.origin.x;
    self.originY = self.frame.origin.y;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    CGPoint currentPosition = [[touches anyObject] locationInView:self];
    CGFloat offsetX = currentPosition.x - self.touchBeginPosition.x;
    CGFloat offsetY = currentPosition.y - self.touchBeginPosition.y;
    CGFloat centerX = self.center.x + offsetX;
    CGFloat centerY = self.center.y + offsetY;
    self.center = CGPointMake(centerX, centerY);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    CGFloat offsetX = self.frame.origin.x - self.originX;
    CGFloat offsetY = self.frame.origin.y - self.originY;
    if(offsetX * offsetX + offsetY * offsetY < 5) {
        [super touchesEnded:touches withEvent:event];
        [self shareToLark];
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

- (void)shareToLark {
    NSString *scheme = self.paramObj.sourceURL.absoluteString ?: @"sslocal://main?select_tab=tab_stream";
    NSString *params = [self.paramObj.userInfo.allInfo btd_jsonStringEncoded] ?: @"";
    
    LarkMediaWebObject *webObejct = [[LarkMediaWebObject alloc] init];
    webObejct.title = @"幸福里";
    webObejct.urlStr = [NSURL btd_URLWithString:@"snssdk1370://fhsharemanager" queryItems:@{@"scheme":scheme,@"params":params}].absoluteString;
    
    LarkSendMessageRequest *request = [[LarkSendMessageRequest alloc] init];
    request.mediaObject = webObejct;
    
    [LarkShareApi sendRequest:request];
}

@end
