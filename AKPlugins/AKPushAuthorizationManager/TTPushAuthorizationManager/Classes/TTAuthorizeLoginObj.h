//
//  TTAuthorizeLoginObj.h
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import "TTAuthorizeBaseObj.h"


/*
 登录授权
 */
@interface TTAuthorizeLoginObj : TTAuthorizeBaseObj


/*
 详情页-点击「收藏」按钮
 */
//- (void)showAlertAtActionDetailFavorite:(TTThemedAlertActionBlock)completionBlock;


/*
 详情页-点击/滑动 进入「评论」
 */
- (void)showAlertAtActionDetailComment:(TTThemedAlertActionBlock)completionBlock;


@end
