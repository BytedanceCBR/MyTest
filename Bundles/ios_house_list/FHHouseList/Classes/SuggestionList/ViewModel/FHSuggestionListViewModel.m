//
//  FHSuggestionListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewModel.h"
#import "FHSuggestionListViewController.h"
#import "ToastManager.h"
#import "FHHouseTypeManager.h"
#import "FHGuessYouWantView.h"
#import "FHUserTracker.h"
#import "FHHouseTypeManager.h"

@interface FHSuggestionListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic , weak) FHSuggestionListViewController *listController;
@property(nonatomic , weak) TTHttpTask *sugHttpTask;
@property(nonatomic , weak) TTHttpTask *historyHttpTask;
@property(nonatomic , weak) TTHttpTask *guessHttpTask;
@property(nonatomic , weak) TTHttpTask *delHistoryHttpTask;

@property (nonatomic, strong , nullable) NSArray<FHSuggestionResponseDataModel> *sugListData;
@property (nonatomic, strong , nullable) NSArray<FHSuggestionSearchHistoryResponseDataDataModel> *historyData;
@property (nonatomic, strong , nullable) NSMutableArray<FHGuessYouWantResponseDataDataModel> *guessYouWantData;

@property (nonatomic, copy)     NSString       *highlightedText;
@property (nonatomic, strong)   FHGuessYouWantView *guessYouWantView;
@property (nonatomic, assign)   BOOL       hasShowKeyboard;

@end

@implementation FHSuggestionListViewModel

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.loadRequestTimes = 0;
        self.guessYouWantData = [NSMutableArray new];
        self.historyShowTracerDic = [NSMutableDictionary new];
        self.associatedCount = 0;
        self.hasShowKeyboard = NO;
        [self setupGuessYouWantView];
    }
    return self;
}

- (void)setupGuessYouWantView {
    self.guessYouWantView = [[FHGuessYouWantView alloc] init];
    __weak typeof(self) wself = self;
    self.guessYouWantView.clickBlk = ^(FHGuessYouWantResponseDataDataModel * _Nonnull model) {
        [wself guessYouWantItemClick:model];
    };
}

