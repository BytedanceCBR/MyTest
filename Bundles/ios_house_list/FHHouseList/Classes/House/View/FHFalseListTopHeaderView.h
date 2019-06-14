//
//  FHFalseListTopHeaderView.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFalseListTopHeaderView : UIView

@property(nonatomic , strong) UILabel *titleLabel;

- (void)refreshUI:(NSString *)title andImageUrl:(NSURL *)imageUrl;

@end

NS_ASSUME_NONNULL_END
