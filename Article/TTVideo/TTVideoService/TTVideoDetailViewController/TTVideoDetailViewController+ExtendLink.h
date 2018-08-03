//
//  TTVideoDetailViewController+ExtendLink.h
//  Article
//
//  Created by panxiang on 16/9/19.
//
//


#import "TTVideoDetailViewController.h"
#import <StoreKit/StoreKit.h>
#import "TTVideoExtendLinkHelper.h"

@interface TTVideoDetailViewController (ExtendLink)<SKStoreProductViewControllerDelegate ,TTVideoLinkViewDelegate>
- (void)showExtendLinkViewWithArticle:(Article *)article;
- (void)showExtendLinkViewWithArticle:(Article *)article isAuto:(BOOL)isAuto;
- (void)extendLinkViewControllerWillAppear;
- (BOOL)shouldPauseMovieWhenShow;
- (void)el_addObserver;
- (void)el_removeObserver;

@property (nonatomic, strong) NSNumber *shouldPresentAdLater;

@end