// 猜你想搜点击
- (void)guessYouWantItemClick:(FHGuessYouWantResponseDataDataModel *)model {
    NSString *jumpUrl = model.openUrl;
    if (jumpUrl.length > 0) {
        NSString *placeHolder = [model.text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        if (placeHolder.length > 0) {
            jumpUrl = [NSString stringWithFormat:@"%@&placeholder=%@",jumpUrl,placeHolder];
        }
        NSString *queryType = @"hot"; // 猜你想搜
        NSString *pageType = [self pageTypeString];
        NSString *queryText = model.text.length > 0 ? model.text : @"be_null";
        NSDictionary *houseSearchParams = @{
                                            @"enter_query":queryText,
                                            @"search_query":queryText,
                                            @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                            @"query_type":queryType
                                            };
        NSMutableDictionary *infos = [NSMutableDictionary new];
        infos[@"houseSearch"] = houseSearchParams;
        if (model.extinfo) {
            infos[@"suggestion"] = [self createQueryCondition:model.extinfo];
        }
        NSMutableDictionary *tracer = [NSMutableDictionary new];
        tracer[@"enter_type"] = @"click";
        if (self.listController.tracerDict != NULL) {
            if (self.listController.tracerDict[@"element_from"]) {
                tracer[@"element_from"] = self.listController.tracerDict[@"element_from"];
            }
            if (self.listController.tracerDict[@"enter_from"]) {
                tracer[@"enter_from"] = self.listController.tracerDict[@"enter_from"];
            }
            if (self.listController.tracerDict[@"origin_from"]) {
                tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
            }
        }
        infos[@"tracer"] = tracer;

        [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:queryText placeholder:queryText infoDict:infos];
    }
}

// 历史记录Cell点击
- (void)historyCellClick:(FHSuggestionSearchHistoryResponseDataDataModel *)model rank:(NSInteger)rank {
    // 点击埋点
    NSDictionary *tracerDic = @{
                                @"word":model.text.length > 0 ? model.text : @"be_null",
                                @"history_id":model.historyId.length > 0 ? model.historyId : @"be_null",
                                @"rank":@(rank),
                                @"show_type":@"list"
                                };
    [FHUserTracker writeEvent:@"search_history_click" params:tracerDic];
    
    NSString *jumpUrl = model.openUrl;
    if (jumpUrl.length > 0) {
        NSString *placeHolder = [model.text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        if (placeHolder.length > 0) {
            jumpUrl = [NSString stringWithFormat:@"%@&placeholder=%@",jumpUrl,placeHolder];
        }
    }
    NSString *queryType = @"history"; // 历史记录
    NSString *pageType = [self pageTypeString];
    NSString *queryText = model.text.length > 0 ? model.text : @"be_null";
    NSDictionary *houseSearchParams = @{
                                        @"enter_query":queryText,
                                        @"search_query":queryText,
                                        @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                        @"query_type":queryType
                                        };
    
    NSMutableDictionary *infos = [NSMutableDictionary new];
    infos[@"houseSearch"] = houseSearchParams;
    if (model.extinfo) {
        infos[@"suggestion"] = [self createQueryCondition:model.extinfo];
    }
    NSMutableDictionary *tracer = [NSMutableDictionary new];
    tracer[@"enter_type"] = @"click";
    if (self.listController.tracerDict != NULL) {
        if (self.listController.tracerDict[@"element_from"]) {
            tracer[@"element_from"] = self.listController.tracerDict[@"element_from"];
        }
        if (self.listController.tracerDict[@"enter_from"]) {
            tracer[@"enter_from"] = self.listController.tracerDict[@"enter_from"];
        }
        if (self.listController.tracerDict[@"origin_from"]) {
            tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
        }
    }
    infos[@"tracer"] = tracer;
    
    [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:model.text placeholder:model.text infoDict:infos];
}

// 联想词Cell点击
- (void)associateWordCellClick:(FHSuggestionResponseDataModel *)model rank:(NSInteger)rank {
    
    // 点击埋点
    NSString *impr_id = model.logPb.imprId.length > 0 ? model.logPb.imprId : @"be_null";
    NSDictionary *tracerDic = @{
                                @"word_text":model.text.length > 0 ? model.text : @"be_null",
                                @"associate_cnt":@(self.associatedCount),
                                @"associate_type":[[FHHouseTypeManager sharedInstance] traceValueForType:self.houseType],
                                @"word_id":model.info.wordid.length > 0 ? model.info.wordid : @"be_null",
                                @"element_type":@"search",
                                @"impr_id":impr_id,
                                @"rank":@(rank)
                                };
    [FHUserTracker writeEvent:@"associate_word_click" params:tracerDic];
    
    NSString *jumpUrl = model.openUrl;
    if (jumpUrl.length > 0) {
        NSString *placeHolder = [model.text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        if (placeHolder.length > 0) {
            jumpUrl = [NSString stringWithFormat:@"%@&placeholder=%@",jumpUrl,placeHolder];
        }
    }
    NSString *queryType = @"associate"; // 联想词
    NSString *pageType = [self pageTypeString];
    NSString *inputStr = self.highlightedText.length > 0 ? self.highlightedText : @"be_null";
    NSString *queryText = model.text.length > 0 ? model.text : @"be_null";
    NSDictionary *houseSearchParams = @{
                                        @"enter_query":inputStr,
                                        @"search_query":queryText,
                                        @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                        @"query_type":queryType
                                        };
    
    NSMutableDictionary *infos = [NSMutableDictionary new];
    infos[@"houseSearch"] = houseSearchParams;
    if (model.info) {
        NSDictionary *dic = [model.info toDictionary];
        infos[@"suggestion"] = [self createQueryCondition:dic];
    }
    NSMutableDictionary *tracer = [NSMutableDictionary new];
    tracer[@"enter_type"] = @"click";
    if (self.listController.tracerDict != NULL) {
        if (self.listController.tracerDict[@"element_from"]) {
            tracer[@"element_from"] = self.listController.tracerDict[@"element_from"];
        }
        if (self.listController.tracerDict[@"enter_from"]) {
            tracer[@"enter_from"] = self.listController.tracerDict[@"enter_from"];
        }
        if (self.listController.tracerDict[@"origin_from"]) {
            tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
        }
    }
    infos[@"tracer"] = tracer;
    
    [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:model.text placeholder:model.text infoDict:infos];
}

// 删除历史记录按钮点击
- (void)deleteHisttoryBtnClick {
    [self.listController requestDeleteHistory];
}

// 联想词埋点
- (void)associateWordShow {
    NSMutableArray *wordList = [NSMutableArray new];
    for (NSInteger index = 0; index < self.sugListData.count; index ++) {
        FHSuggestionResponseDataModel *item = self.sugListData[index];
        NSDictionary *dic = @{
                              @"text":item.text.length > 0 ? item.text : @"be_null",
                              @"word_id":item.info.wordid.length > 0 ? item.info.wordid : @"be_null",
                              @"rank":@(index)
                              };
        [wordList addObject:dic];
    }
    NSError *error = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:wordList options:NSJSONReadingAllowFragments error:&error];
    NSString *wordListStr = @"";
    if (data && error == NULL) {
        wordListStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSString *impr_id = @"be_null";
    if (self.sugListData.count > 0) {
        FHSuggestionResponseDataModel *item = self.sugListData[0];
        impr_id = item.logPb.imprId.length > 0 ? item.logPb.imprId : @"be_null";
    }
    
    NSDictionary *tracerDic = @{
                                @"word_list":wordListStr.length > 0 ? wordListStr : @"be_null",
                                @"associate_cnt":@(self.associatedCount),
                                @"associate_type":[[FHHouseTypeManager sharedInstance] traceValueForType:self.houseType],
                                @"word_cnt":@(wordList.count),
                                @"element_type":@"search",
                                @"impr_id":impr_id
                                };
    [FHUserTracker writeEvent:@"associate_word_show" params:tracerDic];
}

- (NSString *)createQueryCondition:(NSDictionary *)conditionDic {
    NSString *retStr = @"";
    if ([conditionDic isKindOfClass:[NSString class]]) {
        retStr = conditionDic;
        return retStr;
    }
    NSError *error = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:conditionDic options:NSJSONReadingAllowFragments error:&error];
    if (data && error == NULL) {
        retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return retStr;
}

- (NSString *)pageTypeString {
    NSString *retPageTypeStr = @"";
    switch (self.fromPageType) {
        case FHEnterSuggestionTypeHome:
            retPageTypeStr = @"maintab";
            break;
        case FHEnterSuggestionTypeRenting:
            retPageTypeStr = @"rent_list";
            break;
        case FHEnterSuggestionTypeFindTab:
            switch (self.houseType) {
                case FHHouseTypeNeighborhood:
                    retPageTypeStr = @"findtab_neighborhood";
                    break;
                case FHHouseTypeNewHouse:
                    retPageTypeStr = @"findtab_new";
                    break;
                case FHHouseTypeSecondHandHouse:
                    retPageTypeStr = @"findtab_old";
                    break;
                case FHHouseTypeRentHouse:
                    retPageTypeStr = @"findtab_rent";
                    break;
                default:
                     retPageTypeStr = @"findtab_old";
                    break;
            }
            break;
        case FHEnterSuggestionTypeList:
            switch (self.houseType) {
                case FHHouseTypeNeighborhood:
                    retPageTypeStr = @"neighborhood_list";
                    break;
                case FHHouseTypeNewHouse:
                    retPageTypeStr = @"new_list";
                    break;
                case FHHouseTypeSecondHandHouse:
                    retPageTypeStr = @"old_list";
                    break;
                case FHHouseTypeRentHouse:
                    retPageTypeStr = @"rent_list";
                    break;
                default:
                    retPageTypeStr = @"old_list";
                    break;
            }
            break;
        default:
            retPageTypeStr = @"maintab";
            break;
    }
    return retPageTypeStr;
}

- (NSString *)categoryNameByHouseType {
    switch (self.houseType) {
        case FHHouseTypeNeighborhood:
            return @"neighborhood_list";
            break;
        case FHHouseTypeNewHouse:
            return @"new_list";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_list";
            break;
        case FHHouseTypeRentHouse:
            return @"rent_list";
            break;
        default:
            break;
    }
    return @"be_null";
}

#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        // 历史记录
        return self.historyData.count > 0 ? self.historyData.count + 1 : 0;
    } else if (tableView.tag == 2) {
        // 联想词
        return self.sugListData.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        // 历史记录
        if (indexPath.row == 0) {
            FHSuggestHeaderViewCell *headerCell = (FHSuggestHeaderViewCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestHeaderCell" forIndexPath:indexPath];
            headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            __weak typeof(self) wself = self;
            headerCell.delClick = ^{
                [wself deleteHisttoryBtnClick];
            };
            return headerCell;
        }
        FHSuggestionItemCell *cell = (FHSuggestionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestItemCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row - 1 < self.historyData.count) {
            FHSuggestionSearchHistoryResponseDataDataModel *model  = self.historyData[indexPath.row - 1];
            cell.secondaryLabel.text = [[FHHouseTypeManager sharedInstance] stringValueForType:self.houseType];
            NSAttributedString *text1 = [self processHighlightedDefault:model.listText textColorHex:@"#081f33" fontSize:15.0];
            cell.label.attributedText = text1;
            if (indexPath.row - 1 == self.sugListData.count - 1) {
                // 末尾
                [cell.label mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(cell.contentView).offset(-20);
                }];
            } else {
                [cell.label mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(cell.contentView).offset(0);
                }];
            }
        }
        return cell;
    } else if (tableView.tag == 2) {
        // 联想词列表
        if (self.houseType == FHHouseTypeNewHouse) {
            // 新房
            FHSuggestionNewHouseItemCell *cell = (FHSuggestionNewHouseItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestNewItemCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row < self.sugListData.count) {
                FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
                NSAttributedString *text1 = [self processHighlightedDefault:model.text textColorHex:@"#081f33" fontSize:15.0];
                NSAttributedString *text2 = [self processHighlightedDefault:model.text2 textColorHex:@"#a1aab3" fontSize:12.0];
                
                cell.label.attributedText = [self processHighlighted:text1 originText:model.text textColorHex:@"#299cff" fontSize:15.0];
                cell.subLabel.attributedText = [self processHighlighted:text2 originText:model.text2 textColorHex:@"#299cff" fontSize:12.0];
                
                cell.secondaryLabel.text = model.tips;
                cell.secondarySubLabel.text = model.tips2;
            }
            return cell;
        } else {
            FHSuggestionItemCell *cell = (FHSuggestionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestItemCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row < self.sugListData.count) {
                FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
                NSString *originText = model.text;
                NSAttributedString *text1 = [self processHighlightedDefault:model.text textColorHex:@"#081f33" fontSize:15.0];
                NSMutableAttributedString *resultText = [[NSMutableAttributedString alloc] initWithAttributedString:text1];
                if (model.text2.length > 0) {
                    originText = [NSString stringWithFormat:@"%@ (%@)", originText, model.text2];
                    NSAttributedString *text2 = [self processHighlightedGray:model.text2];
                    [resultText appendAttributedString:text2];
                }
                cell.label.attributedText = [self processHighlighted:resultText originText:originText textColorHex:@"#299cff" fontSize:15.0];
                cell.secondaryLabel.text = [NSString stringWithFormat:@"约%@套", model.count];
                if (indexPath.row == self.sugListData.count - 1) {
                    // 末尾
                    [cell.label mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(cell.contentView).offset(-20);
                    }];
                } else {
                    [cell.label mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(cell.contentView).offset(0);
                    }];
                }
            }
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 1) {
        // 历史记录
        if (indexPath.row - 1 < self.historyData.count) {
            FHSuggestionSearchHistoryResponseDataDataModel *model  = self.historyData[indexPath.row - 1];
            [self historyCellClick:model rank:indexPath.row - 1];
        }
    } else if (tableView.tag == 2) {
        // 联想词
        if (indexPath.row < self.sugListData.count) {
            FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
            [self associateWordCellClick:model rank:indexPath.row];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        // 历史记录
        if (self.guessYouWantData.count > 0) {
            return self.guessYouWantView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        // 历史记录
        if (self.guessYouWantData.count > 0) {
            return self.guessYouWantView.guessYouWangtViewHeight;
        } else {
            return CGFLOAT_MIN;
        }
    } else if (tableView.tag == 2) {
        // 联想词
        return CGFLOAT_MIN;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        // 历史记录 search_history_show 埋点
        if (indexPath.row - 1 < self.historyData.count) {
            FHSuggestionSearchHistoryResponseDataDataModel *model  = self.historyData[indexPath.row - 1];
            NSInteger rank = indexPath.row - 1;
            NSString *recordKey = [NSString stringWithFormat:@"%ld",rank];
            if (!self.historyShowTracerDic[recordKey]) {
                // 埋点
                self.historyShowTracerDic[recordKey] = @(YES);
                NSDictionary *tracerDic = @{
                                            @"word":model.text.length > 0 ? model.text : @"be_null",
                                            @"history_id":model.historyId.length > 0 ? model.historyId : @"be_null",
                                            @"rank":@(rank),
                                            @"show_type":@"list"
                                            };
                [FHUserTracker writeEvent:@"search_history_show" params:tracerDic];
            }
        }
    } else if (tableView.tag == 2) {
        // 联想词 associate_word_show 埋点 在 返回数据的地方进行一次性埋点
    }
}

// 1、默认
- (NSAttributedString *)processHighlightedDefault:(NSString *)text textColorHex:(NSString *)textColorHex fontSize:(CGFloat)fontSize {
    // #081f33 默认 #299cff 高亮  #8a9299  灰色
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:fontSize],NSForegroundColorAttributeName:[UIColor colorWithHexString:textColorHex]};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
    
    return attrStr;
}

