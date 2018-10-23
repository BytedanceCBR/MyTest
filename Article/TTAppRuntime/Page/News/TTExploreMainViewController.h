//
//  TTExploreMainViewController.h
//  Article
//
//  Created by 刘廷勇 on 15/9/23.
//
//

#import <UIKit/UIKit.h>
#import "TTCategorySelectorView.h"
//#import "TTPagingScrollViewController.h"

@class TTTopBar;
@class TTSeachBarView;

@interface TTExploreMainViewController : UIViewController

@property (nonatomic, strong, readonly) TTTopBar *topBar;
@property (nonatomic, strong) TTCategorySelectorView *categorySelectorView;

@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat bottomInset;

@property (nonatomic, strong) dispatch_block_t startLoadingBlock;

@property (nonatomic, strong) dispatch_block_t finishLoadingBlock;

@property (nonatomic, readonly) BOOL isRefreshByClickTabBar;
//用来在打点show时区分是否是频道切换的标志位
@property (nonatomic, assign)BOOL isChangeChannel;

+ (TTSeachBarView *)searchBar;

+ (BOOL)isNewFeed;

@end
