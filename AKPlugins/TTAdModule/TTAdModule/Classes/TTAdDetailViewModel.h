//
//  TTAdDetailViewModel.h
//  Article
//
//  Created by carl on 2017/6/14.
//
//

#import <Foundation/Foundation.h>
#import "TTAdDetailInnerArticleProtocol.h"

// VC容器信息tougu
@interface TTAdDetailViewModel : NSObject
@property (nonatomic, assign) NSInteger fromSource;
@property (nonatomic, copy) NSString *catagoryID;
@property (nonatomic, copy) NSDictionary *logPb;
@property (nonatomic, strong) id<TTAdDetailInnerArticleProtocol> article;
@property (nonatomic, strong) TTGroupModel *groupModel;
@property (nonatomic, copy) NSDictionary *mediaInfo; //问答
@end
