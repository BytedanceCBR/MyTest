//
//  FHFastQAGuessQuestionView.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHFastQAGuessQuestionViewDelegate;
@interface FHFastQAGuessQuestionView : UIView

@property(nonatomic , weak) id<FHFastQAGuessQuestionViewDelegate> delegate;

-(NSInteger)updateWithItems:(NSArray *)items;

-(void)selectAtIndex:(NSInteger)index;


@end

@protocol FHFastQAGuessQuestionViewDelegate <NSObject>

-(void)selectView:(FHFastQAGuessQuestionView *)view atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
