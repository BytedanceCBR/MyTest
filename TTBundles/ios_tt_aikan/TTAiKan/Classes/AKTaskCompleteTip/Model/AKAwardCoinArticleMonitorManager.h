//
//  AKAwardCoinArticleMonitorManager.h
//  Article
//
//  Created by chenjiesheng on 2018/3/30.
//

#import <Foundation/Foundation.h>
#import "ArticleDetailHeader.h"

@interface AKAwardCoinArticleMonitorManager : NSObject

//+ (instancetype)shareInstance;
- (void)ak_readComplete;
+ (instancetype)ak_startMonitorIfNeedWithGroupID:(NSString *)groupID
                                      fromSource:(NewsGoDetailFromSource)source;
@end
