//
//  TTExpermimentPreviewViewController.h
//  Article
//
//  Created by zuopengliu on 6/11/2017.
//

#import <UIKit/UIKit.h>
#import <SSViewControllerBase.h>



/**
 客户端具体某个实验数据预览
 */
@class TTExperimentResultModel;
@interface TTExpermimentPreviewViewController : SSViewControllerBase

- (void)showExperiment:(TTExperimentResultModel *)experimentData;

@end
