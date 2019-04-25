//
//  TTQQFriendContentItem.h
//  Pods
//
//  Created by 张 延晋 on 16/06/03.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeQQFriend;

@interface TTQQFriendContentItem : NSObject <TTActivityContentItemShareProtocol>

@property (nonatomic, assign) TTShareType shareType;

//Image
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *webPageUrl;
@property (nonatomic, strong) UIImage *thumbImage;
//General
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSDictionary *callbackUserInfo;

@property (nonatomic, copy) NSString *contentTitle;
@property (nonatomic, copy) NSString *activityImageName;

- (instancetype)initWithTitle:(NSString *)title
                         desc:(NSString *)desc
                   webPageUrl:(NSString *)webPageUr
                   thumbImage:(UIImage *)thumbImage
                     imageUrl:(NSString *)imageUrl
                     shareTye:(TTShareType)shareType;

@end
