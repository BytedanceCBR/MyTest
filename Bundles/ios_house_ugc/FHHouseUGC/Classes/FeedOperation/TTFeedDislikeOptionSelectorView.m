//
//  TTFeedDislikeOptionSelectorView.m
//  AWEVideoPlayer
//
//  Created by 曾凯 on 2018/7/11.
//

#import "TTFeedDislikeOptionSelectorView.h"
#import "UIViewAdditions.h"
#import "SSThemed.h"
#import "TTFeedDislikeOptionCell.h"
#import "TTFeedDislikeKeywordSelectorView.h"
#import "TTFeedPopupController.h"
#import "extobjc.h"
#import "TTFeedDislikeConfig.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>


#define CLASS_NAME(Class) NSStringFromClass([Class class])

#define OPTION_HEIGHT_SINGLE_LINE 53
#define OPTION_HEIGHT_DOUBLE_LINE 70

@interface TTFeedDislikeOptionSelectorView () <
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, copy) NSArray *options;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation TTFeedDislikeOptionSelectorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _options = @[];
        _tableView  = ({
            UITableView *tv = UITableView.new;
            tv.delegate = self;
            tv.dataSource = self;
            tv.scrollEnabled = NO;
            tv.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tv registerClass:[TTFeedDislikeOptionCell class] forCellReuseIdentifier:CLASS_NAME(TTFeedDislikeOptionCell)];
            [self addSubview:tv];
            tv;
        });
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
    
    __block NSInteger doubleLineCount = 0;
    __block NSInteger singleLineCount = 0;
    [self.options enumerateObjectsUsingBlock:^(FHFeedOperationOption *  _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
        if(option.title.length > 0 && option.subTitle.length > 0) {
            doubleLineCount += 1;
        } else {
            singleLineCount += 1;
        }
    }];
    self.contentSizeInPopup = CGSizeMake(self.width, singleLineCount * OPTION_HEIGHT_SINGLE_LINE + doubleLineCount * OPTION_HEIGHT_DOUBLE_LINE);
}

- (void)refreshWithkeywords:(NSArray<FHFeedOperationWord *> *)keywords {
    self.options = [self.class constructOptionsWithKeywords:keywords];
    [self.tableView reloadData];
}

+ (NSArray<FHFeedOperationOption *> *)constructOptionsWithKeywords:(NSArray<FHFeedOperationWord *> *)keywords {
    NSMutableArray *opts = [NSMutableArray array];
    
    if (!keywords.count) return opts;
    
    for (FHFeedOperationWord *kw in keywords) {
        FHFeedOperationOptionType optionType = [FHFeedOperationOption optionTypeForKeyword:kw];
        FHFeedOperationOption *opt = [[FHFeedOperationOption alloc] init];
        opt.type = optionType;
        opt.title = kw.title;
        opt.subTitle = kw.subTitle;
        
//        NSMutableArray<FHFeedOperationWord *> *items = [NSMutableArray array];
//        for (NSDictionary *dict in kw.items) {
//            if ([dict isKindOfClass:[NSDictionary class]]) {
//                FHFeedOperationWord *word = [[FHFeedOperationWord alloc] initWithDict:dict];
//                [items addObject:word];
//            }
//        }
    
        opt.words = kw.items;
        [opts addObject:opt];
    }
    
    return opts;
}

- (void)finishWithKeyword:(FHFeedOperationWord *)keyword optionType:(FHFeedOperationOptionType)optionType {
    if (self.selectionFinished) {
        self.selectionFinished(keyword, optionType);
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTFeedDislikeOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:CLASS_NAME(TTFeedDislikeOptionCell)];
    [cell configWithOption:self.options[indexPath.row] showSeparator:indexPath.row != self.options.count - 1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= 0 && indexPath.row < self.options.count) {
        FHFeedOperationOption *option = self.options[indexPath.row];
        BOOL isDoubleLine = option.title.length > 0 && option.subTitle.length > 0;
        return isDoubleLine ? OPTION_HEIGHT_DOUBLE_LINE : OPTION_HEIGHT_SINGLE_LINE;
    } else {
        return OPTION_HEIGHT_DOUBLE_LINE;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FHFeedOperationOption *option = self.options[indexPath.row];
    switch (option.type) {
        case FHFeedOperationOptionTypeReport: {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            if(self.dislikeTracerBlock){
                self.dislikeTracerBlock();
            }
            TTFeedDislikeKeywordSelectorView *keywordSelectorView = [[TTFeedDislikeKeywordSelectorView alloc] initWithFrame:self.bounds];
            @weakify(self);
            [keywordSelectorView setSelectionFinished:^(FHFeedOperationWord *keyword) {
                @strongify(self);
                [self finishWithKeyword:keyword optionType:option.type];
            }];
            [keywordSelectorView refreshWithOption:option];
            [self.popupController pushView:keywordSelectorView animated:true];
        }
            break;
        case FHFeedOperationOptionTypeDelete:
        case FHFeedOperationOptionTypeTop:
        case FHFeedOperationOptionTypeCancelTop:
        case FHFeedOperationOptionTypeGood:
        case FHFeedOperationOptionTypeCancelGood:
        case FHFeedOperationOptionTypeEdit:
        case FHFeedOperationOptionTypeEditList:
        case FHFeedOperationOptionTypeSelfLook: {
            [self finishWithKeyword:option.words.firstObject optionType:option.type];
        }
            break;
    }
}

@end

