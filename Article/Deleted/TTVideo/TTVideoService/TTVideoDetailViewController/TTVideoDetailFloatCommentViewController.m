//
//  TTVideoDetailFloatCommentViewController.m
//  Article
//
//  Created by songxiangwu on 2016/11/2.
//
//

#import "TTVideoDetailFloatCommentViewController.h"
#import "ArticleMomentDetailView.h"
#import "TTVideoCommentDetailView.h"
#import "TTHeaderScrollView.h"
//#import "TTTabContainerView.h"

static const CGFloat kLinePadding = 0;

@implementation TTVideoDetailFloatCommentTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeName = kColorBackground4;
        
        _shadowView = [[UIImageView alloc] init];
        _shadowView.image = [UIImage imageNamed:@"video_comment_shadow"];
        [self addSubview:_shadowView];
        
        UIImage *img = [UIImage themedImageNamed:@"tt_titlebar_close"];
        _closeBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _closeBtn.imageName = @"tt_titlebar_close";
        _closeBtn.highlightedImageName = @"tt_titlebar_close_press";
        _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        [self addSubview:_closeBtn];
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = NSLocalizedString(@"回复", nil);
        _titleLabel.font = [UIFont systemFontOfSize:17.f];
        _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
//        img = [UIImage themedImageNamed:@"new_more_titlebar"];
//        _moreBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
//        [_moreBtn setImage:img forState:UIControlStateNormal];
//        _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
//        [self addSubview:_moreBtn];
        _lineView = [[SSThemedView alloc] initWithFrame:CGRectMake(kLinePadding, self.height - [TTDeviceHelper ssOnePixel], self.width - 2 * kLinePadding, [TTDeviceHelper ssOnePixel])];
        _lineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _shadowView.frame = CGRectMake(0, -9, self.width, 9);
    _closeBtn.right = self.width - 15;
    _closeBtn.centerY = self.height / 2;
    _titleLabel.left = 15;
    _titleLabel.centerY = self.height / 2;
    _lineView.frame = CGRectMake(kLinePadding, self.height - [TTDeviceHelper ssOnePixel], self.width - 2 * kLinePadding, [TTDeviceHelper ssOnePixel]);
}

@end

static const CGFloat kBarHeight = 49;

@interface TTVideoDetailFloatCommentViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) TTVideoCommentDetailView *detailView; //新版评论
@property (nonatomic, strong) ArticleMomentDetailView *oldDetailView; //老版动态
@property (nonatomic, strong) TTVideoDetailFloatCommentTopBar *topBar;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;
@property (nonatomic, assign) BOOL isDraggingFloatView;
@property (nonatomic, assign) CGFloat lastY;
@property (nonatomic, assign) CGFloat originY;
@property (nonatomic, assign) BOOL fromMessage;

@end

@implementation TTVideoDetailFloatCommentViewController

- (instancetype)initWithViewFrame:(CGRect)viewFrame comment:(id<TTCommentModelProtocol>)commentModel groupModel:(TTGroupModel *)groupModel momentModel:(ArticleMomentModel *)momentModel delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate showWriteComment:(BOOL)showWriteComment fromMessage:(BOOL)fromMessage {
    self = [super init];
    if (self) {
        _isAdVideo = NO;
        _commentModel = commentModel;
        _groupModel = groupModel;
        _showWriteComment = showWriteComment;
        _viewFrame = viewFrame;
        _momentModel = momentModel;
        _delegate = delegate;
        _fromMessage = fromMessage;
    }
    return self;
}

