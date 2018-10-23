//
//  TTCommentViewController.h
//  Article
//
//  Created by 冯靖君 on 16/3/30.
//
//

#import <TTThemed/SSThemed.h>
#import <TTUIWidget/SSViewControllerBase.h>
#import "TTCommentViewControllerProtocol.h"

@interface TTCommentViewController : UIViewController <TTCommentViewControllerProtocol>

@property (nonatomic, weak, nullable) id <TTCommentViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL enableImpressionRecording; // 是否开启评论列表 Impression 统计
@property (nonatomic, assign) BOOL hasSelfShown;              // 标识评论VC是否出现在页面上
@property (nonatomic, strong, readonly) SSThemedTableView *commentTableView;
@property (nonatomic, strong) NSString *serviceID;            // 评论服务所属 serviceID, 评论接口使用

- (nonnull instancetype)initWithViewFrame:(CGRect)frame
                               dataSource:(nullable id<TTCommentDataSource>)dataSource
                                 delegate:(nullable id<TTCommentViewControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;
@end
