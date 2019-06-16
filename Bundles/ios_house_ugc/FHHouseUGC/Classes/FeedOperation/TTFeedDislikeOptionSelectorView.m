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
#import "TTTracker.h"

#define CLASS_NAME(Class) NSStringFromClass([Class class])

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
    self.contentSizeInPopup = CGSizeMake(self.width, self.options.count * 70.0);
}

- (void)refreshWithkeywords:(NSArray<TTFeedDislikeWord *> *)keywords {
    self.options = [self.class constructOptionsWithKeywords:keywords];
    [self.tableView reloadData];
}

+ (NSArray<TTFeedDislikeOption *> *)constructOptionsWithKeywords:(NSArray<TTFeedDislikeWord *> *)keywords {
    NSMutableArray *opts = [NSMutableArray array];
    [opts addObject:({
        TTFeedDislikeOption *opt = [TTFeedDislikeOption new];
        opt.type = TTFeedDislikeOptionTypeUninterest;
        opt;
    })];
    
    if (!keywords.count) return opts;
    
    NSArray<NSDictionary *> *reportOptions = [TTFeedDislikeConfig reportOptions];
    if (reportOptions.count) {
        [opts addObject:({
            TTFeedDislikeOption *opt = [TTFeedDislikeOption new];
            opt.type = TTFeedDislikeOptionTypeReport;
            NSMutableArray<TTFeedReportWord *> *words = [NSMutableArray array];
            for (NSDictionary *ro in reportOptions) {
                [words addObject:[[TTFeedReportWord alloc] initWithDictionary:ro]];
            }
            opt.words = words;
            opt;
        })];
    }
    
    NSMutableArray<TTFeedDislikeWord *> *shieldKeywords = [NSMutableArray array];
    for (TTFeedDislikeWord *kw in keywords) {
        TTFeedDislikeOptionType optionType = [TTFeedDislikeOption optionTypeForKeyword:kw];
        switch (optionType) {
            case TTFeedDislikeOptionTypeUnfollow: {
                TTFeedDislikeOption *opt = [TTFeedDislikeOption new];
                opt.type = optionType;
                opt.words = @[kw];
                return @[opt];
            }
                break;
            case TTFeedDislikeOptionTypeUninterest: {
            }
                break;
            case TTFeedDislikeOptionTypeCommand:
            case TTFeedDislikeOptionTypeSource: {
                TTFeedDislikeOption *opt = [TTFeedDislikeOption new];
                opt.type = optionType;
                opt.words = @[kw];
                [opts addObject:opt];
            }
                break;
            case TTFeedDislikeOptionTypeShield: {
                [shieldKeywords addObject:kw];
            }
                break;
        }
    }
    
    if (shieldKeywords.count > 0) {
        TTFeedDislikeOption *opt = [TTFeedDislikeOption new];
        opt.type = TTFeedDislikeOptionTypeShield;
        opt.words = [shieldKeywords copy];
        [opts addObject:opt];
    }
    
    return [opts sortedArrayUsingComparator:^NSComparisonResult(TTFeedDislikeOption * _Nonnull obj1, TTFeedDislikeOption * _Nonnull obj2) {
        return [@(obj1.type) compare:@(obj2.type)];
    }];
}

- (void)finishWithKeyword:(TTFeedDislikeWord *)keyword optionType:(TTFeedDislikeOptionType)optionType {
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
    return 70.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTFeedDislikeOption *option = self.options[indexPath.row];
    switch (option.type) {
        case TTFeedDislikeOptionTypeShield:
        case TTFeedDislikeOptionTypeReport:
        case TTFeedDislikeOptionTypeFeedback: {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            TTFeedDislikeKeywordSelectorView *keywordSelectorView = [[TTFeedDislikeKeywordSelectorView alloc] initWithFrame:self.bounds];
            @weakify(self);
            [keywordSelectorView setSelectionFinished:^(TTFeedDislikeWord *keyword) {
                @strongify(self);
                [self finishWithKeyword:keyword optionType:option.type];
            }];
            [keywordSelectorView refreshWithOption:option];
            [self.popupController pushView:keywordSelectorView animated:true];
        }
            break;
        case TTFeedDislikeOptionTypeUnfollow:
        case TTFeedDislikeOptionTypeUninterest:
        case TTFeedDislikeOptionTypeSource:
        case TTFeedDislikeOptionTypeCommand: {
            [self finishWithKeyword:option.words.firstObject optionType:option.type];
        }
            break;
    }
    
    if (option.type == TTFeedDislikeOptionTypeShield) {
        [self trackEvent:@"dislike_menu_shielding_click" extraParameters:nil];
    } else if (option.type == TTFeedDislikeOptionTypeReport) {
        [self trackEvent:@"dislike_menu_report_click" extraParameters:nil];
    }
}

- (void)trackEvent:(NSString *)event extraParameters:(NSDictionary *)extraParameters {
    if (isEmptyString(event)) return;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (self.commonTrackingParameters) {
        [parameters addEntriesFromDictionary:self.commonTrackingParameters];
    }
    if (extraParameters) {
        [parameters addEntriesFromDictionary:extraParameters];
    }
    [TTTracker eventV3:event params:parameters];
}

@end

