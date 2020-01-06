//
//  TTPostThreadModel.h
//  发帖及编辑实体类
//
//  Created by zoujianfeng on 2019/1/9.
//

#import <Foundation/Foundation.h>
#import <TTUGCFoundation/FRApiModel.h>
#import <TTUGCFoundation/TTUGCImageCompressManager.h>
#import <TTUGCFoundation/TTUGCDefine.h>

@interface TTPostThreadModel : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *contentRichSpans;
@property (nonatomic, copy) NSString *mentionUsers;
@property (nonatomic, copy) NSString *mentionConcerns;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, assign) FRFromWhereType fromWhere;
@property (nonatomic, copy, nonnull) NSString *concernID;
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSString *postID;
@property (nonatomic, copy) NSArray<TTUGCImageCompressTask *> *taskImages;
@property (nonatomic, copy) NSArray<UIImage *> *thumbImages;
@property (nonatomic, assign) NSInteger needForward;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *detailPos;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat score;
@property (nonatomic, assign) NSUInteger refer;
@property (nonatomic, copy) NSString *communityID;
@property (nonatomic, copy) NSString *payload;
@property (nonatomic, assign) TTPostUGCEnterFrom postUGCEnterFrom;
@property (nonatomic, copy) NSString *forumNames;
@property (nonatomic, copy) NSDictionary *extraTrack;
@property (nonatomic, assign) BOOL syncToRocket;
@property (nonatomic, copy) NSString *promotionId;
@property (nonatomic, assign) int64_t insertMixCardID;
@property (nonatomic, copy) NSString * relatedForumSubjectID;//从专题页面进入时带入的专题的forum_id
@property (nonatomic, copy) NSString *sdkParams;// sdk 分享相关参数
@property (nonatomic, assign)   BOOL       hasSocialGroup;// 是否是外部传入小区
@property (nonatomic, copy)     NSString       *social_group_id;   // 选中的小区ID
@property (nonatomic, copy)     NSString       *social_group_name; // 选中的小区name


// 编辑帖子报数相关
@property (nonatomic, copy)     NSString       *enterFrom;
@property (nonatomic, copy)     NSString       *pageType;
@property (nonatomic, copy)     NSString       *elementFrom;

@end
