//
//  TTRepostThreadModel.h
//  Article
//
//  Created by ranny_90 on 2017/9/11.
//  接口文档参考 https://wiki.bytedance.net/pages/viewpage.action?pageId=128756756
//

#import <Foundation/Foundation.h>
#import "Thread.h"


@interface TTRepostThreadModel : NSObject

@property (nonatomic,copy) NSString *cover_url;

@property (nonatomic,copy) NSString *content;

@property (nonatomic,copy) NSString *content_rich_span;

@property (nonatomic,copy) NSString *mentionUsers; //at人写这里

@property (nonatomic,copy) NSString *mentionConcerns; //#写这里

@property (nonatomic,assign) TTThreadRepostType repost_type; // 用于服务端透传和 Schema 传参

@property (nonatomic,copy) NSString *group_id;

@property (nonatomic,copy) NSString *fw_id; // 转发源内容的ID, 对应于 item_id, thread_id, ugc_video_id, answer_id

@property (nonatomic,assign) FRUGCTypeCode fw_id_type; // 转发源内容类型，对应于 文章、帖子、回复、小视频、问答

@property (nonatomic,copy) NSString *opt_id; // 转发上一级内容的ID

@property (nonatomic,assign) FRUGCTypeCode opt_id_type;

@property (nonatomic,copy) NSString *fw_user_id;

@property (nonatomic,copy) NSString *repostSchema;

@property (nonatomic,copy) NSString *repostTitle;

@property (nonatomic,assign) TTRepostOperationItemType repost_operation_type;

@property (nonatomic,assign) BOOL repostToComment; // 是否转发并评论

- (instancetype)initWithRepostParam:(NSDictionary *)repostParam;

@end
