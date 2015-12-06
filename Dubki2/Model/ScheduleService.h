//
//  ScheduleService.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleService : NSObject

// Singletone Shared Instance
+ (instancetype)sharedInstance;

- (NSArray<NSDictionary *> *)getScheduleTrainByFrom:(NSString *)fromCode
                                              andTo:(NSString *)toCode
                                       andTimestamp:(NSDate *)timestamp;

- (NSArray<NSString *> *)getScheduleBusByFrom:(NSString *)from
                                        andTo:(NSString *)to
                                 andTimestamp:(NSDate *)timestamp;

@end
