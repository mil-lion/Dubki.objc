//
//  TrainStep.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteStep.h"

@interface TrainStep : RouteStep

@property (strong, nonatomic) NSString *url; // ссылка на расписание

- (id)initWithDeparture:(NSDate *)departure
                andFrom:(NSDictionary<NSString *, NSObject *> *)from
                  andTo:(NSDictionary<NSString *, NSObject *> *)to;

- (id)initWithArrival:(NSDate *)arrival
              andFrom:(NSDictionary<NSString *, NSObject *> *)from
                andTo:(NSDictionary<NSString *, NSObject *> *)to;

- (void)setNearestTrainByDeparture:(NSDate *)departure
                           andFrom:(NSDictionary<NSString *, NSObject *> *)from
                             andTo:(NSDictionary<NSString *, NSObject *> *)to;

- (void)setNearestTrainByArrival:(NSDate *)arrival
                         andFrom:(NSDictionary<NSString *, NSObject *> *)from
                           andTo:(NSDictionary<NSString *, NSObject *> *)to;

@end
