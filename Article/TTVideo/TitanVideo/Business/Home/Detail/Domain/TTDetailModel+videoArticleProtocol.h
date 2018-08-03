//
//  TTDetailModel+videoArticleProtocol.h
//  Article
//
//  Created by pei yun on 2017/4/10.
//
//

#import "TTDetailModel.h"
#import "TTVArticleProtocol.h"
#import <TTVideoService/VideoInformation.pbobjc.h>

@interface TTDetailModel (videoArticleProtocol)

@property (nonatomic, strong, readonly) id<TTVArticleProtocol> protocoledArticle;
@property (nonatomic, strong) TTVVideoInformationResponse *videoInfo;
@property (nonatomic, strong) TTVVideoArticle *videoArticle;

@end
