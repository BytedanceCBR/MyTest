//
//  ExploreVideoDetailImpressionHelper.h
//  Article
//
//  Created by 冯靖君 on 15/10/10.
//
//

#import <Foundation/Foundation.h>
#import "SSImpressionManager.h"
#import "TTGroupModel.h"
#import "Article.h"

@interface ExploreVideoDetailImpressionHelper : NSObject

//+ (void)enterVideoDetailForVideoID:(NSString *)videoID
//                        groupModel:(TTGroupModel *)groupModel;
//
//+ (void)leaveVideoDetailForVideoID:(NSString *)videoID
//                        groupModel:(TTGroupModel *)groupModel;

+ (void)recordVideoDetailForArticle:(Article *)article
                           rArticle:(Article *)rArticle
                             status:(SSImpressionStatus)status;

@end
