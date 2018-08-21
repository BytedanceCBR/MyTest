//
//  UIView+bindBackgroundColor.h
//  Article
//
//  Created by SongChai on 2017/4/19.
//
//

@interface UIView (bindBackgroundColor)
- (void) tt_backgroundColorBindView:(UIView*) view; //weak，不必关注内存问题
- (void) tt_backgroundColorUnBindView:(UIView*) view;

- (void) tt_backgroundColorBindViews:(UIView *)view, ...;
@end
