//
//  WDWendaListViewController+TableViewCategory.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import "WDWendaListViewController+TableViewCategory.h"
//ViewModel
#import "WDListViewModel.h"
//LayoutModel
#import "WDListCellLayoutModel.h"
//Model
#import "WDListCellDataModel.h"
#import "WDQuestionEntity.h"
#import "WDAnswerEntity.h"
//Util
#import "WDSettingHelper.h"
#import "WDParseHelper.h"
//Lib
#import <TTRoute/TTRoute.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTImpression/SSImpressionManager.h>
//Router
#import "WDListCellRouterCenter.h"

@implementation WDWendaListViewController(TableViewCategory)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.needShowEmptyView = NO;
    self.needShowFoldView = NO;
    NSInteger count = [[self.viewModel dataModelsArray] count];
    if ([self.viewModel hasMore] && count > 0) {
        count ++; // load more
    }
    else {
        // 只折叠页有回答
        if (self.viewModel.questionEntity.normalAnsCount.longLongValue > 0) {
            self.needShowFoldView = YES;
        }
        // 只列表页有回答，折叠页无回答
        else if (count > 0) {
            count ++; // no more
        }
        // 没有回答
        else {
            self.needShowEmptyView = YES;
        }
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
        WDListCellLayoutModel <WDListCellLayoutModelBaseProtocol>*cellLayoutModel = [self getCellLayoutModelFromDataModel:model];
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
        }
        else {
            state = WDLoadMoreCellStateLoading;
        }
    }
    else {
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
        [self addReadAnswerID:model.answerEntity.ansid];
        WDListCellLayoutModel <WDListCellLayoutModelBaseProtocol>*cellLayoutModel = [self getCellLayoutModelFromDataModel:model];
        UITableViewCell <WDListCellBaseProtocol>*cell = [[WDListCellRouterCenter sharedInstance] dequeueTableCellForLayoutModel:cellLayoutModel tableView:tableView indexPath:indexPath gdExtJson:self.viewModel.gdExtJson apiParams:self.viewModel.apiParameter pageType:WDWendaListRequestTypeNICE];
        if (!cell) {
            return [[UITableViewCell alloc] init];
        }
        if ([cell conformsToProtocol:@protocol(WDListCellBaseProtocol)]) { // 这步判断还有必要？
            [cell refreshWithCellLayoutModel:cellLayoutModel cellWidth:self.answerListView.width];
        }
        if ([cell conformsToProtocol:@protocol(WDListCellVideoProtocol)]) {
            UITableViewCell <WDListCellVideoProtocol>*videoCell = (UITableViewCell <WDListCellVideoProtocol>*)cell;
            if (self.adjustPosition && videoCell.videoCoverPicFrame.size.width != 0 && videoCell.videoCoverPicFrame.size.height != 0) {
                self.adjustPosition = NO;
                [self locateIndexPath:indexPath];
                [videoCell performSelector:@selector(videoPlayButtonClicked) withObject:nil afterDelay:0.1];
            }
        }
        return cell;
    }
    else {
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
            }
            else {
                [cell refreshCellWithNewState:WDLoadMoreCellStateLoading cellWidth:SSWidth(self.answerListView)];
                [self _loadMore];
            }
        }
        else {
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
        
        WDListCellLayoutModel <WDListCellLayoutModelBaseProtocol>*cellLayoutModel = [self getCellLayoutModelFromDataModel:model];
        
        NSInteger isAllWordsShow = cellLayoutModel.isShowAllAnswerText ? 1 : 0;
        NSInteger isLightAnswer = answerEntity.isLightAnswer ? answerEntity.isLightAnswer.integerValue : 0;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@(cellLayoutModel.answerLinesCount) forKey:@"show_rows"];
        [params setValue:@(isAllWordsShow) forKey:@"is_all_words_show"];
        [params setValue:@(answerEntity.contentAbstract.thumb_image_list.count) forKey:@"picture_count"];
        [params setValue:@(answerEntity.contentAbstract.video_list.count) forKey:@"video_count"];
        [params setValue:@(isLightAnswer) forKey:@"is_light_answer"];
        NSDictionary *uInfo = @{@"modelExtra":params};
        
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
             userInfo:uInfo];
        }
        
        if (answerEntity.contentAbstract.video_list.count > 0 ) {
            WDVideoInfoStructModel *videoModel = answerEntity.contentAbstract.video_list.firstObject;
            
            //友盟统计
            if (!isEmptyString(videoModel.video_id)) {
                NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                [extra addEntriesFromDictionary:self.viewModel.gdExtJson];
                [extra setValue:@"list" forKey:@"position"];
                [extra setValue:answerEntity.ansid forKey:@"value"];
                [extra setValue:videoModel.video_id forKey:@"video_id"];
                NSString *tag = [self.viewModel.gdExtJson objectForKey:@"category_name"];
                if (isEmptyString(tag)) {
                    tag = @"unknown";
                }
                NSString *clickTag = [NSString stringWithFormat:@"click_%@",tag];
                [extra setValue:clickTag forKey:@"label"];
                ttTrackEventWithCustomKeys(@"video_show", clickTag, answerEntity.ansid, nil, extra);
            }
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
    if ([cell conformsToProtocol:@protocol(WDListCellVideoProtocol)]) {
        UITableViewCell <WDListCellVideoProtocol>*videoCell = (UITableViewCell <WDListCellVideoProtocol>*)cell;
        [videoCell stopPlayingMovie];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.listViewHasScroll = YES;
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
    return self.viewModel.qID;
}

- (SSImpressionGroupType)impressionType
{
    return SSImpressionGroupTypeWendaNiceList;
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
                
                WDListCellLayoutModel <WDListCellLayoutModelBaseProtocol>*cellLayoutModel = [self getCellLayoutModelFromDataModel:dataModel];
                
                NSInteger isAllWordsShow = cellLayoutModel.isShowAllAnswerText ? 1 : 0;
                NSInteger isLightAnswer = answerEntity.isLightAnswer ? answerEntity.isLightAnswer.integerValue : 0;
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setValue:@(cellLayoutModel.answerLinesCount) forKey:@"show_rows"];
                [params setValue:@(isAllWordsShow) forKey:@"is_all_words_show"];
                [params setValue:@(answerEntity.contentAbstract.thumb_image_list.count) forKey:@"picture_count"];
                [params setValue:@(answerEntity.contentAbstract.video_list.count) forKey:@"video_count"];
                [params setValue:@(isLightAnswer) forKey:@"is_light_answer"];
                NSDictionary *uInfo = @{@"modelExtra":params};
                
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
                     userInfo:uInfo];
                }
            }
        }
    }
}

@end
