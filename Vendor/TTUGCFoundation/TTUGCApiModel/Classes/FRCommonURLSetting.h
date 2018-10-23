//
//  FRCommonURLSetting.h
//  Article
//
//  Created by 王霖 on 16/1/13.
//
//

#import <Foundation/Foundation.h>

@interface FRCommonURLSetting : NSObject
//转发详情页接口
+(NSString *)ugcCommentRepostDetailURL;

//帖子v3详情页接口
+ (NSString *)ugcThreadDetailV3InfoURL;

+(NSString *)uploadImageURL;

+(NSString *)baseURL;

@end
