//
//  TTCertificationOperationView.h
//  Article
//
//  Created by wangdi on 2017/5/17.
//
//

#import "TTAlphaThemedButton.h"

typedef enum {
    TTCertificationOperationViewStyleRed,
    TTCertificationOperationViewStyleGray,
    TTCertificationOperationViewStyleLightRed,
}TTCertificationOperationViewStyle;

@interface TTCertificationOperationView : TTAlphaThemedButton

@property (nonatomic, assign) TTCertificationOperationViewStyle style;

@end
