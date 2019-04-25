//
//  FRForumGossipViewController.h
//  Article
//
//  Created by 王霖 on 15/10/18.
//
//

#import "SSViewControllerBase.h"

/**
 爆料发帖web页面，支持forumID(话题版本)和关心ID(关心版本)
 
 - returns: 爆料发帖web页面
 */
@interface FRForumGossipViewController : SSViewControllerBase

- (instancetype)initWithUrlString:(NSString *)urlString andConcernId:(NSString *)cid NS_DESIGNATED_INITIALIZER;

@end
