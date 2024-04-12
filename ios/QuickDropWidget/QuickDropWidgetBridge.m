//
//  QuickDropWidgetBridge.m
//  QuickDropLiveActivity
//
//  Created by Adam Cseke on 07/04/2024.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(QuickDropWidgetModule, NSObject)

+ (bool)requiresMainQueueSetup {
  return NO;
}

RCT_EXTERN_METHOD(startLiveActivity:(double)startDateTimestamp)
RCT_EXTERN_METHOD(setEndDate:(double)endDateTimestamp)
RCT_EXTERN_METHOD(setStartDate:(double)startDateTimestamp)
RCT_EXTERN_METHOD(updateHalfMinuteLeft:(BOOL)halfMinuteLeft)
RCT_EXTERN_METHOD(updateMinutesLeft:(int)minutesLeft)
RCT_EXTERN_METHOD(timerHasEnded:(BOOL)ended)
RCT_EXTERN_METHOD(stopLiveActivity)

@end
