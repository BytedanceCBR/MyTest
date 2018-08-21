//
//  TTUGCEmojiInputView.m
//  Article
//
//  Created by Jiyee Sheng on 5/19/17.
//
//

#import <TTThemed/SSThemed.h>
#import "TTUGCEmojiInputView.h"
#import "TTUGCEmojiTextAttachment.h"
#import "TTDeviceHelper.h"
#import "TTTrackerWrapper.h"

@interface TTUGCEmojiInputCollectionViewCell ()

@property (nonatomic, strong) SSThemedImageView *imageView;

@end

@implementation TTUGCEmojiInputCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];

        self.imageView.frame = CGRectMake(0, 0, self.emojiSize, self.emojiSize);
    }

    return self;
}

- (CGFloat)emojiSize {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode667:
        case TTDeviceMode812: return 44.f;
        case TTDeviceMode568:
        case TTDeviceMode480: return 37.f;
    }

    return 44.f;
}

- (void)setTextAttachment:(TTUGCEmojiTextAttachment *)textAttachment {
    _textAttachment = textAttachment;

    self.imageView.imageName = textAttachment.imageName;
}

- (SSThemedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, self.emojiSize, self.emojiSize)];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeCenter; // Emoji 图片采用贴边切处理，不留透明间距
        [_imageView sizeToFit];
    }

    return _imageView;
}

@end


static const NSUInteger kNumberOfEmojisPerRow = 7; // 横排一行包含按钮数
static const NSUInteger kNumberOfEmojisPerColumn = 3; // 竖排一行包含按钮数
static const NSUInteger kNumberOfEmojisPerPage = 20; // 不包括删除按钮

@interface TTUGCEmojiInputView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) SSThemedView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) SSThemedView *groupView;

@end

@implementation TTUGCEmojiInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.collectionView];
        [self.contentView addSubview:self.pageControl];

        self.pageControl.transform = CGAffineTransformMakeScale(0.6, 0.6);

        // 一期只提供一组小表情
        [self addSubview:self.groupView];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_1"]];
        imageView.frame = CGRectMake(9, 3, 32, 32);
        [self.groupView addSubview:imageView];

        self.backgroundColorThemeKey = kColorBackground4;
        self.contentView.backgroundColors = @[[UIColor colorWithHexString:@"F9F9F9"] , SSGetThemedColorWithKey(kColorBackground3)];
        self.groupView.backgroundColors = @[[UIColor colorWithHexString:@"F9F9F9"] , SSGetThemedColorWithKey(kColorBackground3)];

        [self themeChanged:nil];
    }

    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];

    self.collectionView.backgroundColor = SSGetThemedColorInArray(@[[UIColor colorWithHexString:@"F9F9F9"] , SSGetThemedColorWithKey(kColorBackground3)]);
    self.pageControl.currentPageIndicatorTintColor = SSGetThemedColorInArray(@[@"1B1B1B", @"F4F5F6"]);
    self.pageControl.pageIndicatorTintColor = SSGetThemedColorWithKey(kColorLine7);
}

