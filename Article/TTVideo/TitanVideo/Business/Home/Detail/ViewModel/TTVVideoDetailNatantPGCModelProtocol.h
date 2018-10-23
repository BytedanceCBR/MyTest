//
//  TTVVideoDetailNatantPGCModelProtocol.h
//  Article
//
//  Created by lishuangyang on 2017/5/23.
//
//

#ifndef TTVVideoDetailNatantPGCModelProtocol_h
#define TTVVideoDetailNatantPGCModelProtocol_h
#import "TTVArticleProtocol.h"
#import "NSDictionary+TTGeneratedContent.h"
@protocol TTVVideoDetailNatantPGCModelProtocol <NSObject>
    
@property (nonatomic, strong) NSDictionary *contentInfo;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *videoSource;
@property (nonatomic, copy) NSString *mediaUserID;
@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *userDecoration;
//log相关
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *groupIDStr;
@property (nonatomic, strong) NSDictionary *logPb;

- (instancetype)initWithVideoArticle: (id<TTVArticleProtocol>) article;

@end

#endif /* TTVVideoDetailNatantPGCModelProtocol_h */

