//
//  TTPostThreadViewController.h
//  Article
//  图文发布器，用于主发布器，微头条发布器，关心主页发布器和爆料、影评
//
//  Created by 王霖 on 16/8/24.
//
//

#import "SSViewControllerBase.h"
#import "Thread.h"

extern NSString * const kForumPostThreadFinish;

@interface TTPostThreadViewController : SSViewControllerBase
@property (nonatomic, copy) NSString *entrance; //入口
@property (nonatomic, copy) NSString *enterConcernID; //entrance为concern时有意义
@end
