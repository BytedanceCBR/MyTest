
#import "TTBaseCell.h"
#import "TTDetailModel.h"
#import "TTVideoFloatContentView.h"
#import "TTVideoFloatCellEntity.h"

@interface TTVideoFloatCell : TTBaseCell
@property(nonatomic ,readonly) TTVideoFloatContentView *customContentView;
@property(nonatomic ,readonly) TTVideoFloatCellEntity  *cellEntity;
- (void)addMovieView:(UIView *)movieView;
- (void)removeMovieView;
- (TTDetailModel *)detailModel;
- (void)immerseHalf;//图片以外的沉浸
- (void)unImmerseHalf;//
- (void)immerseAll;//整个cell都沉浸
- (void)unImmerseAll;
- (BOOL)isImmersed;
- (NSString *)videoID;
- (void)showPlayIcon:(BOOL)show;
- (void)showBackgroundImage:(BOOL)show;
- (UIView *)animationToView;
@end
