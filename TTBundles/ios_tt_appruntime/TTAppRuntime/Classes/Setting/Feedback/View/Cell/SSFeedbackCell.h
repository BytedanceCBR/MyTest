//
//  SSFeedbackCell.h
//  Article
//
//  Created by Zhang Leonardo on 13-1-6.
//
//

#import <UIKit/UIKit.h>
#import "SSFeedbackModel.h"
#import "SSThemed.h"

@protocol SSFeedbackCellDelegate;

@interface SSFeedbackCell : SSThemedTableViewCell

@property(nonatomic, weak)id<SSFeedbackCellDelegate> delegate;

- (void)refreshFeedbackModel:(SSFeedbackModel *)model;

+ (CGFloat)heightForRowByModel:(SSFeedbackModel *)model listViewWidth:(CGFloat)width;

@end

@protocol SSFeedbackCellDelegate <NSObject>

- (void)feedbackCellImgButtonClicked:(SSFeedbackModel *)model;

@end