// 2、部分 灰色
- (NSAttributedString *)processHighlightedGray:(NSString *)text2 {
    // #081f33 默认 #299cff 高亮  #8a9299  灰色
    NSString *retStr = [NSString stringWithFormat:@" (%@)",text2];
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:15],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#8a9299"]};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:retStr attributes:attr];
    
    return attrStr;
}

// 3、高亮
- (NSAttributedString *)processHighlighted:(NSAttributedString *)text originText:(NSString *)originText textColorHex:(NSString *)textColorHex fontSize:(CGFloat)fontSize {
    // #081f33 默认 #299cff 高亮  #8a9299  灰色
    if (self.highlightedText.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:fontSize],NSForegroundColorAttributeName:[UIColor colorWithHexString:textColorHex]};
        NSMutableAttributedString * tempAttr = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@",self.highlightedText] options:NSRegularExpressionCaseInsensitive error:nil];
        
        [regex enumerateMatchesInString:originText options:NSMatchingReportProgress range:NSMakeRange(0, originText.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            [tempAttr addAttributes:attr range:result.range];
        }];
        return tempAttr;
    } else {
        return text;
    }
    return text;
}

#pragma mark - reload

- (void)clearSugTableView {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.sugListData = NULL;
    [self reloadSugTableView];
}