- (void)dealloc {
    _detailView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = _viewFrame;
    _topBar = [[TTVideoDetailFloatCommentTopBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kBarHeight)];
    [_topBar.closeBtn addTarget:self action:@selector(p_dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
//    [_topBar.moreBtn addTarget:self action:@selector(p_moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_topBar];
    BOOL showWriteComment = NO;
    
    _topBar.titleLabel.text = [NSString stringWithFormat:@"%ld条回复", [_commentModel.replyCount integerValue]];
    [_topBar.titleLabel sizeToFit];

    WeakSelf;
    _detailView = [[TTVideoCommentDetailView alloc] initWithFrame:CGRectMake(0, _topBar.bottom, self.view.width, self.view.height - _topBar.height) commentId:[_commentModel.commentID longLongValue] momentModel:_momentModel delegate:_delegate showWriteComment:showWriteComment fromVideoDetail:YES fromMessage:self.fromMessage];
    _detailView.isAdVideo = self.isAdVideo;
    _detailView.commentModel = _commentModel;
    _detailView.dismissBlock = ^ {
        StrongSelf;
        [self p_dismissSelf:nil];
    };
    
    void (^updateMomentCountBlock)(NSInteger, NSInteger) = ^void(NSInteger count, NSInteger increment) {
        StrongSelf;
        if (count) {
            self.topBar.titleLabel.text = [NSString stringWithFormat:@"%ld条回复", count];
            [self.topBar.titleLabel sizeToFit];
        } else if (increment) {
            count = [self.topBar.titleLabel.text integerValue] + increment;
            self.topBar.titleLabel.text = [NSString stringWithFormat:@"%ld条回复", count];
            [self.topBar.titleLabel sizeToFit];
        }
        
        //这通知搞的..能再糙点吗..
        [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"count":@(count) , @"groupID":[NSString stringWithFormat:@"%@", self.groupModel.groupID]}];
    };
    
    _detailView.updateMomentCountBlock = ^(NSInteger count, NSInteger increment) {
        updateMomentCountBlock(count, increment);
    };
    _oldDetailView.updateMomentCountBlock = ^(NSInteger count, NSInteger increment) {
        updateMomentCountBlock(count, increment);
    };
    
    void (^syncDigCountBlock)() = ^void() {
        StrongSelf;
        self.commentModel.userDigged = self.detailView.momentModel.digged;
        self.commentModel.digCount = @(self.detailView.momentModel.diggsCount);
        if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(videoDetailFloatCommentViewControllerDidChangeDigCount)]) {
            [self.vcDelegate videoDetailFloatCommentViewControllerDidChangeDigCount];
        }
    };
    _detailView.syncDigCountBlock = ^{
        syncDigCountBlock();
    };
    _oldDetailView.syncDigCountBlock = ^{
        syncDigCountBlock();
    };
    
    void (^scrollViewDidScrollBlock)(UIScrollView *) = ^void(UIScrollView *scrollView) {
        StrongSelf;
        [self p_handleCommentViewDidScroll:scrollView];
    };
    _detailView.scrollViewDidScrollBlock = ^(UIScrollView *scrollView) {
        scrollViewDidScrollBlock(scrollView);
    };
    _oldDetailView.scrollViewDidScrollBlock = ^(UIScrollView *scrollView) {
        scrollViewDidScrollBlock(scrollView);
    };
    
    if (self.replyMomentCommentModel) {
        [_detailView insertLocalMomentCommentModel:self.replyMomentCommentModel];
        [_oldDetailView insertLocalMomentCommentModel:self.replyMomentCommentModel];
    }
    [self.topBar.titleLabel sizeToFit];
    [TTVideoCommentDetailView configGlobalCustomWidth:[self p_maxWidthForDetailView]];
    [ArticleMomentDetailView configGlobalCustomWidth:[self p_maxWidthForDetailView]];
    //这TM代码写的 我也是日了狗了.. 迁一次代码, 迁的我蛋都碎了..
    [self.view addSubview:_detailView];
    [self.view addSubview:_oldDetailView];
    
    self.panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handlePanGesture:)];
    self.panGes.delegate = self;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:self.panGes];
    self.originY = self.view.top;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", _commentModel.commentID.stringValue, nil, nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_detailView didAppear];
    [_oldDetailView didAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_detailView willDisappear];
    [_oldDetailView willDisappear];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _topBar.frame = CGRectMake(0, 0, self.view.width, kBarHeight);
    _detailView.frame = CGRectMake(0, _topBar.bottom, self.view.width, self.view.height - _topBar.height);
    _oldDetailView.frame = CGRectMake(0, _topBar.bottom, self.view.width, self.view.height - _topBar.height);
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [TTVideoCommentDetailView configGlobalCustomWidth:[self p_maxWidthForDetailView]];
        [ArticleMomentDetailView configGlobalCustomWidth:[self p_maxWidthForDetailView]];
    } else {
        [TTVideoCommentDetailView configGlobalCustomWidth:0];
        [ArticleMomentDetailView configGlobalCustomWidth:[self p_maxWidthForDetailView]];
    }
}

