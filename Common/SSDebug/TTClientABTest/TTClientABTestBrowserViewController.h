//
//  TTClientABTestBrowserViewController.h
//  Article
//
//  Created by zuopengliu on 6/11/2017.
//

#import <UIKit/UIKit.h>
#import <SSViewControllerBase.h>



/**
 客户端所有试验及结果预览
 */
@interface TTClientABTestBrowserViewController : SSViewControllerBase

@end



@class TTABLayer;
@class TTABLayerExperiment;
@interface TTExperimentResultModel : NSObject
@property (nonatomic, strong) TTABLayer *layer;
@property (nonatomic, strong) TTABLayerExperiment *hitExperiment;
@property (nonatomic, assign) NSInteger hitRandomValue;
@property (nonatomic,   copy) NSString *featureKey;
@property (nonatomic,   copy) NSString *featureValue;
@end