- (void)clearHistoryTableView {
    if (self.historyHttpTask) {
        [self.historyHttpTask cancel];
    }
    self.historyData = NULL;
    if (self.guessHttpTask) {
        [self.guessHttpTask cancel];
    }
    [self.guessYouWantData removeAllObjects];
    [self reloadHistoryTableView];
}

- (void)reloadSugTableView {
    if (self.listController.suggestTableView != NULL) {
        [self.listController.suggestTableView reloadData];
    }
}

- (void)reloadHistoryTableView {
    if (self.listController.historyTableView != NULL && self.loadRequestTimes >= 2) {
        if (!self.hasShowKeyboard) {
            [self.listController.naviBar.searchInput becomeFirstResponder];
            self.hasShowKeyboard = YES;
        }
        [self.listController.historyTableView reloadData];
    }
}

#pragma mark - Request

- (void)requestSearchHistoryByHouseType:(NSString *)houseType {
    if (self.historyHttpTask) {
        [self.historyHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.historyHttpTask = [FHHouseListAPI requestSearchHistoryByHouseType:houseType class:[FHSuggestionSearchHistoryResponseModel class] completion:^(FHSuggestionSearchHistoryResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.historyData = model.data.data;
            [wself reloadHistoryTableView];
        } else {
            
        }
    }];
}

- (void)requestGuessYouWant:(NSInteger)cityId houseType:(NSInteger)houseType {
    if (self.guessHttpTask) {
        [self.guessHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.guessHttpTask = [FHHouseListAPI requestGuessYouWant:cityId houseType:houseType class:[FHGuessYouWantResponseModel class] completion:^(FHGuessYouWantResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        if (model != NULL && error == NULL) {
            // 构建数据源
            [wself.guessYouWantData removeAllObjects];
            if (model.data.data.count > 0) {
                // 把外部传入的搜索词放到第一个位置
                NSMutableArray *tempData = [[NSMutableArray alloc] initWithArray:model.data.data];
                NSString *text = self.homePageRollDic[@"text"];
                NSInteger houseType  = [self.homePageRollDic[@"house_type"] integerValue];
                if (text.length > 0 && houseType == self.houseType) {
                    NSInteger index = 0;
                    FHGuessYouWantResponseDataDataModel *tempModel  = [[FHGuessYouWantResponseDataDataModel alloc] init];
                    tempModel.text = text;
                    tempModel.openUrl = self.homePageRollDic[@"open_url"];
                    tempModel.guessSearchId = self.homePageRollDic[@"guess_search_id"];
                    tempModel.houseType = [NSString stringWithFormat:@"%ld",houseType];
                    for (FHGuessYouWantResponseDataDataModel *obj in tempData) {
                        if ([obj.text isEqualToString:text]) {
                            tempModel = obj;
                            [tempData removeObjectAtIndex:index];
                            break;
                        }
                        index += 1;
                    }
                    // 猜你想搜：第一行展示长度大于第二行-逻辑
                    tempData = [wself.guessYouWantView firstLineGreaterThanSecond:text array:tempData count:1];
                    
                    [tempData insertObject:tempModel atIndex:0];
                } else {
                    // 猜你想搜：第一行展示长度大于第二行-逻辑
                    tempData = [wself.guessYouWantView firstLineGreaterThanSecond:@"" array:tempData count:1];
                }
                [wself.guessYouWantData addObjectsFromArray:tempData];
                wself.guessYouWantView.guessYouWantItems = wself.guessYouWantData;
            } else {
                wself.guessYouWantView.guessYouWantItems = NULL;
            }
        } else {
            wself.guessYouWantView.guessYouWantItems = NULL;
        }
        [wself reloadHistoryTableView];
    }];
}

- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.highlightedText = query;
    self.associatedCount += 1;
    __weak typeof(self) wself = self;
    self.sugHttpTask = [FHHouseListAPI requestSuggestionCityId:cityId houseType:houseType query:query class:[FHSuggestionResponseModel class] completion:^(FHSuggestionResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.sugListData = model.data;
            [wself reloadSugTableView];
            // 埋点 associate_word_show
            [wself associateWordShow];
        } else {
            
        }
    }];
}

// 删除历史记录
- (void)requestDeleteHistoryByHouseType:(NSString *)houseType {
    if (self.delHistoryHttpTask) {
        [self.delHistoryHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.delHistoryHttpTask = [FHHouseListAPI requestDeleteSearchHistoryByHouseType:houseType class:[FHSuggestionClearHistoryResponseModel class] completion:^(FHSuggestionClearHistoryResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            wself.historyData = NULL;
            [wself reloadHistoryTableView];
        } else {
            [[ToastManager manager] showToast:@"历史记录删除失败"];
        }
    }];
}

@end
