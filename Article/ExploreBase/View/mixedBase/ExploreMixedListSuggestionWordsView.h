//
//  ExploreMixedListSuggestionWordsView.h
//  Article
//
//  Created by chenren on 01/11/2017.
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@interface ExploreMixedListSuggestionWordsView : SSThemedView

@property (nonatomic, copy) NSString *categoryID;

- (void)loadData;
- (void)refreshWithData:(NSArray *)array animated:(BOOL)animated superviewIsShowing:(BOOL)superviewIsShowing;

@end
