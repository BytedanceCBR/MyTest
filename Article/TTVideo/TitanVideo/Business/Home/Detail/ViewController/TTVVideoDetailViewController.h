//
//  TTVVideoDetailViewController.h
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import <TTUIWidget/SSViewControllerBase.h>
#import "TTDetailModel.h"
#import "TTVVideoInformationSyncProtocol.h"
#import "TTVDetailContext.h"

extern NSString * const assertDesc_articleType;
extern NSString * const TTVideoDetailViewControllerDeleteVideoArticle;

@class TTVideoLinkView;
@interface TTVVideoDetailViewController : SSViewControllerBase <TTVDetailContext>

@property (nonatomic, strong) id <TTVArticleProtocol> videoInfo;
@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;
@property (nonatomic, weak) id<TTVVideoDetailToolbarActionProtocol> toolbarActionDelegate;
@property (nonatomic, strong) TTVideoLinkView *linkView;

@end
