//
//  UGCRepostCommonModel.h
//  Article
//  通用转发数据模型，不区分源类型，与 originGroup, originThread 互斥
//
//  Created by ranny_90 on 2017/10/10.
//

#import "JSONModel.h"

@interface UGCRepostCommonModel : JSONModel

@property(nonatomic, copy) NSString<Optional> *schema;

@property(nonatomic, copy) NSString<Optional> *title;

@property(nonatomic, copy) NSDictionary<Optional> *cover_image;

@property(nonatomic, strong) NSNumber<Optional> *has_video;

@property(nonatomic, copy) NSString<Optional> *group_id;

@property(nonatomic, strong) NSNumber<Optional> *style; // 上图下文（style=2）、左图右文（style=1）、小图右文（style=0）

@property(nonatomic, strong) NSArray<Optional> *image_list; // 转发图集

@end
