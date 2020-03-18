//
//  TTTopBar.h
//  Article
//
//  Created by fengyadong on 16/8/25.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTCategorySelectorView.h"
#import <TTUIWidget/TTSearchBarView.h>
#import "ExploreSearchView.h"
#import "TTTopBarHeader.h"

@class TTCategorySelectorView;
@class TTSearchBarView;
@class FHHomeSearchPanelView;

@protocol TTTopBarDelegate <NSObject>

- (void)searchActionFired:(id)sender;
- (void)mineActionFired:(id)sender;

@end

@interface TTTopBar : SSViewBase

@property (nonatomic, weak) id<TTTopBarDelegate> delegate;
@property (nonatomic, strong) NSString *tab;
@property (nonatomic, assign) BOOL isShowTopSearchPanel;
@property (nonatomic, strong) FHHomeSearchPanelView *pageSearchPanel;
//@property (nonatomic, strong) HomePageSearchPanel *pageSearchPanel;

- (void)addTTCategorySelectorView:(TTCategorySelectorView *)selectorView delegate:(id<TTCategorySelectorViewDelegate>)delegate;

- (void)setupSubviews;

+ (UIImage *)searchBackgroundImage;

+ (UIImage *)searchBarImage;

- (void)changeBackColor:(NSInteger)index;
@end
