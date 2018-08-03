//
//  TTArticleDetailNatantViewModel.h
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//

#import <Foundation/Foundation.h>
#import "TTDetailModel.h"
#import "ArticleInfoManager.h"

@interface TTArticleDetailNatantViewModel : NSObject

- (instancetype)initWithDetailModel:(TTDetailModel *)detailModel;

- (void)tt_startFetchInformationWithFinishBlock:(TTArticleDetailFetchInformationBlock)block;

@end
