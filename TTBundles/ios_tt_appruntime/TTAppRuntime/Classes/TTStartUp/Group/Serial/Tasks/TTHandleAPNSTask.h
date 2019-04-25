//
//  TTHandleAPNSTask.h
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupTask.h"
#import "ArticleAPNsManager.h"

@protocol ArticleAPNsManagerDelegate;

@interface TTHandleAPNSTask : TTStartupTask<ArticleAPNsManagerDelegate,UIApplicationDelegate>

+ (NSString *)deviceTokenString;

@end
