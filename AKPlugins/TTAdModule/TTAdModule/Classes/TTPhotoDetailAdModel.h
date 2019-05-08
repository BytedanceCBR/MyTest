//
//  TTPhotoDetailAdModel.h
//  Article
//
//  Created by yin on 16/8/1.
//
//

#import <JSONModel/JSONModel.h>

typedef enum TTPhotoDetailAdActionType
{
    TTPhotoDetailAdActionType_Web,
    TTPhotoDetailAdActionType_Action,
    TTPhotoDetailAdActionType_App,
    TTPhotoDetailAdActionType_Form,
    TTPhotoDetailAdActionType_Counsel
    
}TTPhotoDetailAdActionType;



@class TTPhotoDetailAdImageRecomModel;
@interface TTPhotoDetailAdModel : JSONModel

@property (nonatomic, strong)TTPhotoDetailAdImageRecomModel<Optional>* image_recom;
@property (nonatomic, strong)NSNumber<Optional>* is_preview;

@end




@class TTAdImageModel;
@protocol TTAdImageModel;

@interface TTPhotoDetailAdImageRecomModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* log_extra;
@property (nonatomic, strong)NSString<Optional>* track_url;
@property (nonatomic, strong)NSString<Optional>* label;
@property (nonatomic, strong)NSString<Optional>* web_title;
@property (nonatomic, strong)NSString<Optional>* web_url;
@property (nonatomic, strong)NSArray<Optional>* track_url_list;
@property (nonatomic, strong)NSString<Optional>* ID;
@property (nonatomic, strong)NSString<Optional>* type;
@property (nonatomic, strong)TTAdImageModel<Optional>* image;
@property (nonatomic, strong)NSString<Optional>* source;

@property (nonatomic, strong)NSString<Optional> *title;
@property (nonatomic, strong)NSString<Optional> *open_url;
@property (nonatomic, strong)NSArray<Optional,TTAdImageModel> *image_list;
@property (nonatomic, strong)NSNumber<Optional> *display_type;
@property (nonatomic, strong)NSString<Optional> *app_name;
@property (nonatomic, strong)NSString<Optional> *package;
@property (nonatomic, strong)NSString<Optional> *appleid;
@property (nonatomic, strong)NSString<Optional> *button_text;
@property (nonatomic, strong)NSString<Optional> *button_icon;
@property (nonatomic, strong)NSString<Optional> *phone_number;
@property (nonatomic, strong)NSNumber<Optional> *dial_action_type;
@property (nonatomic, strong)NSString<Optional> *ipa_url;
@property (nonatomic, strong)NSString<Optional> *download_url;
@property (nonatomic, strong)NSArray<Optional>  *click_track_url_list;
@property (nonatomic, strong)NSNumber<Optional> *hide_if_exists;

//下载app前的判断逻辑
@property (nonatomic, strong)NSString<Optional> *appURL;
@property (nonatomic, strong)NSString<Optional> *tabURL;

//端监控上报数据
@property (nonatomic, strong)NSDictionary<Optional> *mointerInfo;

- (TTPhotoDetailAdActionType) adActionType;

@end

@class TTPhotoDetailAdUrlListModel;
@protocol TTPhotoDetailAdUrlListModel;
@interface TTAdImageModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* url;
@property (nonatomic, strong)NSNumber<Optional>* width;
@property (nonatomic, strong)NSArray<Optional, TTPhotoDetailAdUrlListModel>* url_list;
@property (nonatomic, strong)NSString<Optional>* uri;
@property (nonatomic, strong)NSNumber<Optional>* height;
@property (nonatomic, strong)NSNumber<Optional>*day_mode;


@end

@interface TTPhotoDetailAdUrlListModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* url;

@end




