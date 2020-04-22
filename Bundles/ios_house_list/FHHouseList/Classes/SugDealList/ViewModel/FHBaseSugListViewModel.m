//
//  FHBaseSugListViewModel.m
//  FHHouseList
//
//  Created by 张静 on 2019/4/18.
//

#import "FHBaseSugListViewModel.h"
#import "FHBaseSugListViewModel+Internal.h"
#import "FHSuggestionItemCell.h"
#import "Masonry.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <TTRoute/TTRoute.h>
#import <FHHouseBase/FHHouseSuggestionDelegate.h>
#import "FHBaseSugListViewModel+dealList.h"
#import "FHBaseSugListViewModel+priceValuation.h"
#import <FHHouseBase/FHEnvContext.h>
#import "FHSuggestionItemCell.h"
#import <FHHouseBase/FHBaseViewController.h>
#import <FHCommonUI/FHSearchBar.h>
#import "FHPriceValuationNSCell.h"
#import "FHPriceValuationNSearchView.h"
#import <FHCommonUI/FHErrorView.h>

@implementation FHBaseSugListViewModel

- (instancetype)initWithTableView:(UITableView *)tableView paramObj:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        self.suggestTableView = tableView;
        if (paramObj.allParams[@"delegate"]) {
            
            NSHashTable<FHHouseSuggestionDelegate> *temp_delegate = paramObj.allParams[@"delegate"];
            self.delegate = temp_delegate.anyObject;
        }
        if (paramObj.allParams[@"sug_delegate"]) {
            
            NSHashTable<FHHouseSuggestionDelegate> *sug_delegate = paramObj.allParams[@"sug_delegate"];
            self.suggestDelegate = sug_delegate.anyObject;
            NSHashTable *back_vc = paramObj.allParams[@"need_back_vc"]; // pop方式返回某个页面
            self.backListVC = back_vc.anyObject;  // 需要返回到的某个列表页面
            
        }
        
        [tableView registerClass:[FHSuggestionItemCell class] forCellReuseIdentifier:@"suggestItemCell"];
        [tableView registerClass:[FHPriceValuationNSCell class] forCellReuseIdentifier:@"FHPriceValuationNSCell"];
        tableView.delegate  = self;
        tableView.dataSource = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledTextChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];

    }
    return self;
}

- (void)setEmptyView:(FHErrorView *)emptyView
{
    _emptyView = emptyView;
    __weak typeof(self)wself = self;
    UITextField *textField = nil;
    if (self.searchType == FHSugListSearchTypeNeighborDealList) {
        textField = self.naviBar.searchInput;
    }else if (self.searchType == FHSugListSearchTypePriceValuation) {
        textField = self.searchView.searchInput;
    }
    emptyView.retryBlock = ^{
        if (textField.text > 0) {
            [wself requestSuggestion:textField.text];
        }
    };
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)requestSuggestion:(NSString *)text
{
    FHEmptyMaskViewType emptyType = FHEmptyMaskViewTypeNoNetWorkAndRefresh;
    if (![TTReachability isNetworkConnected]) {
        [self.listController.emptyView showEmptyWithType:emptyType];
        return;
    }
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    if (cityId) {
        // 小区搜索
        if (self.searchType == FHSugListSearchTypeNeighborDealList) {
            [self requestNeighborDealSuggestion:cityId houseType:self.houseType query:text searchType:@"neighborhood_deal"];
        }else if (self.searchType == FHSugListSearchTypePriceValuation) {
            [self requestSuggestion:cityId houseType:self.houseType query:text];
        }
    }
}

- (void)setNaviBar:(FHSearchBar *)naviBar
{
    _naviBar = naviBar;
    if (self.searchType == FHSugListSearchTypeNeighborDealList) {
        [_naviBar setSearchPlaceHolderText:@"请输入小区/商圈/地铁"];
    }
    _naviBar.searchInput.delegate = self;
}

- (void)setSearchView:(FHPriceValuationNSearchView *)searchView
{
    _searchView = searchView;
    _searchView.searchInput.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [self.naviBar.searchInput resignFirstResponder];
    [self.searchView.searchInput resignFirstResponder];
}

