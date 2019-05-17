//
//  TTDetailContainerViewController.h
//  Article
//
//  Created by Ray on 16/3/31.
//
//

#import "SSViewControllerBase.h"
#import "TTDetailContainerViewModel.h"
#import "TTDetailViewController.h"
#import "TTVArticleProtocol.h"
#import "TTRoute.h"


@interface TTDetailContainerViewController : SSViewControllerBase <TTRouteInitializeProtocol>

@property (nonatomic, strong, nullable)TTDetailContainerViewModel * viewModel;
@property (nonatomic, strong, nullable) SSViewControllerBase<TTDetailViewController> * detailViewController;
@property (nonatomic, strong, nullable) UIView *shotScreenView;
- (nullable id)initWithArticle:(nullable id<TTVArticleProtocol>)tArticle
               source:(NewsGoDetailFromSource)source
            condition:(nullable NSDictionary *)condition;

- (BOOL)isNewsDetailForImageSubject;

- (BOOL)canRotateNewsDetailForImageSubject;

@end
