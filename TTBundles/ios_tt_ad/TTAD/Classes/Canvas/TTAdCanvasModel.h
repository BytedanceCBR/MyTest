//
//  TTAdCanvasModel.h
//  Article
//
//  Created by yin on 2016/12/13.
//
//

#import <JSONModel/JSONModel.h>
#import "TTPhotoDetailAdModel.h"

/**
    预加载资源 元信息
 */

@class TTAdCanvasDataModel;

@interface TTAdCanvasModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* message;
@property (nonatomic, strong)TTAdCanvasDataModel* data;

@end

@class    TTAdCanvasProjectModel;
@protocol TTAdCanvasProjectModel;

@interface TTAdCanvasDataModel : JSONModel

@property (nonatomic, strong)NSNumber<Optional>* request_after;
@property (nonatomic, strong)NSNumber<Optional>* predownload;
@property (nonatomic, strong)NSArray<Optional, TTAdCanvasProjectModel>* ad_projects;
@property (nonatomic, strong)NSDate<Optional>* requestTime;

- (void)updateReqeustDate;

@end

@class TTAdCanvasResourceModel;

@protocol NSString;
/**
 沉浸式广告 创意模型，标识广告的所有数据
 */
@interface TTAdCanvasProjectModel : JSONModel

@property (nonatomic, strong)NSArray<NSNumber *><Optional>* ad_ids;
@property (nonatomic, strong)TTAdCanvasResourceModel <Optional>* resource;
@property (nonatomic, assign)NSInteger  end_time;                               //广告资源过期 时间戳
@property (nonatomic, strong)NSDate<Optional>* clearTime;                       //后台到前台,清除缓存时间
- (void)updateClearTime;

@end

@class TTAdImageModel;
@protocol TTAdImageModel;
@class TTAdCanvasResVideoModel;
@protocol TTAdCanvasResVideoModel;

@interface TTAdCanvasResourceModel : JSONModel

@property (nonatomic, strong) NSArray<NSDictionary *><Optional> *image;
@property (nonatomic, strong) NSArray<NSDictionary *><Optional> *video;
@property (nonatomic, strong) NSArray<NSString *><Optional, NSString> *json;                 //沉浸式布局文件，required
@property (nonatomic, strong) NSArray<NSString *><Optional, NSString> *rootViewColor;
@property (nonatomic, strong) NSArray<NSNumber *><Optional> *anim_style; // 0 无动画 1 move top 2 scale
@property (nonatomic, strong) NSArray<NSNumber *><Optional> *hasCreatedata; // 0 默认值，无创意联动，1，有创意联动

- (NSString *)rootViweColorString;
- (NSString *)jsonString;
- (NSNumber *)animationStyle;
- (BOOL)hasCreateFeedData;

@end


@protocol NSString;
@interface TTAdCanvasResVideoModel : JSONModel

@property (nonatomic, strong)NSArray <Optional, NSString>* video_url_list;
@property (nonatomic, strong)NSString<Optional>* video_density;
@property (nonatomic, strong)NSString<Optional>* video_id;
@property (nonatomic, strong)NSNumber<Optional>* voice_switch;
@property (nonatomic, strong)NSNumber<Optional>* video_group_id;

@end
