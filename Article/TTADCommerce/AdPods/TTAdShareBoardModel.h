//
//  TTAdShareBoardModel.h
//  Article
//
//  Created by yin on 2016/11/11.
//
//

#import <JSONModel/JSONModel.h>
#import "TTPhotoDetailAdModel.h"

typedef NS_ENUM(NSUInteger, TTAdShareDisplayType) {
    TTAdShareDisplayType_Small,
    TTAdShareDisplayType_Large,
    TTAdShareDisplayType_Group,
    TTAdShareDisplayType_Video
};

@class TTAdShareBoardDataModel;
@protocol TTAdShareBoardDataModel;

@interface TTAdShareBoardModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* message;
@property (nonatomic, strong)TTAdShareBoardDataModel<Optional>* data;

@end

@class TTAdShareBoardItemModel;
@protocol TTAdShareBoardItemModel;

@interface TTAdShareBoardDataModel : JSONModel

@property (nonatomic, strong)NSArray<Optional, TTAdShareBoardItemModel>* ad_item;
@property (nonatomic, strong)NSNumber<Optional>* request_after;
@property (nonatomic, strong)NSNumber<Optional>* close_button_switch;
@property (nonatomic, strong)NSNumber<Optional>* close_expire_time;

@property (nonatomic, strong)NSDate<Optional>* requestTime;
@property (nonatomic, strong)NSDate<Optional>* closeShowTime;

- (void)updateDate;

- (void)updateShowCloseTime;

- (void)readShowCloseTime:(TTAdShareBoardModel*)model;

@end

@class TTAdImageModel;
@protocol TTAdImageModel;

@interface TTAdShareBoardItemModel : JSONModel

@property (nonatomic, strong)NSNumber<Optional>* ID;  //创意 下载、电话等
@property (nonatomic, strong)NSString<Optional>* log_extra;
@property (nonatomic, strong)NSArray<Optional>* track_url_list;
@property (nonatomic, strong)NSNumber<Optional>* display_after;
@property (nonatomic, strong)NSNumber<Optional>* expire_seconds;
@property (nonatomic, strong)NSString<Optional>* title;
@property (nonatomic, strong)NSArray<Optional, TTAdImageModel>* image_list;
@property (nonatomic, strong)NSString<Optional>* label;
@property (nonatomic, strong)NSNumber<Optional> * display_type;
@property (nonatomic, strong)NSNumber<Optional> * label_style;
@property (nonatomic, strong)NSString<Optional>* type;
@property (nonatomic, strong)NSNumber<Optional>* predownload;
@property (nonatomic, strong)NSDate<Optional>* startTime;
@property (nonatomic, strong)NSDate<Optional>* endTime;

- (void)updateDate;

- (TTAdShareDisplayType)displayType;

@end


