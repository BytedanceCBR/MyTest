//
//  TTResponseModel.h
//  Forum
//
//  Created by Zhang Leonardo on 15-3-30.
//
//

#import "JSONModel.h"
#import "TTResponseModelProtocol.h"

@interface TTResponseModel : JSONModel<TTResponseModelProtocol>

@property(nonatomic, strong)NSNumber<Ignore> * _ttCreateTimeStamp;

@end
