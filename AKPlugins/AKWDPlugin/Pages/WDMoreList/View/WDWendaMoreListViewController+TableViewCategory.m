//
//  WDWendaMoreListViewController+TableViewCategory.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import "WDWendaMoreListViewController+TableViewCategory.h"
#import "WDLoadMoreCell.h"
#import "WDParseHelper.h"
#import "TTStringHelper.h"
#import "TTRoute.h"
#import "WDMoreListCellLayoutModel.h"
#import "WDListCellDataModel.h"
#import "WDDefines.h"
#import <TTBaseLib/UIViewAdditions.h>
#import "WDListCellRouterCenter.h"

@implementation WDWendaMoreListViewController(TableViewCategory)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self.viewModel dataModelsArray] count];
    if (count > 0) {
        count ++; // has more || no more
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[self.viewModel dataModelsArray] count]) {
        WDListCellDataModel *model = [self.viewModel.dataModelsArray objectAtIndex:indexPath.row];
        if (![[WDListCellRouterCenter sharedInstance] canRecgonizeData:model]) {
            return 0;
        }
        WDMoreListCellLayoutModel <WDListCellLayoutModelBaseProtocol>*cellLayoutModel = [self getCellLayoutModelFromDataModel:model];
        return [[WDListCellRouterCenter sharedInstance] heightForCellLayoutModel:cellLayoutModel cellWidth:self.answerListView.width];
    }
    WDLoadMoreCellState state = WDLoadMoreCellStateDefault;
    if ([self.viewModel hasMore]) {
        if ([self.viewModel latelyHasException]) {
            if (self.viewModel.isFailure) {
                state = WDLoadMoreCellStateFailure;
            }
            else if (!self.viewModel.isFinish) {
                state = WDLoadMoreCellStateLoading;
            }
        } else {
            state = WDLoadMoreCellStateLoading;
        }
    } else {
        state = WDLoadMoreCellStateNoMore;
    }
    return [WDLoadMoreCell cellHeightForState:state];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [[self.viewModel dataModelsArray] count];
    if (indexPath.row < count) {
        WDListCellDataModel *model = [self.viewModel.dataModelsArray objectAtIndex:indexPath.row];
        if (![[WDListCellRouterCenter sharedInstance] canRecgonizeData:model]) {
            return [[UITableViewCell alloc] init];
        }
        WDMoreListCellLayoutModel <WDListCellLayoutModelBaseProtocol>*cellLayoutModel = [self getCellLayoutModelFromDataModel:model];
        UITableViewCell <WDListCellBaseProtocol>*cell = [[WDListCellRouterCenter sharedInstance] dequeueTableCellForLayoutModel:cellLayoutModel tableView:tableView indexPath:indexPath gdExtJson:self.viewModel.gdExtJson apiParams:self.viewModel.apiParameter pageType:WDWendaListRequestTypeNORMAL];
        if (!cell) {
            return [[UITableViewCell alloc] init];
        }
        if ([cell conformsToProtocol:@protocol(WDListCellBaseProtocol)]) { // 这步判断还有必要？
            [cell refreshWithCellLayoutModel:cellLayoutModel cellWidth:self.answerListView.width];
        }
        return cell;
    } else {
        static NSString *moreCellIdentifier = @"moreCellIdentifier";
        WDLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
        if (!cell) {
            cell = [[WDLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreCellIdentifier];
            cell.delegate = self;
        }
        WDLoadMoreCellState state = WDLoadMoreCellStateDefault;
        if ([self.viewModel hasMore]) {
            if ([self.viewModel latelyHasException]) {
                if (self.viewModel.isFailure) {
                    state = WDLoadMoreCellStateFailure;
                }
                else if (!self.viewModel.isFinish) {
                    state = WDLoadMoreCellStateLoading;
                }
                [cell refreshCellWithNewState:state cellWidth:SSWidth(self.answerListView)];
            } else {
                state = WDLoadMoreCellStateLoading;
                [cell refreshCellWithNewState:state cellWidth:SSWidth(self.answerListView)];
                [self _loadMore];
            }
        } else {
            state = WDLoadMoreCellStateNoMore;
            [cell refreshCellWithNewState:state cellWidth:SSWidth(self.answerListView)];
        }
        if (count > 0) {
            cell.separatorAtTOP = NO;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row < [self.viewModel.dataModelsArray count]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell conformsToProtocol:@protocol(WDListCellBaseProtocol)]) {
            [(UITableViewCell <WDListCellBaseProtocol>*)cell cellDidSelected];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.viewModel.dataModelsArray count]) {
        return;
    }
    WDListCellDataModel *model = [self.viewModel.dataModelsArray objectAtIndex:indexPath.row];
    if (![[WDListCellRouterCenter sharedInstance] canRecgonizeData:model]) {
        return;
    }
    if (model.hasAnswerEntity) {
        WDAnswerEntity *answerEntity = model.answerEntity;
        //impression
        if (!isEmptyString(answerEntity.ansid)) {
            SSImpressionStatus status = SSImpressionStatusSuspend;
            //item统计开始
            if ([self _isListShowing]) {
                status = SSImpressionStatusRecording;
            }
            [[SSImpressionManager shareInstance]
             recordWendaListImpressionKeyName:[self impressionKeyName]
             ansID:answerEntity.ansid
             groupType:[self impressionType]
             status:status
             userID:answerEntity.user.userID
             userInfo:nil];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row >= [self.viewModel.dataModelsArray count]) {
        return;
    }
    WDListCellDataModel *model = [self.viewModel.dataModelsArray objectAtIndex:indexPath.row];
    if (![[WDListCellRouterCenter sharedInstance] canRecgonizeData:model]) {
        return;
    }
    if (model.hasAnswerEntity) {
        WDAnswerEntity *answerEntity = model.answerEntity;
        //item统计结束
        if (!isEmptyString(answerEntity.ansid)) {
            [[SSImpressionManager shareInstance]
             recordWendaListImpressionKeyName:[self impressionKeyName]
             ansID:answerEntity.ansid
             groupType:[self impressionType]
             status:SSImpressionStatusEnd
             userID:answerEntity.user.userID
             userInfo:nil];
        }
    }
}
 
