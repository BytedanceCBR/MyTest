//
//  WDDetailNatantTagsView.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/18.
//

#import "WDDetailNatantTagsView.h"
#import "WDDetailModel.h"
#import "WDAnswerEntity.h"
#import <TTUIWidget/TTTagView.h>
#import <TTUIWidget/TTTagItem.h>
#import <TTUIWidget/TTTagViewConfig.h>
#import <TTRoute/TTRoute.h>

@interface WDDetailNatantTagsView ()

@property(nonatomic, strong) WDDetailModel *detailModel;
@property(nonatomic, strong) TTTagView *tagsView;

@end

@implementation WDDetailNatantTagsView

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.tagsView];
    }
    return self;
}

- (TTTagView *)tagsView {
    if (_tagsView == nil) {
        TTTagViewConfig *config = [[TTTagViewConfig alloc] init];
        config.lineSpacing = 5.f;
        config.interitemSpacing = 5.f;
        
        _tagsView = [[TTTagView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0) configuration:config alignment:TTTagViewAlignmentLeft];
        _tagsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tagsView.rowNumber = 1;
    }
    return _tagsView;
}

- (void)reloadData:(id)object {
    if (![object isKindOfClass:[WDDetailModel class]]) {
        return;
    }
    WDDetailModel *model = object;
    self.detailModel = model;
    NSArray * data = model.ordered_info[kWDDetailNatantTagsKey];
    if (![data isKindOfClass:[NSArray class]]) {
        return;
    }
    NSArray *tags = [self _mappingTagsToModel:data];
    [self.tagsView refreshWithTagItems:[tags mutableCopy]];
    
    [self refreshUI];
}

- (void)refreshUI {
    [super refreshUI];
    [self.tagsView sizeToFit];
    self.height = self.tagsView.frame.size.height;
}

- (void)trackEventIfNeeded {
    if (!self.hasShow) {
        WDAnswerEntity *answer = self.detailModel.answerEntity;
        NSDictionary * extDict = nil;
        if (answer.ansid) {
            extDict = @{@"item_id":answer.ansid};
        }
        [TTTrackerWrapper event:@"detail" // tag 还需要改，这个是文章的额
                          label:@"concern_words_show"
                          value:answer.ansid
                       extValue:nil
                      extValue2:nil
                           dict:extDict];
        self.hasShow = YES;
    }
}

- (NSArray *)_mappingTagsToModel:(NSArray *)originTagsArray{
    NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:5];
    [originTagsArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WDOrderedItemStructModel *oneItem = (WDOrderedItemStructModel *)obj;
        NSString * word = oneItem.word;
        NSString * schema = oneItem.link;
        if (!isEmptyString(word)) {
            TTTagItem *item = [[TTTagItem alloc] initWithText:word action:^{
                NSURL *url = [NSURL URLWithString:schema];
                //统计
                {
                    WDAnswerEntity *answer = self.detailModel.answerEntity;
                    NSMutableDictionary *extDict = [[NSMutableDictionary alloc] init];
                    [extDict setValue:answer.ansid forKey:@"item_id"];
                    [extDict setValue:@(idx+1) forKey:@"position"];
                    [extDict setValue:word forKey:@"keyword"];
                    [TTTrackerWrapper event:@"detail" // tag 还需要改，这个是文章的额
                                      label:@"concern_words_click"
                                      value:answer.ansid
                                   extValue:nil
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
