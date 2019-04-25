//
//  TTCommentDetailModelProtocol.h
//  Article
//
//  Created by pei yun on 2017/8/14.
//
//

#ifndef TTCommentDetailModelProtocol_h
#define TTCommentDetailModelProtocol_h

@class TTGroupModel;
@protocol TTCommentDetailModelProtocol <NSObject>

@property (nonatomic, strong, readonly) TTGroupModel *groupModel;
@property (nonatomic, strong, readonly) NSString *commentID;
@property (nonatomic, assign, readonly) BOOL banEmojiInput;

@optional
- (BOOL)banForwardToWeitoutiao;

@end

#endif /* TTCommentDetailModelProtocol_h */
