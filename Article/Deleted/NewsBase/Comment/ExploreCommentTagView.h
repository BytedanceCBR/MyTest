//
//  ExploreCommentTagView.h
//  Article
//
//  Created by 冯靖君 on 15/7/28.
//
//

#import "SSViewBase.h"

@protocol ExploreCommentTagViewDelegate <NSObject>

- (void)exploreCommentTagView:(id)commentTagView didSelectTagViewAtIndex:(NSInteger)index;

@end

@interface ExploreCommentTagView : SSViewBase

@property(nonatomic, strong) NSArray *tagItems;
@property(nonatomic, weak) id<ExploreCommentTagViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame tagItems:(NSArray *)tags NS_DESIGNATED_INITIALIZER;

@end
