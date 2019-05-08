//
//  TTDetailNatantTagsView.m
//  Article
//
//  Created by Ray on 16/5/4.
//
//


#import "Article.h"
#import "TTTagView.h"
#import "TTTagItem.h"
#import "TTDetailModel.h"
#import "ArticleInfoManager.h"
#import "ArticleInfoManager.h"
#import "TTDetailNatantTagsView.h"
#import "TTRoute.h"
#import "TTTagViewConfig.h"
#import "TTDeviceHelper.h"

static CGFloat horizontalMargin = 0.0;

@interface TTDetailNatantTagsView ()

@property(nonatomic, strong)TTTagView * tagsView;
@property(nonatomic, strong)ArticleInfoManager * articleInfo;

@end

@implementation TTDetailNatantTagsView

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
//        [self addSubview:self.tagsView];
    }
    return self;
}

- (TTTagView *)tagsView {
    if (_tagsView == nil) {
        TTTagViewConfig *config = [[TTTagViewConfig alloc] init];
        config.lineSpacing = 5.f;
        config.interitemSpacing = 5.f;
        
        _tagsView = [[TTTagView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - horizontalMargin*2, 0) configuration:config alignment:TTTagViewAlignmentLeft];
        _tagsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tagsView.rowNumber = 1;
    }
    return _tagsView;
}

- (void)reloadData:(id)object {
    [super reloadData:object];
    if (![object isKindOfClass:[ArticleInfoManager class]]) {
        return;
    }
    ArticleInfoManager * articleInfo = (ArticleInfoManager *)object;
    self.articleInfo = articleInfo;
    NSArray * data = articleInfo.ordered_info[kDetailNatantTagsKey];
    if (![data isKindOfClass:[NSArray class]]) {
        return;
    }
    NSArray * tags = [self _mappingTagsToModel:data];
    [self.tagsView refreshWithTagItems:[tags mutableCopy]];

    [self refreshUI];
}

- (void)refreshUI {
    [super refreshUI];
    [self.tagsView sizeToFit];
    self.height = 0;
}

+ (CGFloat)topPadding {
    if ([TTDeviceHelper is568Screen]) {
        return 16.f;
    }else {
        return 21.f;
    }
}

- (void)trackEventIfNeeded{
    if (!self.hasShow) {
        Article * article = self.articleInfo.detailModel.article;
        NSDictionary * extDict = nil;
        if (article.itemID) {
            extDict = @{@"item_id":article.itemID};
        }
        [TTTrackerWrapper event:@"detail"
                   label:@"concern_words_show"
                   value:@(article.uniqueID)
                extValue:self.articleInfo.detailModel.adID
               extValue2:nil
                    dict:extDict];
        self.hasShow = YES;
    }
}

-(NSArray *)_mappingTagsToModel:(NSArray *)originTagsArray{
    NSMutableArray * tagsArray = [NSMutableArray arrayWithCapacity:5];
    [originTagsArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * word = [obj objectForKey:@"word"];
        NSString * schema = [obj objectForKey:@"link"];
        if (!isEmptyString(word)) {
            __weak typeof(self) wself = self;
            TTTagItem * item = [[TTTagItem alloc] initWithText:word action:^{
                __strong typeof(wself) self = wself;
                NSURL * url = [NSURL URLWithString:schema];
                //统计
                {
                    Article * article = self.articleInfo.detailModel.article;
                    NSMutableDictionary * extDict = [[NSMutableDictionary alloc] init];
                    [extDict setValue:article.itemID forKey:@"item_id"];
                    [extDict setValue:@(idx+1) forKey:@"position"];
                    [extDict setValue:word forKey:@"keyword"];
                    [TTTrackerWrapper event:@"detail"
                               label:@"concern_words_click"
                               value:@(article.uniqueID)
                            extValue:self.articleInfo.detailModel.adID
                           extValue2:nil
                                dict:extDict];
                }
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
        }
    }];
    return tagsArray.copy;
}

@end
