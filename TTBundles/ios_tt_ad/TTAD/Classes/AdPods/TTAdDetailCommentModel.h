//
//  TTAdDetailCommentModel.h
//  Article
//
//  Created by carl on 2016/11/20.
//
//

#import "TTPhotoDetailAdModel.h"
#import <JSONModel/JSONModel.h>

@interface TTAdDetailCommentModel : JSONModel
/**
 * @abstract ad_id，id from server means ad_id, idea_id
 * It is a bomb. At most time ad_id is idea_id.
 */
@property (nonatomic, copy) NSNumber *ad_id;
@property (nonatomic, copy) NSString<Optional> *log_extra;
@property (nonatomic, copy) NSString<Optional> *web_url;
@property (nonatomic, copy) NSString *web_title;

@property (nonatomic, strong) NSArray<NSString *> *show_track_urls;
@property (nonatomic, strong) NSArray<NSString *> *click_track_urls;

@property (nonatomic, copy) NSString<Optional> *title;


@property (nonatomic, strong) NSArray<NSDictionary *> *image_list;

@property (nonatomic, copy) NSString<Optional> *label;

/**
 * @see TTAdActionType
 */
@property (nonatomic, copy) NSString<Optional> *type;

/**
 * @see TTAdDisplayStyle
 */
@property (nonatomic, assign) NSInteger display_type;
/**
 * @see TTAdPreloadOption
 */
@property (nonatomic, assign) NSInteger predownload;

@property (nonatomic, assign) NSInteger display_after;
@property (nonatomic, assign) NSInteger expire_seconds;

@end
