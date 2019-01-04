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
#import "TTSeachBarView.h"
#import "ExploreSearchView.h"
#import "TTTopBarHeader.h"
#import "Bubble-Swift.h"

@class TTCategorySelectorView;
@class TTSeachBarView;
@class FHHomeSearchPanelView;

@protocol TTTopBarDelegate <NSObject>

- (void)searchActionFired:(id)sender;
- (void)mineActionFired:(id)sender;

@end

@interface TTTopBar : SSViewBase

@property (nonatomic, weak) id<TTTopBarDelegate> delegate;
@property (nonatomic, strong) NSString *tab;
@property (nonatomic, strong) FHHomeSearchPanelView *pageSearchPanel;
//@property (nonatomic, strong) HomePageSearchPanel *pageSearchPanel;

- (void)addTTCategorySelectorView:(TTCategorySelectorView *)selectorView delegate:(id<TTCategorySelectorViewDelegate>)delegate;

- (void)setupSubviews;

+ (UIImage *)searchBackgroundImage;

+ (UIImage *)searchBarImage;
@end