#pragma mark - WDLoadMoreCellDelegate

- (void)loadMoreCellRequestTrigger {
    [self _loadMore];
}

#pragma mark --

- (void)_unregist
{
    [[SSImpressionManager shareInstance] removeRegist:self];
}

- (void)_regist
{
    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)_willAppear
{
    [[SSImpressionManager shareInstance]
     enterWendaListKeyName:[self impressionKeyName]
     groupType:[self impressionType]];
}

- (void)_willDisappear
{
    [[SSImpressionManager shareInstance]
     leaveWendaListKeyName:[self impressionKeyName]
     groupType:[self impressionType]];
}

- (NSString *)impressionKeyName
{
    if (isEmptyString(self.viewModel.qID)) {
        return nil;
    }
    //hack code， 添加一个空格是因为之前的类不支持同一个key name在两个列表，在发送的时候过滤, 临时写法， 避免影响其他类的统计
    return [NSString stringWithFormat:@" %@", self.viewModel.qID];
}

- (SSImpressionGroupType)impressionType
{
    return SSImpressionGroupTypeWendaNormalList;
}

#pragma mark -- SSImpressionProtocol

-(void)needRerecordImpressions
{
    if ([self.viewModel.dataModelsArray count] == 0) {
        return;
    }
    
    for (UITableViewCell *cell in [self.answerListView visibleCells]) {
        NSIndexPath *indexPath = [self.answerListView indexPathForCell:cell];
        if (indexPath.row < [self.viewModel.dataModelsArray count]) {
            WDListCellDataModel *dataModel = [self.viewModel.dataModelsArray objectAtIndex:indexPath.row];
            if (![[WDListCellRouterCenter sharedInstance] canRecgonizeData:dataModel]) {
                return;
            }
            if (dataModel.hasAnswerEntity) {
                WDAnswerEntity *answerEntity = dataModel.answerEntity;
                if (!isEmptyString(answerEntity.ansid)) {
                    SSImpressionStatus st = SSImpressionStatusSuspend;
                    if ([self _isListShowing]) {
                        st = SSImpressionStatusRecording;
                    }
                    [[SSImpressionManager shareInstance]
                     recordWendaListImpressionKeyName:[self impressionKeyName]
                     ansID:answerEntity.ansid
                     groupType:[self impressionType]
                     status:st
                     userID:answerEntity.user.userID
                     userInfo:nil];
                }
            }
        }
    }
}

@end
