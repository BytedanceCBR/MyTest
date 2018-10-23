//
//  TTHTTPProcesserMessageHandle.h
//  Article
//
//  Created by panxiang on 2017/4/7.
//
//

#import <Foundation/Foundation.h>
#import "TTVBaseMacro.h"
#import "TTVideoArticleServiceMessage.h"
#import "TTHTTPProcesserMessage.h"
#warning todop 文章下架等功能待测试
@interface TTVHTTPProcesserMessageHandle : NSObject<TTHTTPProcesserMessage>
ShareInterface(TTVHTTPProcesserMessageHandle);
@end
