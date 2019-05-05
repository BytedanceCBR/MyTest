//
//  ExploreMovieLoadingView.h
//  Article
//
//  Created by Chen Hong on 15/9/21.
//
//

#import <UIKit/UIKit.h>

@interface ExploreMovieLoadingView : UIView
@property(nonatomic, assign)BOOL isFullScreen;
- (void)startAnimating;
- (void)stopAnimating;
@end
