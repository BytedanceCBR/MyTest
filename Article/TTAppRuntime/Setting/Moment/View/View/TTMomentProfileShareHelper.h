//
//  TTMomentProfileShareHelper.h
//  Article
//
//  Created by muhuai on 2017/6/6.
//
//

#import <Foundation/Foundation.h>

//个人主页直接调用了ArticleJSBridge的shareWithUserID:方法... 清理ArticleJSBridge时 这个方法被删掉了..
//故..迁移一份shareWithUserID到此处..
@interface TTMomentProfileShareHelper : NSObject

- (void)shareWithUserID:(NSString *)uid;

@end
