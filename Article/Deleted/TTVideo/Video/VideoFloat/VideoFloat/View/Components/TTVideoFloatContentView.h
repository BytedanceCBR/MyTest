
#import "TTCellView.h"
#import "TTVideoFloatCellEntity.h"
#import "TTVideoFloatProtocol.h"

@interface TTVideoFloatContentView : TTCellView
@property (nonatomic ,nullable) TTVideoFloatCellEntity *cellEntity;
- (void)addMovieView:( UIView * _Nonnull )movieView;
- (void)immerseHalf;//图片以外的沉浸
- (void)unImmerseHalf;//
- (void)immerseAll;//整个cell都沉浸
- (void)unImmerseAll;
- (void)removeMovieView;
- (BOOL)isImmersed;
- (void)showPlayIcon:(BOOL)show;
- (void)showBackgroundImage:(BOOL)show;
- (UIView * _Nonnull)animationToView;
@end


