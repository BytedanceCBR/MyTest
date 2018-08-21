//
//  TTVVideoDetailNatantTagsView.m
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import "TTVVideoDetailNatantTagsView.h"
#import "TTTagView.h"
#import "SSThemed.h"
#import "TTTagViewConfig.h"
#import "TTTagItem.h"
#import "TTDetailModel.h"
#import "Article.h"
#import "TTRoute.h"

static const CGFloat kPadding = 15;

@interface TTVVideoDetailNatantTagsView ()

@property (nonatomic, strong) TTTagView * tagsView;
@property (nonatomic, strong) SSThemedButton *sourceBtn;
@property (nonatomic, strong) SSThemedView *bottomLine;

@end

@implementation TTVVideoDetailNatantTagsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tagsView];
        [self addSubview:self.sourceBtn];
        [self addSubview:self.bottomLine];
    }
    return self;
}

- (void)setViewModel:(id<TTVVideoDetailNatantTagsViewDataProtocol>)viewModel
{
    _viewModel = viewModel;
    
    [self configureUI];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat tPadding = self.tagPosition == TTVideoDetailSearchTagPositionTop ? 0 : kPadding;
    self.tagsView.top = tPadding;
    self.tagsView.left = kPadding;
    self.sourceBtn.top = tPadding;
    self.sourceBtn.left = kPadding;
    self.bottomLine.left = 0;
    self.bottomLine.bottom = self.height;
}

- (void)configureUI {
    //    NSMutableDictionary *testDict = [[NSMutableDictionary alloc] init];
    //    NSDictionary *testDict1 = @{@"link":@"sslocal://search?from=article_tag&gd_ext_json=%7B%22enter_from%22%3A%22click_related%22%7D&keyword=%23%E6%B2%99%E7%BE%8E%E5%B2%9B%23&extra=%7B%27entra_from%27%3A+%27click_related%27%2C+%27group_id%27%3A+6360572164613275905%7D", @"word":@"柴犬"};
    //    NSArray *testArr = @[
    //  @{@"link":@"sslocal://search?from=article_tag&gd_ext_json=%7B%22enter_from%22%3A%22click_related%22%7D&keyword=%23%E6%B2%99%E7%BE%8E%E5%B2%9B%23&extra=%7B%27entra_from%27%3A+%27click_related%27%2C+%27group_id%27%3A+6360572164613275905%7D", @"word":@"柴犬"},
    //  @{@"link":@"sslocal://search?from=article_tag&gd_ext_json=%7B%22enter_from%22%3A%22click_related%22%7D&keyword=%23%E6%B3%B0%E5%9B%BD%23&extra=%7B%27entra_from%27%3A+%27click_related%27%2C+%27group_id%27%3A+6360572164613275905%7D", @"word":@"松狮"},
    //  @{@"link":@"sslocal://search?from=article_tag&gd_ext_json=%7B%22enter_from%22%3A%22click_related%22%7D&keyword=%23%E7%A4%BE%E4%BC%9A%23&extra=%7B%27entra_from%27%3A+%27click_related%27%2C+%27group_id%27%3A+6360572164613275905%7D", @"word":@"博美"}];
    //    [testDict setValue:testDict1 forKey:@"source_tag"];
    //    [testDict setValue:testArr forKey:@"related_tags"];
    //    articleInfo.video_detail_tags = testDict;
//    self.sourceTag = [articleInfo.video_detail_tags valueForKey:@"source_tag"];
//    self.relatedTags = [articleInfo.video_detail_tags valueForKey:@"related_tags"];
    self.sourceBtn.hidden = YES;
    self.tagsView.hidden = YES;
    if (self.viewModel.videoDetailTags.sourceTag == nil) {
        if ([self.viewModel.videoDetailTags.relatedTagsArray isKindOfClass:[NSArray class]]) {
            NSArray *tags = [self _mappingTagsToModel:self.viewModel.videoDetailTags.relatedTagsArray];
            [self.tagsView refreshWithTagItems:[tags mutableCopy]];
        }
        self.tagsView.hidden = NO;
        wrapperTrackEvent(@"videotag_searchmore", @"show");
    } else {
        [self.sourceBtn setTitle:self.viewModel.videoDetailTags.sourceTag.word forState:UIControlStateNormal];
        self.sourceBtn.hidden = NO;
        wrapperTrackEvent(@"videotag_search", @"show");
    }
    
    [self refreshUI];
}

