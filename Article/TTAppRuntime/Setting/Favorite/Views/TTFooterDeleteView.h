//
//  TTFooterDeleteView.h
//  Article
//
//  Created by fengyadong on 16/11/20.
//
//

#import "SSThemed.h"

@class TTFeedMultiDeleteViewModel;

@protocol TTFooterDeleteViewDelegate<NSObject>

- (NSString *)clearAllTitleString;
- (NSString *)deleteTitleString;

@end

@interface TTFooterDeleteView : SSThemedView

@property (nonatomic, assign, readonly) long long totalDeletingCount;
@property (nonatomic, copy) void (^didDelete)(BOOL clearAll, TTFeedMultiDeleteViewModel *viewModel);
@property (nonatomic, weak) id<TTFooterDeleteViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame viewModel:(TTFeedMultiDeleteViewModel *)viewModel canClearAll:(BOOL)canClearAll;
- (void)changeDeletingCountIfNeeded;

@end
