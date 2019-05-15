//
//  TTResourceModel.h
//  Article
//
//  Created by carl on 2017/5/24.
//
//

#import <JSONModel/JSONModel.h>

@protocol TTAdResoureModel <NSObject>

@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *uri;

@optional
- (NSArray<NSString *> *)group_urls;
- (NSString *)url;
@end


/**
 A media type is composed of a type, a subtype, and optional parameters
 example: text/html; charset=UTF-8
 syntax: top-level type name / subtype name [; parameters]
 RCF6838: https://tools.ietf.org/html/rfc6838
 here we use: top-level type name, application, image, text, video
 example: text/html video/mp4 application/json image/png image/webp
 */
@interface TTAdResourceModel : JSONModel <TTAdResoureModel>

@property (nonatomic, copy)     NSString *contentType;
@property (nonatomic, assign)   NSUInteger contentSize;
@property (nonatomic, copy)     NSString *uri;
@property (nonatomic, copy)     NSString *charset;
@property (nonatomic, copy)     NSDictionary *resource;

- (NSArray<NSString *> *)video_urls;
@end


