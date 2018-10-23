//
//  TTVVideoDetailStayPageTracker.h
//  Article
//
//  Created by pei yun on 2017/4/9.
//
//

#import <Foundation/Foundation.h>
#import "TTVArticleProtocol.h"
#import "TTVArticleExtraInfo.h"
#import "TTVDetailContext.h"
#import "TTDetailModel.h"
@interface TTVVideoDetailStayPageTracker : NSObject<TTVDetailContext>
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;
@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, copy  ) NSString           *enterFrom;
@property (nonatomic, copy  ) NSString           *categoryName;
@property (nonatomic, strong) id<TTVArticleProtocol>            article;
@property (nonatomic, strong) NSDictionary       *gdExtDict;

@property (nonatomic,assign) double commentShowTimeTotal;
@property (nonatomic,assign) double commentDetailShowTimeTotal;

@property (nonatomic, strong) TTVArticleExtraInfo *articleExtraInfo;
- (instancetype)initWithArticle:(id<TTVArticleProtocol>)article;
- (float)currentStayDuration;
@end
