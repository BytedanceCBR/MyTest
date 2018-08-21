//
//  TTCommentWriteManager.h
//  Article
//
//  Created by ranny_90 on 2018/1/11.
//

#import <Foundation/Foundation.h>
#import "TTCommentDetailModelProtocol.h"
#import "TTCommentDetailReplyCommentModelProtocol.h"
#import "TTRichSpanText.h"
#import "Article.h"
#import "TTCommentWriteViewDefine.h"


@interface TTCommentWriteManager : NSObject <TTCommentManagerProtocol>

//内部使用
@property (nonatomic, weak) TTCommentWriteView *commentWriteView;

//内部使用
@property (nonatomic, weak) id<TTCommentWriteManagerDelegate> delegate;

@property (nonatomic, strong) NSString *serviceID;            // 评论服务所属 serviceID, 评论接口使用

/** 外部接口
 评论时使用
 @param conditions 主体评论
 @param replyCommentModel 被回复的评论
 @return ..
 */
- (instancetype)initWithCommentCondition:(NSDictionary *)conditions
                     commentViewDelegate:(id<TTCommentWriteManagerDelegate>)commentViewDelegate
                      commentRepostBlock:(TTCommentRepostParamsBlock)commentRepostBlock;


- (instancetype)initWithCommentCondition:(NSDictionary *)conditions
                     commentViewDelegate:(id<TTCommentWriteManagerDelegate>)commentViewDelegate
                      commentRepostBlock:(TTCommentRepostParamsBlock)commentRepostBlock
                          extraTrackDict:(NSDictionary *)extraTrackDict
                         bindVCTrackDict:(NSDictionary *)bindVCTrackDict
        commentRepostWithPreRichSpanText:(TTRichSpanText *)preRichSpanText
                             readQuality:(TTArticleReadQualityModel *)readQuality;



@end
