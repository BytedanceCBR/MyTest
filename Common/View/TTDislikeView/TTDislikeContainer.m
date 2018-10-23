//
//  TTDislikeContainer.m
//  Article
//
//  Created by zhaoqin on 01/03/2017.
//
//

#import "TTDislikeContainer.h"
#import "TTDislikeViewController.h"
#import "TTActionSheetCellModel.h"
#import "TTDetailModel.h"


@interface TTDislikeContainer ()
@property (nonatomic, strong) TTDislikeViewController *dislikeViewController;
@property (nonatomic, strong) void (^complete)(NSArray *dislikeOptions, NSArray *reportOptions, NSDictionary *extraDict);
@property (nonatomic, strong) NSArray *dislikeOptions;
@property (nonatomic, strong) NSArray *reportOptions;
@property (nonatomic, strong) NSMutableDictionary *extraDict;
@end

@implementation TTDislikeContainer

- (void)insertDislikeOptions:(NSArray *)dislikeOptions reportOptions:(NSArray *)reportOptions {
    
    if (dislikeOptions && !self.dislikeOptions) {
        NSMutableArray *mutableDislikeArray = [[NSMutableArray alloc] init];
        [dislikeOptions enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTActionSheetCellModel *model = [[TTActionSheetCellModel alloc] init];
            model.identifier = [obj tt_stringValueForKey:@"id"];
            model.text = [obj tt_stringValueForKey:@"name"];
            model.isSelected = NO;
            model.source = TTActionSheetTypeDislike;
            [mutableDislikeArray addObject:model];
            if (stop) {
                self.dislikeOptions = [mutableDislikeArray copy];
            }
        }];
    }
    
    if (reportOptions && !self.reportOptions) {
        NSMutableArray *mutalbeReportArray = [[NSMutableArray alloc] init];
        [reportOptions enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTActionSheetCellModel *model = [[TTActionSheetCellModel alloc] init];
            model.identifier = [obj tt_stringValueForKey:@"type"];
            model.text = [obj tt_stringValueForKey:@"text"];
            model.isSelected = NO;
            model.source = TTActionSheetTypeReport;
            [mutalbeReportArray addObject:model];
            if (stop) {
                self.reportOptions = [mutalbeReportArray copy];
            }
        }];
        
    }
    
    [self.dislikeViewController insertDislikeOptions:self.dislikeOptions reportOptions:self.reportOptions];
    if (!self.extraDict) {
        self.extraDict = [[NSMutableDictionary alloc] init];
    }
    [self.dislikeViewController insertExtraDict:self.extraDict];
}

- (void)showDislikeViewAfterComplete:(void (^ _Nullable)(NSArray * _Nullable dislikeOptions, NSArray * _Nullable reportOptions, NSDictionary * _Nullable extraDict))complete {
    UINavigationController *topViewContrller = [TTUIResponderHelper topNavigationControllerFor:[TTUIResponderHelper topmostViewController]];
    topViewContrller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
        topViewContrller.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [topViewContrller presentViewController:self.dislikeViewController animated:NO completion:nil];
        topViewContrller.view.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    else {
        self.dislikeViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [topViewContrller presentViewController:self.dislikeViewController animated:NO completion:nil];
    }
    self.dislikeViewController.type = self.type;
    self.complete = complete;
    
}

- (TTDislikeViewController *)dislikeViewController {
    if (!_dislikeViewController) {
        _dislikeViewController = [[TTDislikeViewController alloc] init];
        _dislikeViewController.detailModel = self.detailModel;
        WeakSelf;
        _dislikeViewController.commitComplete = ^ {
            StrongSelf;
            //发送网络请求
            if (self.complete) {
                NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
                
                if (self.type == TTDislikeTypeOnlyReport) {
                    NSMutableArray *reportTypes = [[NSMutableArray alloc] init];
                    for (int i = 0; i < self.reportOptions.count; i++) {
                        TTActionSheetCellModel *model = [self.reportOptions objectAtIndex:i];
                        if (model.isSelected) {
                            [reportTypes addObject:model.identifier];
                            model.isSelected = NO;
                        }
                    }
                    if ([self.extraDict tt_stringValueForKey:@"criticism"]) {
                        [reportTypes addObject:@"0"];
                    }
                    
                    self.complete(nil, [reportTypes copy], [self.extraDict copy]);
                    [self.extraDict setValue:nil forKey:@"criticism"];
                    
                    [extra setValue:@(reportTypes.count) forKey:@"report"];
                    [extra setValue:@"report" forKey:@"style"];
                    wrapperTrackEventWithCustomKeys(@"detail", @"report_finish", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
                }
                else {
                    NSMutableArray *dislikeTypes = [[NSMutableArray alloc] init];
                    for (int i = 0; i < self.dislikeOptions.count; i++) {
                        TTActionSheetCellModel *model = [self.dislikeOptions objectAtIndex:i];
                        if (model.isSelected) {
                            [dislikeTypes addObject:model.identifier];
                            model.isSelected = NO;
                        }
                    }
                    NSMutableArray *reportTypes = [[NSMutableArray alloc] init];
                    for (int i = 0; i < self.reportOptions.count; i++) {
                        TTActionSheetCellModel *model = [self.reportOptions objectAtIndex:i];
                        if (model.isSelected) {
                            [reportTypes addObject:model.identifier];
                            model.isSelected = NO;
                        }
                    }
                    if ([self.extraDict tt_stringValueForKey:@"criticism"]) {
                        [reportTypes addObject:@"0"];
                    }
                    
                    self.complete([dislikeTypes copy], [reportTypes copy], [self.extraDict copy]);
                    [self.extraDict setValue:nil forKey:@"criticism"];
                    
                    [extra setValue:@(dislikeTypes.count) forKey:@"dislike"];
                    [extra setValue:@(reportTypes.count) forKey:@"report"];
                    [extra setValue:@"report_and_dislike" forKey:@"style"];
                    wrapperTrackEventWithCustomKeys(@"detail", @"report_and_dislike_finish", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
                }
                

            }
        };
        _dislikeViewController.dismissComplete = ^{
            StrongSelf;
            self.dislikeViewController = nil;            
        };
        _dislikeViewController.hasComplainMessage = ^(BOOL isMessage){
            StrongSelf;
            [self.dislikeViewController updateComplainMessage:isMessage];
        };
    }
    return _dislikeViewController;
}

@end
