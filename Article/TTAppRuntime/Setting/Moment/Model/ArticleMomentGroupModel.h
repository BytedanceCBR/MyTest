//
//  ArticleMomentGroup.h
//  Article
//
//  Created by Dianwei on 14-5-22.
//
//

#import <Foundation/Foundation.h>
#import "SSBaseModel.h"

typedef NS_ENUM(NSInteger, ArticleMomentGroupType){
    ArticleMomentGroupNone      = -1,
    ArticleMomentGroupEssay     = 3,
    ArticleMomentGroupArticle   = 4,
    ArticleMomentGroupThread    = 6,
};

typedef NS_ENUM (NSInteger, ArticleMediaType){
    NormalArticle = 1,
    ArticleWithVideo = 2
};

/**
 用于新版动态，消息，通知的文章表示
 */
@interface ArticleMomentGroupModel : SSBaseModel<NSCoding>
- (instancetype)initWithDictionary:(NSDictionary*)dict;
- (void)updateWithDictionary:(NSDictionary*)dict;
@property(nonatomic, assign) BOOL deleted;
@property(nonatomic, retain)NSString *title;
@property(nonatomic, retain)NSString *thumbnailURLString;
@property(nonatomic, assign)ArticleMomentGroupType groupType;
@property(nonatomic, assign)ArticleMediaType mediaType;
@property(nonatomic, copy)  NSString            *openURL;

@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, strong) SSUserModel *user;

@end
