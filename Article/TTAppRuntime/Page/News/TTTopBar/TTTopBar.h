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

@class TTCategorySelectorView;
@class TTSeachBarView;

@protocol TTTopBarDelegate <NSObject>

- (void)searchActionFired:(id)sender;
- (void)mineActionFired:(id)sender;

@end

@interface TTTopBar : SSViewBase

@property (nonatomic, weak) id<TTTopBarDelegate> delegate;
@property (nonatomic, strong) NSString *tab;

- (void)addTTCategorySelectorView:(TTCategorySelectorView *)selectorView delegate:(id<TTCategorySelectorViewDelegate>)delegate;

- (void)setupSubviews;

+ (UIImage *)searchBackgroundImage;

+ (UIImage *)searchBarImage;
@end
