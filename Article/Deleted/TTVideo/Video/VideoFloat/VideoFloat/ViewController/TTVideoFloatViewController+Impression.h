//
//  TTVideoFloatViewController+Impression.h
//  Article
//
//  Created by panxiang on 16/7/21.
//
//

#import "TTVideoFloatViewController.h"
#import "SSImpressionManager.h"
#import "FRPageStayManager.h"

@interface TTVideoFloatViewController (Impression)<SSImpressionProtocol,FRPageStayManagerDelegate>
- (void)expression_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)expression_tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)expression_setIsViewAppear:(BOOL)isViewAppear;
- (void)leaverPageStay;
- (void)endCellStay:(BOOL)sendTrack;
- (void)impressionDealloc;
- (void)impressionViewDidLoad;
@end