- (void)refreshUI {
    UIImage *img = [UIImage imageNamed:@"movie"];
    UIEdgeInsets padding = UIEdgeInsetsMake(6.f, 13.f, 6.f, 13.f);
    CGSize size = [self.sourceBtn.titleLabel sizeThatFits:CGSizeMake(self.width / 2, CGFLOAT_MAX)];
    size.width += padding.left + padding.right + img.size.width + 5;
    size.height += padding.top + padding.bottom;
    self.sourceBtn.frame = CGRectMake(0, 0, size.width, size.height);
    self.sourceBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    self.sourceBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [self.tagsView sizeToFit];
    CGFloat vH = kPadding * 2;
    if (self.tagPosition == TTVideoDetailSearchTagPositionTop || self.tagPosition == TTVideoDetailSearchTagPositionAboveComment) {
        vH -= kPadding;
    }
    if (self.viewModel.videoDetailTags.sourceTag) {
        self.height = self.sourceBtn.frame.size.height + vH;
    } else {
        self.height = self.tagsView.frame.size.height + vH;
    }
    if (self.tagPosition == TTVideoDetailSearchTagPositionAboveComment) {
        self.bottomLine.hidden = YES;
    } else {
        self.bottomLine.hidden = NO;
    }
}

-(NSArray *)_mappingTagsToModel:(NSArray *)originTagsArray{
    NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:4];
    [originTagsArray enumerateObjectsUsingBlock:^(TTVVideoDetailSourceTag * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *word = obj.word;
        NSString *schema = obj.link;
        if (!isEmptyString(word)) {
            TTTagItem *item = [[TTTagItem alloc] initWithText:word action:^{
                wrapperTrackEvent(@"videotag_searchmore", @"click");
                NSURL *url = [TTStringHelper URLWithURLString:schema];
                [[TTRoute sharedRoute] openURLByPushViewController:url];
            }];
            
            item.padding = UIEdgeInsetsMake(7.5f, 13.f, 7.5f, 13.f);
            item.style = TTTagJumpedButtonStyle;
            item.textColorThemedKey = kColorText2;
            item.highlightedTextColorThemedKey = kColorText2Highlighted;
            item.bgColorThemedKey = kColorBackground3;
            item.highlightedBgColorThemedKey = kColorBackground3Highlighted;
            item.borderColorThemedKey = kColorLine1;
            item.borderWidth = [TTDeviceHelper ssOnePixel];
            item.cornerRadius = 6.f;
            item.font = [UIFont systemFontOfSize:14.f];
            
            [tagsArray addObject:item];
            //客户端做保护，只能最多显示四个relatedTag
            if (idx >= 3){
                *stop = YES;
            }
        }
    }];
    if (!tagsArray.count) {
        return nil;
    }
    return tagsArray.copy;
}

- (void)sourceBtnClicked:(UIButton *)sender {
    wrapperTrackEvent(@"videotag_search", @"click");
    NSString *schema = self.viewModel.videoDetailTags.sourceTag.link;
    NSURL *url = [TTStringHelper URLWithURLString:schema];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

- (TTTagView *)tagsView {
    if (!_tagsView) {
        TTTagViewConfig *config = [[TTTagViewConfig alloc] init];
        config.lineSpacing = 5.f;
        config.interitemSpacing = 5.f;
        _tagsView = [[TTTagView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0) configuration:config alignment:TTTagViewAlignmentLeft];
        _tagsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tagsView.rowNumber = 1;
    }
    return _tagsView;
}

- (SSThemedButton *)sourceBtn {
    if (!_sourceBtn) {
        _sourceBtn = [[SSThemedButton alloc] init];
        _sourceBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _sourceBtn.backgroundColorThemeKey = kColorBackground3;
        _sourceBtn.highlightedBackgroundImageName = kColorBackground3Highlighted;
        _sourceBtn.titleColorThemeKey = kColorText2;
        _sourceBtn.highlightedTitleColorThemeKey = kColorText2Highlighted;
        _sourceBtn.borderColorThemeKey = kColorLine1;
        _sourceBtn.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _sourceBtn.layer.cornerRadius = 6;
        [_sourceBtn setImage:[UIImage imageNamed:@"movie"] forState:UIControlStateNormal];
        [_sourceBtn addTarget:self action:@selector(sourceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sourceBtn;
}

- (SSThemedView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel])];
        _bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        if ([TTDeviceHelper isPadDevice]) {
            _bottomLine.hidden = YES;
        }
    }
    return _bottomLine;
}

@end
