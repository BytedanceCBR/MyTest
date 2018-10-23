//
//  ExploreMixedListBaseView+FunctionArea.h
//  Article
//
//  Created by 王霖 on 2017/6/1.
//
//

#import "ExploreMixedListBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExploreMixedListBaseView (FunctionArea)

//- (void)categoryIDDidChange;
- (UITableViewCell *)functionAreaCell;
- (CGFloat)heightForFunctionAreaCell;

@end

NS_ASSUME_NONNULL_END
