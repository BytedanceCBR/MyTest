//
//  TTWechatContentItem.h
//  Pods
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeWechat;

@interface TTWechatContentItem : NSObject <TTActivityContentItemShareProtocol>

@property (nonatomic, assign) TTShareType shareType;
//Image
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong) UIImage * thumbImage;
//Web
@property (nonatomic, copy) NSString *webPageUrl;
//General
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *videoString;
@property (nonatomic, copy) NSDictionary *extraInfo;

@property (nonatomic, copy) NSDictionary *callbackUserInfo;

@property (nonatomic, copy) NSString *contentTitle;
@property (nonatomic, copy) NSString *activityImageName;

- (instancetype)initWithTitle:(NSString *)title
                         desc:(NSString *)desc
                   webPageUrl:(NSString *)webPageUrl
                   thumbImage:(UIImage *)thumbImage
                    shareType:(TTShareType)shareType;

@end
