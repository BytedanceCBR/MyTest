//
//  TTAdResPreloadModel.h
//  Article
//
//  Created by yin on 2017/1/13.
//
//

#import <JSONModel/JSONModel.h>
#import <TTAdModule/TTPhotoDetailAdModel.h>

@class TTAdResPreloadDataModel;
@protocol TTAdResPreloadDataModel;

@interface TTAdResPreloadModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* message;
@property (nonatomic, strong)NSString<Optional>* reason;
@property (nonatomic, strong)NSArray<Optional, TTAdResPreloadDataModel>* data;

@end

@protocol TTAdImageModel;
@protocol NSNumber;
@interface TTAdResPreloadDataModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* source_url;
@property (nonatomic, strong)NSString<Optional>* content_type;
@property (nonatomic, strong)NSNumber<Optional>* content_size;
@property (nonatomic, strong)NSMutableArray<Optional, NSNumber>* ad_id;
@property (nonatomic, strong)NSString<Optional>* charset;
@property (nonatomic, strong)NSDictionary<Optional>* preload_data;

//此字段用来判断某个资源在同一个页面是否被成功转发,防止同一资源被重复计算转发次数
@property (nonatomic, strong)NSNumber<Optional>* loadStatus;
//同上 计算match_num时候方式重复计算
@property (nonatomic, strong)NSNumber<Optional>* matchStatus;

@end