- (void)setTextAttachments:(NSArray<TTUGCEmojiTextAttachment *> *)textAttachments {
    if (!textAttachments) return;

    NSUInteger count = textAttachments.count;
    NSUInteger pageCount = (count / kNumberOfEmojisPerPage) + (count % kNumberOfEmojisPerPage > 0 ? 1 : 0);

    NSMutableArray *fulfillEmojiTextAttachments = [[NSMutableArray alloc] init];

    // 因为策略要求横排排序，UICollectionView 因为横向滑动，数据则竖向排序，故需要翻转行列式
    for (int page = 0; page < pageCount; ++page) {
        for (int column = 0; column < kNumberOfEmojisPerRow; ++column) {
            for (int row = 0; row < kNumberOfEmojisPerColumn; ++row) {
                NSUInteger index = page * kNumberOfEmojisPerPage + column + row * kNumberOfEmojisPerRow;
                TTUGCEmojiTextAttachment *emojiTextAttachment;

                if (column + 1 == kNumberOfEmojisPerRow && row + 1 == kNumberOfEmojisPerColumn) { // 插入删除按钮
                    emojiTextAttachment = [[TTUGCEmojiTextAttachment alloc] init];
                    emojiTextAttachment.idx = TTUGCEmojiDelete;
                    emojiTextAttachment.imageName = @"input_emoji_delete";
                    emojiTextAttachment.plainText = @"";
                } else if (index < count) { // 插入 Emoji 按钮
                    emojiTextAttachment = textAttachments[index];
                } else { // 插入空白补全按钮
                    emojiTextAttachment = [[TTUGCEmojiTextAttachment alloc] init];
                    emojiTextAttachment.idx = TTUGCEmojiBlank;
                    emojiTextAttachment.imageName = nil;
                    emojiTextAttachment.plainText = @"";
                }

                [fulfillEmojiTextAttachments addObject:emojiTextAttachment];
            }
        }
    }

    _textAttachments = [fulfillEmojiTextAttachments copy];

    self.pageControl.numberOfPages = pageCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.textAttachments.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTUGCEmojiInputCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTUGCEmojiInputCollectionViewCell class]) forIndexPath:indexPath];
    cell.textAttachment = self.textAttachments[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.row > self.textAttachments.count) {
        return;
    }

    TTUGCEmojiTextAttachment *selectedTextAttachment = self.textAttachments[indexPath.row];

    if (selectedTextAttachment.idx != TTUGCEmojiBlank) {
        if (selectedTextAttachment.idx == TTUGCEmojiDelete) {
            [TTTrackerWrapper eventV3:@"emoticon_delete" params:@{
                @"source" : self.source ?: @""
            }];
        } else {
            [TTTrackerWrapper eventV3:@"emoticon_select" params:@{
                @"emoticon_id" : [selectedTextAttachment.imageName stringByReplacingOccurrencesOfString:@"emoji_" withString:@""],
                @"source" : self.source ?: @""
            }];
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiInputView:didSelectEmojiTextAttachment:)]) {
        [self.delegate emojiInputView:self didSelectEmojiTextAttachment:selectedTextAttachment];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.row > self.textAttachments.count) {
        return;
    }

    TTUGCEmojiTextAttachment *selectedTextAttachment = self.textAttachments[indexPath.row];

    if (selectedTextAttachment.idx == TTUGCEmojiDelete) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

        cell.alpha = 0.5f;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.row > self.textAttachments.count) {
        return;
    }

    TTUGCEmojiTextAttachment *selectedTextAttachment = self.textAttachments[indexPath.row];

    if (selectedTextAttachment.idx == TTUGCEmojiDelete) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

        cell.alpha = 1.0f;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = (NSInteger) (scrollView.contentOffset.x / floor(scrollView.frame.size.width));

    if (currentPage >= 0 && currentPage < self.pageControl.numberOfPages) {
        [TTTrackerWrapper eventV3:@"emoticon_slide" params:@{
            @"source" : self.source ?: @""
        }];

        self.pageControl.currentPage = currentPage;
    }
}

- (CGFloat)emojiSize {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode667:
        case TTDeviceMode812: return 44.f;
        case TTDeviceMode568:
        case TTDeviceMode480: return 37.f;
    }

    return 44.f;
}

- (CGFloat)lineSpacing {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736: return 13.f;
        case TTDeviceMode667:
        case TTDeviceMode812: return 8.f;
        case TTDeviceMode568:
        case TTDeviceMode480: return 8.f * 0.9f;
    }

    return 8.f;
}

- (CGFloat)itemSpacing {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode667:
        case TTDeviceMode812: return 6.f;
        case TTDeviceMode568:
        case TTDeviceMode480: return 6.f * 0.9f;
    }

    return 6.f;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.emojiSize, self.emojiSize);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = self.lineSpacing;
    flowLayout.minimumInteritemSpacing = self.itemSpacing;
    flowLayout.headerReferenceSize = CGSizeMake(self.lineSpacing / 2, 0.f);
    flowLayout.footerReferenceSize = CGSizeMake(self.lineSpacing / 2, 0.f);

    return flowLayout;
}

- (SSThemedView *)contentView {
    if (!_contentView) {
        _contentView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 37.f)];
    }

    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.itemSpacing, 10.f, self.lineSpacing + self.emojiSize * kNumberOfEmojisPerRow + self.lineSpacing * (kNumberOfEmojisPerRow -1) , self.emojiSize * kNumberOfEmojisPerColumn + self.itemSpacing * (kNumberOfEmojisPerColumn - 1)) collectionViewLayout:self.flowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionHeaderView"];
        [_collectionView registerClass:[TTUGCEmojiInputCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TTUGCEmojiInputCollectionViewCell class])];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionFooterView"];
    }

    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds) - 25.f, CGRectGetMaxY(self.bounds) - 5.f - 15.f - 37.f, 50.f, 5.f)];
        _pageControl.numberOfPages = 0;
    }

    return _pageControl;
}

- (SSThemedView *)groupView {
    if (!_groupView) {
        _groupView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds) - 37.f, 50.f, 37.f)];
    }

    return _groupView;
}

@end
