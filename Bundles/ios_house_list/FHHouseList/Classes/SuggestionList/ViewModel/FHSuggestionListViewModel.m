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

@end

@implementation FHSuggestionListViewModel

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.loadRequestTimes = 0;
        self.guessYouWantData = [NSMutableArray new];
        self.guessYouWantView = [[FHGuessYouWantView alloc] init];
    }
    return self;
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        // 历史记录
        if (indexPath.row == 0) {
            FHSuggestHeaderViewCell *headerCell = (FHSuggestHeaderViewCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestHeaderCell" forIndexPath:indexPath];
            headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return headerCell;
        }
        FHSuggestionItemCell *cell = (FHSuggestionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestItemCell" forIndexPath:indexPath];
        if (indexPath.row - 1 < self.historyData.count) {
            FHSuggestionSearchHistoryResponseDataDataModel *model  = self.historyData[indexPath.row - 1];
            cell.secondaryLabel.text = [[FHHouseTypeManager sharedInstance] stringValueForType:self.houseType];
            NSAttributedString *text1 = [self processHighlightedDefault:model.text textColorHex:@"#081f33" fontSize:15.0];
            cell.label.attributedText = text1;
        }
        return cell;
    } else if (tableView.tag == 2) {
        // 联想词列表
        if (self.houseType == FHHouseTypeNewHouse) {
            // 新房
            FHSuggestionNewHouseItemCell *cell = (FHSuggestionNewHouseItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestNewItemCell" forIndexPath:indexPath];
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
            }
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
//            // 刷新数据
//            // 埋点？
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
                
                [wself.guessYouWantView firstLineGreaterThanSecond:@"" array:model.data.data count:1];
                
                [wself.guessYouWantData addObjectsFromArray:model.data.data];
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
    __weak typeof(self) wself = self;
    self.sugHttpTask = [FHHouseListAPI requestSuggestionCityId:cityId houseType:houseType query:query class:[FHSuggestionResponseModel class] completion:^(FHSuggestionResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.sugListData = model.data;
            [wself reloadSugTableView];
            // 刷新数据
            // 埋点？
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
