//
//  TTWaitingView.h
//  Article
//
//  Created by 冯靖君 on 16/2/1.
//
//

#import "SSThemed.h"

/**
 *  动画显示转菊花，用在loadMore和TTIndicator的waitingStyle场景
 */
@interface TTWaitingView : SSThemedView
@property(nonatomic, strong) SSThemedImageView  *imageView;

- (void)startAnimating;
- (void)stopAnimating;

@end
