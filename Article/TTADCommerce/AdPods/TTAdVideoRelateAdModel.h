//
//  TTAdVideoRelateAdModel.h
//  Article
//
//  Created by yin on 16/8/19.
//
//

#import <JSONModel/JSONModel.h>
#import "TTAdConstant.h"

@class TTAdVideoRelateAdImageUrlModel;
@class TTAdVideoRelateAdUrlListModel;
@protocol TTAdVideoRelateAdUrlListModel;

@interface TTAdVideoRelateAdModel : JSONModel<TTAd, TTAdAppAction>

@property (nonatomic, strong)NSString<Optional>* card_type;
@property (nonatomic, copy)  NSString<Optional>* ad_id;
@property (nonatomic, strong)NSString<Optional>* show_tag;
@property (nonatomic, strong)NSString<Optional>* source;
@property (nonatomic, copy)  NSString<Optional>* log_extra;
@property (nonatomic, strong)NSString<Optional>* web_url;
@property (nonatomic, strong)NSString<Optional>* title;
@property (nonatomic, strong)NSString<Optional>* image_url;
@property (nonatomic, strong)NSArray<Optional> * track_url_list;
@property (nonatomic, strong)NSArray<Optional> * click_track_url_list;
@property (nonatomic, strong)NSArray<Optional> * adPlayTrackUrls;
@property (nonatomic, strong)NSArray<Optional> * adPlayActiveTrackUrls;
@property (nonatomic, strong)NSArray<Optional> * adPlayEffectiveTrackUrls;
@property (nonatomic, strong)NSArray<Optional> * adPlayOverTrackUrls;
@property (nonatomic, assign)CGFloat  effectivePlayTime;
@property (nonatomic, strong)TTAdVideoRelateAdImageUrlModel<Optional>* middle_image;
@property (nonatomic, strong)NSString<Optional>* type;
@property (nonatomic, strong)NSNumber<Optional>* is_preview;
@property (nonatomic, strong)NSNumber<Optional>* ui_type;

//6.0新增下载、电话的创意
@property (nonatomic, strong)NSString<Optional>* creative_type;
@property (nonatomic, strong)NSString<Optional>* button_text;
@property (nonatomic, strong)NSString<Optional>* phone_number;
@property (nonatomic, strong)NSNumber<Optional>* dial_action_type;

@property (nonatomic, copy)  NSString<Optional>* download_url;
@property (nonatomic, copy)  NSString<Optional>* apple_id;
@property (nonatomic, copy)  NSString<Optional>* open_url;
@property (nonatomic, copy)  NSString<Optional>* ipa_url;
@property (nonatomic, copy)  NSString<Optional>* appUrl;
@property (nonatomic, copy)  NSString<Optional>* tabUrl;

//6.3.6新增表单创意
@property (nonatomic, copy)   NSString<Optional> *form_url;
@property (nonatomic, strong) NSNumber<Optional> *form_width;
@property (nonatomic, strong) NSNumber<Optional> *form_height;
@property (nonatomic, strong) NSNumber<Optional> *use_size_validation;

@property (nonatomic, assign)TTAdActionType actionType;   //点击非button区域跳转类型

- (BOOL)isValidAd;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end

@class TTAdVideoRelateAdUrlModel;
@protocol TTAdVideoRelateAdUrlModel;
@interface TTAdVideoRelateAdImageUrlModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* url;
@property (nonatomic, strong)NSNumber<Optional>* width;
@property (nonatomic, strong)NSArray<Optional, TTAdVideoRelateAdUrlModel>* url_list;
@property (nonatomic, strong)NSString<Optional>* uri;
@property (nonatomic, strong)NSNumber<Optional>* height;


@end

@interface TTAdVideoRelateAdUrlModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* url;

@end