- (void)p_dismissSelf:(UIButton *)sender {
    [self p_dismissSelf:sender animate:YES];
}

- (void)p_dismissSelf:(UIButton *)sender animate:(BOOL)animate {
    dispatch_block_t block = ^ {
        if ([_vcDelegate respondsToSelector:@selector(videoDetailFloatCommentViewControllerDidDimiss:)]) {
            [_vcDelegate videoDetailFloatCommentViewControllerDidDimiss:self];
        }
    };
    if (animate) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.top = self.view.bottom;
        } completion:^(BOOL finished) {
            block();
        }];
    } else {
        block();
    }
}

- (void)p_handleCommentViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        scrollView.contentOffset = contentOffset;
        if (!self.isDraggingFloatView) {
            self.isDraggingFloatView = YES;
        }
    }
    if (self.isDraggingFloatView && self.view.top != self.originY) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        scrollView.contentOffset = contentOffset;
    }
}

- (void)p_moreBtnClick:(UIButton *)sender {
    wrapperTrackEvent(@"update_detail", @"title_bar_more_click");
    [[self.detailView getDetailViewHeaderItem] arrowButtonClicked];
    [[self.oldDetailView getDetailViewHeaderItem] arrowButtonClicked];
}

- (void)p_handlePanGesture:(UIPanGestureRecognizer *)ges {
    CGPoint locationPoint = [ges locationInView:self.view.superview];
    CGPoint velocityPoint = [ges velocityInView:self.view.superview];
    BOOL flag = (self.detailView && self.detailView.commentListView.contentOffset.y <= 0) || (self.oldDetailView && self.oldDetailView.commentListView.contentOffset.y <= 0);
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.lastY = locationPoint.y;
            if (velocityPoint.y > 0 && flag && !self.isDraggingFloatView) {
                self.isDraggingFloatView = YES;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
            if (velocityPoint.y > 0 && flag && !self.isDraggingFloatView) {
                self.isDraggingFloatView = YES;
            }
            if (self.isDraggingFloatView) {
                CGFloat step = locationPoint.y - self.lastY;
                CGRect frame = self.view.frame;
                frame.origin.y += step;
                if (frame.origin.y < self.originY) {
                    frame.origin.y = self.originY;
                }
                if (frame.origin.y > self.view.superview.height) {
                    frame.origin.y = self.view.superview.height;
                }
                self.view.frame = frame;
            }
            self.lastY = locationPoint.y;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (self.isDraggingFloatView) {
                CGRect frame = self.view.frame;
                frame.origin.y = velocityPoint.y > 0 ? self.view.superview.height : self.originY;
                [UIView animateWithDuration:0.2 animations:^{
                    self.view.frame = frame;
                } completion:^(BOOL finished) {
                    if (velocityPoint.y > 0) {
                        [self p_dismissSelf:nil animate:NO];
                    }
                }];
            }
            self.isDraggingFloatView = NO;
        }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGes) {
        CGPoint velocityPoint = [self.panGes velocityInView:self.view.superview];
        if (fabs(velocityPoint.x) > fabs(velocityPoint.y)) {
            return NO;
        }
        return YES;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer.view == self.detailView.commentListView) {
        return YES;
    }
    
    if (otherGestureRecognizer.view == self.oldDetailView.commentListView) {
        return YES;
    }
    return NO;
}

- (CGFloat)p_maxWidthForDetailView {
    return self.view.width;
}

- (void)setViewFrame:(CGRect)viewFrame {
    _viewFrame = viewFrame;
    self.view.frame = _viewFrame;
}

- (void)setBanEmojiInput:(BOOL)banEmojiInput {
    if ([TTDeviceHelper isPadDevice]) { // iPad 暂时不支持
        banEmojiInput = YES;
    }

    _banEmojiInput = banEmojiInput;

    self.detailView.banEmojiInput = banEmojiInput;
}

@end
