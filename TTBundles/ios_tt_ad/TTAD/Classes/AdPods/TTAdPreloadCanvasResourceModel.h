//
//  TTAdPreloadCanvasResourceModel.h
//  Article
//
//  Created by carl on 2017/5/24.
//
//

#import <JSONModel/JSONModel.h>
#import "TTAdResourceModel.h"

@protocol TTAdResourceModel;

@interface TTAdPreloadCanvasSettingModel : JSONModel
@property (nonatomic, strong) NSArray<NSString *> *must_url;
@property (nonatomic, copy) NSString *layout_url;
@property (nonatomic, copy) NSString *root_color;
@property (nonatomic, copy) NSNumber *anim_style;
@property (nonatomic, copy) NSNumber *hasCreatedata;
@end

@interface TTAdPreloadCanvasResourceModel : JSONModel

@property (nonatomic, strong) NSArray<TTAdResourceModel *><TTAdResourceModel> *preload_data;
@property (nonatomic, strong) TTAdPreloadCanvasSettingModel *canvas;
@property (nonatomic, assign) NSInteger expire_seconds;
@property (nonatomic, assign) NSInteger expire_timestamp;
@property (nonatomic, strong) NSArray<NSNumber *> *ad_id;
@end
