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

//上传图片url的接口
+ (NSString *)uploadWithUrlOfImageURL;

+ (NSString *)baseURL;

+ (NSString *)actionCountInfoURL;

//热榜
+ (NSString *)hotBoardUrl;

//https://lf.snssdk.com/client_impr/impr_report/v1/
+ (NSString *)hotBoardClientImprUrl;

@end
