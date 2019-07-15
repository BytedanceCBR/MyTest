//
//  FHFastQATextView.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol HPGrowingTextViewDelegate;
@interface FHFastQATextView : UIView

@property(nonatomic , strong) NSString *text;
@property(nonatomic , strong) NSString *placeholder;
@property(nonatomic , weak)   id<HPGrowingTextViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
