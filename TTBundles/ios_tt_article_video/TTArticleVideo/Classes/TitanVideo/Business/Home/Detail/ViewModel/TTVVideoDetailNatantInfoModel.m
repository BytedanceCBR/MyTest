//
//  TTVVideoDetailNatantInfoModel.m
//  Article
//
//  Created by lishuangyang on 2017/5/22.
//
//

#import "TTVVideoDetailNatantInfoModel.h"
#import "TTVArticleProtocol.h"
#import "NSDictionary+TTGeneratedContent.h"
@implementation TTVVideoDetailNatantInfoModel

- (instancetype) initWithArticle:(id<TTVArticleProtocol>)article andadId:(NSString *)adId withCategoryId:(NSString *)categoryId andVideoAbstract:(NSString *) abstract andTitleRichSpan:(NSString *)titleRichSpan{
    self = [super init];
    if ([article conformsToProtocol:@protocol(TTVArticleProtocol) ]) {
        
        self.title = article.title;
        self.content = [article articleDetailContent];
        self.abstract = abstract;
        self.VExtendLinkDic = article.videoExtendLink;
        self.zzComments = article.zzComments;
        self.digCount = [NSString stringWithFormat:@"%d",article.diggCount];
        self.buryCount = [@(article.buryCount) stringValue];
        self.userDiged = @(article.userDigg);
        self.userBuried = @(article.userBury);
        self.banBury = article.banBury;
        self.banDig = article.banDigg;
        self.articlePublishTime = article.articlePublishTime;
        self.isOriginal = [article.h5Extra valueForKey:@"is_original"];
        self.videoDetailInfo = article.videoDetailInfo;
        self.aggrType = article.aggrType;
        self.adId = adId;
        self.groupId = article.groupModel.groupID;
        self.categoryId = categoryId;
        self.itemId = article.groupModel.itemID;
        NSDictionary *userInfo = article.userInfo;
        self.authorId = [userInfo ttgc_contentID];
        self.titleRichSpan = titleRichSpan;
    }
    return self;
}

@end