#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sugListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.sugListData.count) {
        if (self.searchType == FHSugListSearchTypeNeighborDealList) {

            FHSuggestionItemCell *cell = (FHSuggestionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestItemCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
            NSString *originText = model.text;
            NSAttributedString *text1 = [self processHighlightedDefault:model.text textColor:[UIColor themeGray1] fontSize:15.0];
            NSMutableAttributedString *resultText = [[NSMutableAttributedString alloc] initWithAttributedString:text1];
            if (model.text2.length > 0) {
                originText = [NSString stringWithFormat:@"%@ (%@)", originText, model.text2];
                NSAttributedString *text2 = [self processHighlightedGray:model.text2];
                [resultText appendAttributedString:text2];
            }
            cell.label.attributedText = [self processHighlighted:resultText originText:originText textColor:[UIColor themeOrange1] fontSize:15.0];
            cell.secondaryLabel.text = model.tips;
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
            return cell;
        } else if (self.searchType == FHSugListSearchTypePriceValuation) {
            FHPriceValuationNSCell *cell = (FHPriceValuationNSCell *)[tableView dequeueReusableCellWithIdentifier:@"FHPriceValuationNSCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
            NSString *originText = model.text;
            NSAttributedString *text1 = [self processHighlightedDefault:model.text textColor:[UIColor themeGray1] fontSize:15.0];
            NSMutableAttributedString *resultText = [[NSMutableAttributedString alloc] initWithAttributedString:text1];
            cell.label.attributedText = [self processHighlighted:resultText originText:originText textColor:[UIColor themeOrange1] fontSize:15.0];
            if (indexPath.row == self.sugListData.count - 1) {
                // 末尾
                cell.sepLine.hidden = YES;
            } else {
                cell.sepLine.hidden = NO;
            }
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 联想词
    if (indexPath.row < self.sugListData.count) {
        FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
        if (model && [model isKindOfClass:[FHSuggestionResponseDataModel class]]) {
            if (self.searchType == FHSugListSearchTypePriceValuation) {
                
                NSString *originText = model.text;
                NSString *neigbordId = model.info.neigbordId;
                [self cellDidClick:originText neigbordId:neigbordId];
            }else if (self.searchType == FHSugListSearchTypeNeighborDealList) {
                NSString *pageType = [self pageTypeString];
                NSString *queryText = model.text.length > 0 ? model.text : @"be_null";
                NSString *queryType = @"associate"; // 订阅搜索
                NSDictionary *houseSearchParams = @{
                                                    @"enter_query":queryText,
                                                    @"search_query":queryText,
                                                    @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                                    @"query_type":queryType
                                                    };
                NSMutableDictionary *infos = [NSMutableDictionary new];
                infos[@"houseSearch"] = houseSearchParams;
                
                NSMutableDictionary *tracer = [NSMutableDictionary new];
                if (self.listController.tracerDict[@"origin_from"]) {
                    tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
                }
                infos[@"tracer"] = tracer;
                [self jumpToDealListVCByUrl:model.openUrl infoDict:infos];
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchType == FHSugListSearchTypeNeighborDealList) {
        if (indexPath.row == self.sugListData.count - 1) {
            return 61;
        } else {
            return 41;
        }
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

// 文本框文字变化，进行sug请求
- (void)textFiledTextChangeNoti:(NSNotification *)noti
{
    NSInteger maxCount = 80;
    NSString *text = nil;
    UITextField *textField = nil;
    if (self.searchType == FHSugListSearchTypePriceValuation) {
        textField = self.searchView.searchInput;
    } else {
        textField = self.naviBar.searchInput;
    }
    text = textField.text;
    UITextRange *selectedRange = [textField markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，说明不是拼音输入
    if (position) {
        return;
    }

    if (text.length > maxCount) {
        text = [text substringToIndex:maxCount];
        self.naviBar.searchInput.text = text;
    }
    FHEmptyMaskViewType emptyType = FHEmptyMaskViewTypeNoNetWorkAndRefresh;
    if (![TTReachability isNetworkConnected]) {
        [self.listController.emptyView showEmptyWithType:emptyType];
        return;
    }
    BOOL hasText = text.length > 0;
    if (hasText) {
        [self requestSuggestion:text];
    } else {
        // 清空sug列表数据
        [self clearSugTableView];
        self.emptyView.hidden = YES;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:textField.text];
    [content replaceCharactersInRange:range withString:string];
//    NSLog(@"zjing---textField:%@,content:%@,string:%@",textField.text,content,string);
    if (content.length > MAX_INPUT) {
        return NO;
    }
    return YES;
}

// 输入框执行搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *content =  [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *result  =  [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (result.length > 0 && ![result isEqualToString:self.highlightedText]) {
        [self requestSuggestion:textField.text];
    } else {
        if (self.searchType == FHSugListSearchTypeNeighborDealList) {
            // 拼接URL
            NSString * fullText = [textField.text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
            NSString * placeHolderStr = fullText;
            NSString *pageType = [self pageTypeString];
            NSString *queryText = placeHolderStr.length > 0 ? placeHolderStr : @"be_null";
            NSString *openUrl = [NSString stringWithFormat:@"sslocal://neighborhood_deal_list?house_type=%ld&full_text=%@",self.houseType,placeHolderStr];
            NSString *queryType = @"enter";
            NSDictionary *houseSearchParams = @{
                                                @"enter_query":queryText,
                                                @"search_query":queryText,
                                                @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                                @"query_type":queryType
                                                };
            NSMutableDictionary *infos = [NSMutableDictionary new];
            infos[@"houseSearch"] = houseSearchParams;
            
            NSMutableDictionary *tracer = [NSMutableDictionary new];
            if (self.listController.tracerDict[@"origin_from"]) {
                tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
            }
            infos[@"tracer"] = tracer;
            [self jumpToDealListVCByUrl:openUrl infoDict:infos];
        }
    }
    return YES;
}

// 1、默认
- (NSAttributedString *)processHighlightedDefault:(NSString *)text textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize {
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:fontSize],NSForegroundColorAttributeName:textColor};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
    
    return attrStr;
}

// 2、部分 灰色
- (NSAttributedString *)processHighlightedGray:(NSString *)text2 {
    NSString *retStr = [NSString stringWithFormat:@" (%@)",text2];
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:15],NSForegroundColorAttributeName:[UIColor themeGray3]};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:retStr attributes:attr];
    
    return attrStr;
}

// 3、高亮
- (NSAttributedString *)processHighlighted:(NSAttributedString *)text originText:(NSString *)originText textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize {
    if (self.highlightedText.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:fontSize],NSForegroundColorAttributeName:textColor};
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

- (void)jumpToDealListVCByUrl:(NSString *)jumpUrl infoDict:(NSDictionary *)infos {
    NSString *openUrl = jumpUrl;
    if (self.suggestDelegate != NULL) {
        // 1、suggestDelegate说明需要回传sug数据
        // 2、如果是从租房大类页和二手房大类页向下个页面跳转，则需要移除搜索列表相关的页面
        // 3、如果是从列表页和找房Tab列表页进入搜索，则还需pop到对应的列表页
        NSMutableDictionary *tempInfos = [NSMutableDictionary dictionaryWithDictionary:infos];
        if (self.backListVC == nil) {
            // 需要移除搜索列表相关页面
            tempInfos[@"fh_needRemoveLastVC_key"] = @(YES);
            tempInfos[@"fh_needRemoveedVCNamesString_key"] = @[@"FHBaseSugListViewController"];
        }
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:tempInfos];
        // 回传数据，外部pop 页面
        TTRouteObject *obj = [[TTRoute sharedRoute] routeObjWithOpenURL:[NSURL URLWithString:openUrl] userInfo:userInfo];
        if ([self.suggestDelegate respondsToSelector:@selector(suggestionSelected:)]) {
            [self.suggestDelegate suggestionSelected:obj];// 部分-内部有页面跳转逻辑
        }
        if (self.backListVC) {
            [self.listController.navigationController popToViewController:self.backListVC animated:YES];
        }
    } else {
        // 不需要回传sug数据，以及自己控制页面跳转和移除逻辑
        NSMutableDictionary *tempInfos = [NSMutableDictionary dictionaryWithDictionary:infos];
        // 跳转页面之后需要移除当前页面，如果从home和找房tab叫起，则当用户跳转到列表页，则后台关闭此页面
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:tempInfos];
        
        NSURL *url = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)cellDidClick:(NSString *)text neigbordId:(NSString *)neigbordId
{
    if (text.length > 0 && self.delegate && [self.delegate respondsToSelector:@selector(callBackDataInfo:)]) {
        NSDictionary *dicInfo = @{
                                  @"neighborhood_name":text,
                                  @"neighborhood_id":neigbordId,
                                  };
        [self.delegate callBackDataInfo:dicInfo];
        [self.listController.navigationController popViewControllerAnimated:YES];
    }
}


- (void)clearSugTableView
{
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.sugListData = NULL;
    [self reloadSugTableView];
}

- (void)reloadSugTableView
{
    if (self.suggestTableView != NULL) {
        if (self.sugListData.count > 0) {
            // 隐藏空页面，展示列表
            self.suggestTableView.hidden = NO;
            self.listController.emptyView.hidden = YES;
            [self.suggestTableView reloadData];
            [self.suggestTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } else {
            // 展示空页面
            self.suggestTableView.hidden = YES;
            self.listController.emptyView.hidden = NO;
            if (![TTReachability isNetworkConnected]) {
                [self.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            } else {
                if (self.searchType == FHSugListSearchTypePriceValuation) {
                    [self.listController.emptyView showEmptyWithTip:@"未能找到对应小区" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
                }else {
                    self.listController.emptyView.hidden = YES;
                }
            }
        }
    }
}

- (NSString *)pageTypeString
{
    if (self.searchType == FHSugListSearchTypeNeighborDealList) {
        return @"neighborhood_trade_list";
    }
    return @"be_null";
}

@end
