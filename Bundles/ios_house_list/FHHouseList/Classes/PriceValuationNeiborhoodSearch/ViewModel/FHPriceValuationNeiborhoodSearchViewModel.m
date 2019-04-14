//
//  FHPriceValuationNeiborhoodSearchViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/27.
//

#import "FHPriceValuationNeiborhoodSearchViewModel.h"
#import "FHPriceValuationNeiborhoodSearchController.h"
#import "ToastManager.h"
#import "FHHouseTypeManager.h"
#import "FHGuessYouWantView.h"
#import "FHUserTracker.h"
#import "TTReachability.h"
#import "FHPriceValuationNSCell.h"

@interface FHPriceValuationNeiborhoodSearchViewModel ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic , weak) FHPriceValuationNeiborhoodSearchController *listController;
@property(nonatomic , weak) TTHttpTask *sugHttpTask;
@property (nonatomic, strong , nullable) NSArray<FHSuggestionResponseDataModel> *sugListData;
@property (nonatomic, copy)     NSString       *highlightedText;

@end

@implementation FHPriceValuationNeiborhoodSearchViewModel

-(instancetype)initWithController:(FHPriceValuationNeiborhoodSearchController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
    }
    return self;
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
        FHPriceValuationNSCell *cell = (FHPriceValuationNSCell *)[tableView dequeueReusableCellWithIdentifier:@"FHPriceValuationNSCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
        NSString *originText = model.text;
        NSAttributedString *text1 = [self processHighlightedDefault:model.text textColor:[UIColor themeGray1] fontSize:15.0];
        NSMutableAttributedString *resultText = [[NSMutableAttributedString alloc] initWithAttributedString:text1];
        cell.label.attributedText = [self processHighlighted:resultText originText:originText textColor:[UIColor themeRed1] fontSize:15.0];
        if (indexPath.row == self.sugListData.count - 1) {
            // 末尾
            cell.sepLine.hidden = YES;
        } else {
            cell.sepLine.hidden = NO;
        }
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 联想词
    if (indexPath.row < self.sugListData.count) {
        FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
        if (model && [model isKindOfClass:[FHSuggestionResponseDataModel class]]) {
            NSString *originText = model.text;
            NSString *neigbordId = model.info.neigbordId;
            [self.listController cellDidClick:originText neigbordId:neigbordId];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.highlightedText = query;
    __weak typeof(self) wself = self;
    
    self.sugHttpTask = [FHHouseListAPI requestSuggestionOnlyNeiborhoodCityId:cityId houseType:houseType query:query class:[FHSuggestionResponseModel class] completion:^(FHSuggestionResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (error.code == NSURLErrorCancelled) {
            return ;
        }
        // 正常返回
        wself.sugListData = nil;
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.sugListData = model.data;
            wself.listController.hasValidateData = YES;
            [wself reloadSugTableView];
        } else {
             wself.listController.hasValidateData = NO;
            [wself reloadSugTableView];
        }
    }];
}

- (void)clearSugTableView {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.sugListData = NULL;
    [self reloadSugTableView];
}

- (void)reloadSugTableView {
    if (self.listController.suggestTableView != NULL) {
        if (self.sugListData.count > 0) {
            // 隐藏空页面，展示列表
            self.listController.suggestTableView.hidden = NO;
            self.listController.emptyView.hidden = YES;
            [self.listController.suggestTableView reloadData];
            [self.listController.suggestTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } else {
            // 展示空页面
            self.listController.suggestTableView.hidden = YES;
            self.listController.emptyView.hidden = NO;
            if (![TTReachability isNetworkConnected]) {
                [self.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
            } else {
                // add by zyk 空页面图需要替换，合并alpha代码后替换
                [self.listController.emptyView showEmptyWithTip:@"未能找到对应小区" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
            }
        }
    }
}

@end
