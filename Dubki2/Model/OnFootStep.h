//
//  OnFootStep.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteStep.h"

@interface OnFootStep : RouteStep

@property (strong, nonatomic) NSString *map; // имя файла карты для показа делелей шага маршрута

- (id)initWithDeparture:(NSDate *)departure
                 andEdu:(NSDictionary<NSString *, NSObject *> *)edu;

- (id)initWithArrival:(NSDate *)arrival
               andEdu:(NSDictionary<NSString *, NSObject *> *)edu;

- (void)setNearestOnFootByDeparture:(NSDate *)departure
                             andEdu:(NSDictionary<NSString *, NSObject *> *)edu;

- (void)setNearestOnFootByArrival:(NSDate *)arrival
                           andEdu:(NSDictionary<NSString *, NSObject *> *)edu;

@end
