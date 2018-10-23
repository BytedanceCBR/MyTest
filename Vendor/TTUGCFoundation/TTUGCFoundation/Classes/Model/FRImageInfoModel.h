//
//  FRImageInfoModel.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/27.
//
//

#import <Foundation/Foundation.h>
#import "FRApiModel.h"
@class TTImageInfosModel;

@interface  TTImageURLInfoModel : NSObject<NSCoding>
@property (strong, nonatomic) NSString *url;
@end

@protocol TTImageURLInfoModel;

@protocol FRImageInfoModel;

@interface FRImageInfoModel : NSObject<NSCoding>

@property (assign, nonatomic) int64_t height;
@property (assign, nonatomic) int64_t width;
@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSArray<TTImageURLInfoModel>* url_list;
@property (assign, nonatomic) FRImageType type;
//@property (assign, nonatomic) NSInteger currentRequestingIndex;

- (instancetype)initWithURL:(NSString *)url;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithTTImageInfosModel:(TTImageInfosModel *)TTImageInfosModel;

- (NSURL *)_cacheKey;

- (NSString *)urlStringAtIndex:(NSUInteger)index;

+ (FRImageInfoModel *)genInfoModelFromStruct:(FRImageUrlStructModel *)model;

+ (NSArray<FRImageInfoModel> *)genInfoModelsForumStructs:(NSArray<FRImageUrlStructModel> *)structs;

+ (FRImageUrlStructModel *)genUserIconStructModelFromInfoModel:(FRImageInfoModel *)infoModel;


@end
