//
//  TTSeachBarView.h
//  Article
//
//  Created by SunJiangting on 14-9-10.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

extern const CGFloat kCancelButtonPadding;

@protocol TTSeachBarViewDelegate;
@interface TTSeachBarView : SSThemedView <UITextFieldDelegate>

@property (nonatomic, copy)   NSString         * text;

@property (nonatomic, strong) SSThemedView * contentView;
@property (nonatomic, strong) SSThemedButton * inputBackgroundView;

@property (nonatomic, strong) SSThemedImageView     * searchImageView;
@property (nonatomic, strong) SSThemedTextField     * searchField;
@property (nonatomic, strong) SSThemedButton        * closeButton;
/// 取消按钮
@property (nonatomic, strong) SSThemedButton        * cancelButton;

@property (nonatomic, weak) id <TTSeachBarViewDelegate> delegate;

@property (nonatomic, assign) BOOL                   editing;

@property (nonatomic, strong) SSThemedView          * bottomLineView;
- (void) setEditing:(BOOL) editing animated:(BOOL) animated;
/// Default NO
@property (nonatomic, assign) BOOL showsCancelButton;

@end
/// UISearchBarDelegate
@protocol TTSeachBarViewDelegate <NSObject>

@optional
- (BOOL)searchBarShouldBeginEditing:(TTSeachBarView *)searchBar;                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(TTSeachBarView *)searchBar;                     // called when text starts editing
- (BOOL)searchBarShouldEndEditing:(TTSeachBarView *)searchBar;                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(TTSeachBarView *)searchBar;                       // called when text ends editing
- (void)searchBar:(TTSeachBarView *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
- (BOOL)searchBar:(TTSeachBarView *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0); // called before text changes

- (void)searchBarSearchButtonClicked:(TTSeachBarView *)searchBar;                     // called when keyboard search button pressed

//// unused
- (void)searchBarBookmarkButtonClicked:(TTSeachBarView *)searchBar;                   // called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(TTSeachBarView *) searchBar;                    // called when cancel button pressed
- (void)searchBarResultsListButtonClicked:(TTSeachBarView *)searchBar NS_AVAILABLE_IOS(3_2); // called when search results button pressed

- (void)searchBar:(TTSeachBarView *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0);

@end

extern CGSize const TTSeachBarViewDefaultSize;
