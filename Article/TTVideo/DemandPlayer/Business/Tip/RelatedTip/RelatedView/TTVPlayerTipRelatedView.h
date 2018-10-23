//
//  TTVPlayerTipRelatedView.h
//  Article
//
//  Created by panxiang on 2017/10/12.
//

#import <UIKit/UIKit.h>
#import "JSONModel.h"

typedef NS_ENUM(NSUInteger, TTVPlayerTipRelatedViewType) {
    TTVPlayerTipRelatedViewTypeUnknown,
    TTVPlayerTipRelatedViewTypeSimple,
    TTVPlayerTipRelatedViewTypeRed,
    TTVPlayerTipRelatedViewTypeAppIcon,
    TTVPlayerTipRelatedViewTypeImageIcon
};


@interface TTVPlayerTipRelatedEngityAuthor : JSONModel
@property (nonatomic ,strong)NSNumber <Optional> *id;
@property (nonatomic ,copy)NSString <Optional> *name;
@property (nonatomic ,copy)NSString <Optional> *avatar_url;
@property (nonatomic ,strong)NSNumber <Optional> *is_verify;
@end

@interface TTVPlayerTipRelatedEngityVideo : JSONModel
@property (nonatomic ,copy)NSString <Optional> *cover_image_url;
@property (nonatomic ,copy)NSString <Optional> *cover_animated_url;
@end

@interface TTVPlayerTipRelatedEngityStats : JSONModel
@property (nonatomic ,strong)NSNumber <Optional> *play_count;
@property (nonatomic ,strong)NSNumber <Optional> *impr_count;
@property (nonatomic ,strong)NSNumber <Optional> *digg_count;
@property (nonatomic ,strong)NSNumber <Optional> *bury_count;
@property (nonatomic ,strong)NSNumber <Optional> *favorite_count;
@property (nonatomic ,strong)NSNumber <Optional> *comment_count;
@property (nonatomic ,strong)NSNumber <Optional> *share_count;
@end

@protocol TTVPlayerTipImageList
@end

@interface TTVPlayerTipImageList : JSONModel
@property (nonatomic ,copy)NSString <Optional> *source;
@property (nonatomic ,copy)NSString <Optional> *url;
@end

@interface TTVPlayerTipRelatedEntity : JSONModel
@property (nonatomic ,strong)NSNumber <Optional> *hasSendShowTrack;//本地计算属性
@property (nonatomic ,strong)NSNumber <Optional> *id;
@property (nonatomic ,strong)NSNumber <Optional> *feed_type;
@property (nonatomic ,copy)NSString *title;
@property (nonatomic ,copy)NSString *download_text;
@property (nonatomic ,copy)NSString *app_apple_id;
@property (nonatomic ,copy)NSString <Optional> *content;
@property (nonatomic ,copy)NSString <Optional> *app_display_name;
@property (nonatomic ,copy)NSString <Optional> *app_scheme;
@property (nonatomic ,copy)NSString <Optional> *url;
@property (nonatomic ,copy)NSString *download_url;
@property (nonatomic ,copy)NSString <Optional> *feed_icon_url;
@property (nonatomic ,strong)NSNumber <Optional> *create_time;
@property (nonatomic ,strong)NSNumber <Optional> *modify_time;
//@property (nonatomic ,strong)NSArray <TTVPlayerTipImageList,Optional> *image_list;
@property (nonatomic ,strong)TTVPlayerTipRelatedEngityStats <Optional> *stats;
@property (nonatomic ,strong)TTVPlayerTipRelatedEngityVideo <Optional> *video;
@property (nonatomic ,strong)TTVPlayerTipRelatedEngityAuthor <Optional> *author;
@property (nonatomic ,strong)NSString *ack_click;    //点击事件
@property (nonatomic ,strong)NSString *ack_valid_impr;  //展示事件

- (NSDictionary *)ack_clickDic;
- (NSDictionary *)ack_valid_imprDic;
@end

#define kAutoChangeTime 3

@protocol TTVPlayerTipRelatedViewDelegate<NSObject>
- (void)relatedViewClickAtItem:(TTVPlayerTipRelatedEntity *)entity;
- (void)relatedViewSendShowTrack:(TTVPlayerTipRelatedEntity *)entity;
@end

@interface TTVPlayerTipRelatedView : UIView
@property (nonatomic ,assign)TTVPlayerTipRelatedViewType viewType;
@property (nonatomic ,weak)id <TTVPlayerTipRelatedViewDelegate> delegate;
@property (nonatomic ,strong)NSMutableArray <TTVPlayerTipRelatedEntity *> *entitys;
- (void)setDataInfo:(NSDictionary *)dataInfo;
- (void)startTimer;
- (void)pauseTimer;
- (void)openDownloadUrl:(TTVPlayerTipRelatedEntity *)entity;
@end

