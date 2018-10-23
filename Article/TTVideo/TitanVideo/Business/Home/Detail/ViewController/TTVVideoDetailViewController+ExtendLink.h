//
//  TTVVideoDetailViewController+ExtendLink.h
//  Article
//
//  Created by pei yun on 2017/5/18.
//
//

#import "TTVVideoDetailViewController.h"
#import <StoreKit/StoreKit.h>
#import "TTVideoExtendLinkHelper.h"
#import "TTVArticleProtocol.h"
#import "TTVDemandPlayer.h"

@interface TTVVideoDetailViewController (ExtendLink) <SKStoreProductViewControllerDelegate, TTVideoLinkViewDelegate,TTVDemandPlayerDelegate>

- (void)showExtendLinkViewWithArticle:(id<TTVArticleProtocol>)article;
- (void)showExtendLinkViewWithArticle:(id<TTVArticleProtocol>)article isAuto:(BOOL)isAuto;
- (void)extendLinkViewControllerWillAppear;
- (BOOL)shouldPauseMovieWhenShow;
- (void)el_addObserver;
- (void)el_removeObserver;

@property (nonatomic, strong) NSNumber *shouldPresentAdLater;
@property (nonatomic, strong) UIView *maskView;
@end
