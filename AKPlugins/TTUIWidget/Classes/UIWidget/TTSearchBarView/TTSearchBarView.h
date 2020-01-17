//
//  TTSearchBarView.h
//  Article
//
//  Created by SunJiangting on 14-9-10.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

extern const CGFloat kCancelButtonPadding;

@protocol TTSearchBarViewDelegate;
@interface TTSearchBarView : SSThemedView <UITextFieldDelegate>

@property (nonatomic, copy)   NSString         * text;

@property (nonatomic, strong) SSThemedView * contentView;
@property (nonatomic, strong) SSThemedButton * inputBackgroundView;

@property (nonatomic, strong) SSThemedImageView     * searchImageView;
@property (nonatomic, strong) SSThemedTextField     * searchField;
@property (nonatomic, strong) SSThemedButton        * closeButton;
/// 取消按钮
@property (nonatomic, strong) SSThemedButton        * cancelButton;

@property (nonatomic, weak) id <TTSearchBarViewDelegate> delegate;

@property (nonatomic, assign) BOOL                   editing;

@property (nonatomic, strong) SSThemedView          * bottomLineView;
- (void) setEditing:(BOOL) editing animated:(BOOL) animated;
- (void) searchBarCancelButtonClicked:(id) sender;
/// Default NO
@property (nonatomic, assign) BOOL showsCancelButton;

@end
/// UISearchBarDelegate
@protocol TTSearchBarViewDelegate <NSObject>

@optional
- (BOOL)searchBarShouldBeginEditing:(TTSearchBarView *)searchBar;                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(TTSearchBarView *)searchBar;                     // called when text starts editing
- (BOOL)searchBarShouldEndEditing:(TTSearchBarView *)searchBar;                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(TTSearchBarView *)searchBar;                       // called when text ends editing
- (void)searchBarTextDidClear:(TTSearchBarView *)searchBar;                            // called when clear text
- (void)searchBar:(TTSearchBarView *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
- (BOOL)searchBar:(TTSearchBarView *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0); // called before text changes

- (void)searchBarSearchButtonClicked:(TTSearchBarView *)searchBar;                     // called when keyboard search button pressed

//// unused
- (void)searchBarBookmarkButtonClicked:(TTSearchBarView *)searchBar;                   // called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(TTSearchBarView *) searchBar;                    // called when cancel button pressed
- (void)searchBarResultsListButtonClicked:(TTSearchBarView *)searchBar NS_AVAILABLE_IOS(3_2); // called when search results button pressed

- (void)searchBar:(TTSearchBarView *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0);

@end

extern CGSize const TTSearchBarViewDefaultSize;
