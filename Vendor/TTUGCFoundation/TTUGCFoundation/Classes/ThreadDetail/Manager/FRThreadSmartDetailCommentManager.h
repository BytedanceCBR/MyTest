//
//  FRThreadSmartDetailCommentManager.h
//  Article
//
//  Created by 王霖 on 4/22/16.
//
//

#import <Foundation/Foundation.h>
#import "FRRequestManager.h"

@interface FRThreadSmartDetailCommentManager : NSObject

+ (void)requestArticleCommentWithThreadID:(int64_t)threadID
                                  forumID:(int64_t)forumID
                                    msgID:(NSString *_Nullable)msgID
                            offset:(NSInteger)offset
                             count:(NSInteger)count
                      apiParameter:(NSString * _Nullable)apiParameter
                          callback:(void(^ _Nullable)(NSError * _Nullable error, NSObject<TTResponseModelProtocol> * _Nullable responseModel,FRForumMonitorModel *_Nullable monitorModel))callback;

@end
