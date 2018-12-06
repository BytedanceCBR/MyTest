//
//  TTCommentDetailReplyWriteManager.h
//  Article
//
//  Created by ranny_90 on 2018/1/21.
//

#import <Foundation/Foundation.h>
#import "TTCommentDetailModelProtocol.h"
#import "TTCommentDetailReplyCommentModelProtocol.h"
#import "TTCommentWriteViewDefine.h"

@class TTRichSpanText;

@interface TTCommentDetailReplyWriteManager : NSObject<TTCommentManagerProtocol>

@property (nonatomic, strong) NSString *serviceID;            // 评论服务所属 serviceID, 评论接口使用

//内部使用
@property (nonatomic, weak) TTCommentWriteView *commentWriteView;

@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSDictionary *logPb;

- (instancetype)initWithCommentDetailModel:(id<TTCommentDetailModelProtocol>)commentDetailModel
                         replyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol> )replyCommentModel
                           publishCallback:(TTCommentDetailPublishCommentViewPublishCallback)publishCallBack
                        commentRepostBlock:(TTCommentRepostParamsBlock)commentRepostBlock;

/** 外部接口
 回复 主体下的子评论... ..就是回复reply_list里的评论
 @param detailModel 主体评论
 @param replyCommentModel 被回复的评论
 @return ..
 */
- (instancetype)initWithCommentDetailModel:(id<TTCommentDetailModelProtocol>)commentDetailModel
                         replyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol> )replyCommentModel
                        commentRepostBlock:(TTCommentRepostParamsBlock)commentRepostBlock
                           publishCallback:(TTCommentDetailPublishCommentViewPublishCallback)publishCallBack
            getReplyCommentModelClassBlock:(TTCommentGetReplyCommentModelClassCallback)getReplyClassCallback
          commentRepostWithPreRichSpanText:(TTRichSpanText *)preRichSpanText
                             commentSource:(NSString *)commentSource;

@end
