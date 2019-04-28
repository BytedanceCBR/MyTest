//
//  ExploreOrderedADModel+TTVADSupport.h
//  Article
//
//  Created by pei yun on 2017/7/5.
//
//

#import <TTVideoService/Common.pbobjc.h>
#import "ExploreOrderedADModel.h"

@interface ExploreOrderedADModel (TTVADSupport)

+ (ExploreOrderedADModel *_Nullable)adModelWithTTVADInfo:(TTVADCell *_Nullable)adCell article:(TTVVideoArticle *_Nullable)article;

@end
