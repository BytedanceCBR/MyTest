//
//  TTCommentDetailHeaderDigItem.m
//  Article
//
//  Created by muhuai on 12/01/2017.
//
//

#import "TTCommentDetailHeaderDigItem.h"
#import <TTPlatformBaseLib/TTIconFontDefine.h>
#import <TTAvatar/TTAsyncCornerImageView+VerifyIcon.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceUIUtils.h>



@interface _TTCommentDetailHeaderDigAvatarCell : UICollectionViewCell
@property (nonatomic, strong) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong) SSUserModel *userModel;
@end

@implementation _TTCommentDetailHeaderDigAvatarCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:self.bounds allowCorner:YES];
        _avatarView.cornerRadius = _avatarView.width / 2.f;
        _avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _avatarView.userInteractionEnabled = NO;
        [_avatarView setupVerifyViewForLength:24.f adaptationSizeBlock:nil];
        [self.contentView addSubview:self.avatarView];
    }
    return self;
}

- (void)refreshWithModel:(SSUserModel *)userModel {
    self.userModel = userModel;
   
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userModel.userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
    [self.avatarView tt_setImageWithURLString:userModel.avatarURLString];
}
@end

@interface TTCommentDetailHeaderDigItem() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) SSThemedButton *arrowButton;
@property (nonatomic, strong) UICollectionView *avatarCollectionView;
@property (nonatomic, strong) TTCommentDetailModel *commentModel;
@property (nonatomic, copy) NSString *mediaId;
@property (nonatomic, copy) NSString *gid;

@end

@implementation TTCommentDetailHeaderDigItem

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshArrowButton {
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:self.commentModel.diggCount? [NSString stringWithFormat:@"%ld人赞过 ",(long)self.commentModel.diggCount]: @"暂无人赞过" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]],
    NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText1)
    }];
    if (self.commentModel.diggCount) {
        [attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:iconfont_right_arrow attributes:@{NSFontAttributeName: [UIFont fontWithName:@"iconfont" size:7.f], NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText1), NSBaselineOffsetAttributeName : @(2.f)}]];
    }
    
    [_arrowButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [_arrowButton sizeToFit];
    _arrowButton.height = self.height;
    _arrowButton.userInteractionEnabled = !!self.commentModel.diggCount;
}

- (id)initWithModel:(TTCommentDetailModel *)model Width:(CGFloat)width
{
    CGRect frame = CGRectMake(0, 0, width, 24.f);
    self = [super initWithFrame:frame];
    if (self) {
        _commentModel = model;
        [self setupViews];
        [self setupLayouts];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.avatarCollectionView];
    [self addSubview:self.arrowButton];
    [self refreshArrowButton];
}

- (void)setupLayouts {
    if (self.avatarCollectionView.frame.size.width != [self _avatarCollectionViewFrame].size.width) {
        self.avatarCollectionView.frame = [self _avatarCollectionViewFrame];
    }
    self.arrowButton.left = self.avatarCollectionView.right? self.avatarCollectionView.right + [TTDeviceUIUtils tt_newPadding:8.f]: 0.f;
    
    self.arrowButton.centerY = self.avatarCollectionView.centerY;
}

- (void)relayoutWithWidth:(CGFloat)width
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (void)reloadDataWithModel:(TTCommentDetailModel *)model {
    self.commentModel = model;
    [self.avatarCollectionView reloadData];
    [self refreshArrowButton];
    [self setupLayouts];
}

- (void)arrowButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(commentDetailHeaderDigItem:diggUsersAccessoryClicked:)]) {
        [self.delegate commentDetailHeaderDigItem:self diggUsersAccessoryClicked:nil];
    }
}

- (CGRect)_avatarCollectionViewFrame {
    NSUInteger count = MIN(self.commentModel.digUsers.count, [TTDeviceHelper isScreenWidthLarge320]? 4: 3);
    return CGRectMake(0, 0, count * 24.f + (count? (count - 1) * 4.f: 0.f), 24.f);
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    // add by zjing 去掉 xx人赞过的头像点击
//    if ([self.delegate respondsToSelector:@selector(commentDetailHeaderDigItem:diggUserAvatarClicked:)]) {
//        [self.delegate commentDetailHeaderDigItem:self diggUserAvatarClicked:self.commentModel.digUsers[indexPath.row]];
//    }
    
}

#pragma mark - UICollectionViewDataSource;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(self.commentModel.digUsers.count, [TTDeviceHelper isScreenWidthLarge320]? 4: 3);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString * stringID = [NSString stringWithFormat:@"TTCommentDetailHeaderDigAvatarCellIdentifier%ld",indexPath.row];
    _TTCommentDetailHeaderDigAvatarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringID forIndexPath:indexPath];
    [cell refreshWithModel:self.commentModel.digUsers[indexPath.row]];
    return cell;
}

#pragma mark - setter & getter
- (UICollectionView *)avatarCollectionView {
    if (!_avatarCollectionView) {
        _avatarCollectionView = [[UICollectionView alloc] initWithFrame:[self _avatarCollectionViewFrame] collectionViewLayout:({
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            flowLayout.itemSize = CGSizeMake(24.f, 24.f);
            flowLayout.minimumLineSpacing = 4.f;
            flowLayout;
        })];
        _avatarCollectionView.dataSource = self;
        _avatarCollectionView.delegate = self;
        _avatarCollectionView.clipsToBounds = NO;
        _avatarCollectionView.scrollEnabled = NO;
        for (NSInteger i = 0; i < 4; i++) {
            NSString * stringID = [NSString stringWithFormat:@"TTCommentDetailHeaderDigAvatarCellIdentifier%ld",i];
            [_avatarCollectionView registerClass:[_TTCommentDetailHeaderDigAvatarCell class] forCellWithReuseIdentifier:stringID];
        }
        _avatarCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _avatarCollectionView;
}

- (SSThemedButton *)arrowButton {
    if (!_arrowButton) {
        _arrowButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _arrowButton.backgroundColor = [UIColor clearColor];
        _arrowButton.titleColorThemeKey = kColorText1;
        _arrowButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSizeForMoment:12.f]];
        [_arrowButton addTarget:self action:@selector(arrowButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrowButton;
}
@end
