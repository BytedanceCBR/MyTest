//
//  TTCommentDetailService.h
//  Article
//
//  Created by pei yun on 2017/11/23.
//

#import <Foundation/Foundation.h>
#import "TTCommentDetailModel.h"
#import "ExploreMomentDefine.h"

@interface TTCommentDetailService : NSObject

- (void)loadCommentDetailWithCommentID:(NSString *)commentID modifyTime:(NSNumber *)modifyTime finished:(void(^)(TTCommentDetailModel *model, NSError *error))finished;

@end
