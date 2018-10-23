//
//  SSImageInfosModel.h
//  Article
//
//  Created by Zhang Leonardo on 12-12-5.
//
//
/*
 {
 url: "xxxx.jpg",
    header: {
    Referer: "xxxx",
    User-Agent: "xxxx"
    }
 },
 {
    url: "xxxx"
 }

 */
#import <Foundation/Foundation.h>

#define SSImageInfosModelURL @"url"
#define SSImageInfosModelHeader @"header"

#define kSSImageURIKey @"uri"
#define kSSImageURLListKey @"url_list"
#define kSSImageWidthKey @"width"
#define kSSImageHeightKey @"height"

@interface SSImageInfosModel : NSObject<NSCoding>

@property(nonatomic, retain)NSString * URI;
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)CGFloat height;
@property(nonatomic, retain)NSArray * urlWithHeader;

//将URL 和 header 转换为没有 width 和 height（或者没有header）的Model，其中URI为URL
- (id)initWithURL:(NSString *)URL withHeader:(NSDictionary *)header;
- (id)initWithURL:(NSString *)URL;

- (id)initWithURL:(NSString *)URL withHeader:(NSDictionary *)header withWidth:(CGFloat)w withHeight:(CGFloat)h withURI:(NSString *)URI;
- (id)initWithURLAndHeader:(NSArray *)URLWithHeader withWidth:(CGFloat)w withHeight:(CGFloat)h withURI:(NSString *)URI;

+ (BOOL)isImageInfosModel:(SSImageInfosModel *)model1 equalesToModel:(SSImageInfosModel *)model2;

@end
