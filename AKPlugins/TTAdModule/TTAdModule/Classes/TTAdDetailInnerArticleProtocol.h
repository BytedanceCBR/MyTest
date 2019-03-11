//
//  TTAdDetailInnerArticleProtocol.h
//  Article
//
//  Created by pei yun on 2017/7/24.
//
//

#ifndef TTAdDetailInnerArticleProtocol_h
#define TTAdDetailInnerArticleProtocol_h

@class TTGroupModel;
@protocol TTAdDetailInnerArticleProtocol <NSObject>

@property (nonatomic, assign, readonly) int64_t uniqueID;
@property (nonatomic, strong, readonly) NSString *mediaID;

- (TTGroupModel *)groupModel;

@end

#endif /* TTAdDetailInnerArticleProtocol_h */
