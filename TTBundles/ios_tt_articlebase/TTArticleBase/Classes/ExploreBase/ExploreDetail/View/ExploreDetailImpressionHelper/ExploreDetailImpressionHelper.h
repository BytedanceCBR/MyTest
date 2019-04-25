//
//  ExploreDetailImpressionHelper.h
//  Article
//
//  Created by 冯靖君 on 15/10/29.
//
//

#import <Foundation/Foundation.h>
#import "TTGroupModel.h"
#import "SSImpressionManager.h"

@interface ExploreDetailImpressionHelper : NSObject

+ (void)recordDetailForRelatedGroupModel:(TTGroupModel *)rGroupModel
                              groupModel:(TTGroupModel *)groupModel
                                listType:(SSImpressionGroupType)listType
                              withStatus:(SSImpressionStatus)status;
+ (void)recordDetailForUrl:(NSString *)url
                groupModel:(TTGroupModel *)groupModel
                  listType:(SSImpressionGroupType)listType
                withStatus:(SSImpressionStatus)status;
+ (void)recordDetailForWendaKey:(NSString *)wendaKey
                      groupModel:(TTGroupModel *)groupModel
                        listType:(SSImpressionGroupType)listType
                      withStatus:(SSImpressionStatus)status;
//新版记录详情页相关问答，传qid_aid
+ (void)recordDetailForNewWendaKey:(NSString *)wendaKey
                        groupModel:(TTGroupModel *)groupModel
                          listType:(SSImpressionGroupType)listType
                        withStatus:(SSImpressionStatus)status;
@end
