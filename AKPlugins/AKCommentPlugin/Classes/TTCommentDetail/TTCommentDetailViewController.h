//
//  TTCommentDetailViewController.h
//  Article
//
//  Created by zhaoqin on 05/01/2017.
//
//

#import "TTCommentModelProtocol.h"
#import <TTUIWidget/SSViewControllerBase.h>
#import <TTPlatformUIModel/TTGroupModel.h>
#import <BDTArticle/Article.h>
#import <TTUIWidget/TTModalWrapController.h>

//评论转发到文章的通知
extern NSString *const kTTCommentDetailForwardCommentNotification;

@class TTCommentDetailToolbarView;

@interface TTCommentDetailViewController : SSViewControllerBase <TTModalWrapControllerProtocol>

@property (nonatomic, strong) id<TTCommentModelProtocol> commentModel;
@property (nonatomic, strong) TTGroupModel *groupModel;
@property (nonatomic, assign) BOOL showWriteComment;
@property (nonatomic, assign) BOOL showComment;
@property (nonatomic, strong) void(^dismissComplete)();
@property (nonatomic, strong) TTCommentDetailToolbarView *toolbarView;
@property (nonatomic, strong) Article *article;

// 埋点用
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, strong) NSDictionary *logPb;


@end

