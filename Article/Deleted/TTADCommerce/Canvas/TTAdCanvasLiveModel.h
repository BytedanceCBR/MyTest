//
//  TTAdCanvasLiveModel.h
//  Article
//
//  Created by yin on 2017/3/9.
//
//

#import <JSONModel/JSONModel.h>

@class TTAdCanvasLiveDataModel;
@interface TTAdCanvasLiveModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* live_id;
@property (nonatomic, strong)NSString<Optional>* message;
@property (nonatomic, strong)NSNumber<Optional>* code;
@property (nonatomic, strong)TTAdCanvasLiveDataModel<Optional>* data;

@end


@class TTAdCanvasLiveStatusModel;
@class TTAdCanvasLiveTimeModel;
@interface TTAdCanvasLiveDataModel : JSONModel

@property (nonatomic, strong)TTAdCanvasLiveStatusModel<Optional>* status;
@property (nonatomic, strong)TTAdCanvasLiveTimeModel<Optional>* time;

@end



@interface TTAdCanvasLiveStatusModel : JSONModel

@property (nonatomic, strong)NSNumber<Optional>* status;
@property (nonatomic, strong)NSNumber<Optional>* live_status;
@property (nonatomic, strong)NSNumber<Optional>* playback_status;


@end

@interface TTAdCanvasLiveTimeModel : JSONModel

@property (nonatomic, strong)NSNumber<Optional>* start_time;
@property (nonatomic, strong)NSNumber<Optional>* end_time;

@end




