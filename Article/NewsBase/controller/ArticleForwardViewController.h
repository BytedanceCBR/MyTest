//
//  ArticleForwardViewController.h
//  Article
//
//  Created by SunJiangting on 15-1-18.
//
//

#import "SSViewControllerBase.h"


typedef NS_ENUM(NSInteger, ArticleForwardSourceType) {
    ArticleForwardSourceTypeMoment,
    ArticleForwardSourceTypeTopic,
    ArticleForwardSourceTypeProfile,
    ArticleForwardSourceTypeNotify,
    ArticleForwardSourceTypeOther
};

@interface ArticleForwardViewController : SSViewControllerBase

- (instancetype)initWithMomentModel:(ArticleMomentModel *) momentModel NS_DESIGNATED_INITIALIZER;
@property (nonatomic, assign) ArticleForwardSourceType sourceType;

@property (nonatomic, strong)ArticleMomentModel *momentModel;

@end
