//
//  TTVideoDetailViewController+VerticalInteract.h
//  Article
//
//  Created by xiangwu on 2016/12/2.
//
//

#import "TTVideoDetailViewController.h"

@interface TTVideoDetailInteractModel : NSObject

@property (nonatomic, assign) CGFloat minMovieH;
@property (nonatomic, assign) CGFloat maxMovieH;
@property (nonatomic, assign) CGFloat curMovieH;
@property (nonatomic, assign) BOOL isDraggingMovieContainerView;
@property (nonatomic, assign) BOOL isDraggingCommentTableView;
@property (nonatomic, assign) CGFloat lastY;
@property (nonatomic, assign) CGFloat cLastY;
@property (nonatomic, assign) BOOL shouldSendCommentTrackLater;

@end

@interface TTVideoDetailViewController (VerticalInteract) <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *movieContainerViewPanGes;
@property (nonatomic, strong) UIPanGestureRecognizer *commentTableViewPanGes;

- (void)vdvi_commentTableViewDidScroll:(UIScrollView *)scrollView;
- (void)vdvi_commentTableViewDidEndDragging:(UIScrollView *)scrollView;
- (void)vdvi_changeMovieSizeWithStatus:(VideoDetailViewShowStatus)staus;
- (BOOL)vdvi_shouldFiltered;
- (void)vdvi_trackWithLabel:(NSString *)label source:(NSString *)source groupId:(NSString *)groupId;

@end
