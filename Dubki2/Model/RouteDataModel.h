//
//  RouteDataModel.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RouteStep;

@interface RouteDataModel : NSObject

// Singletone Shared Instance
+ (instancetype)sharedInstance;

// Описание общежитий
@property (strong, nonatomic) NSArray<NSDictionary<NSString *, NSDictionary *> *> *dormitories;
// Описание кампусов
@property (strong, nonatomic) NSArray<NSDictionary<NSString *, NSDictionary *> *> *campuses;
// Названия станций метро
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *subways;
// Описания станций ж/д
@property (strong, nonatomic) NSDictionary<NSString *, NSDictionary *> *stations;

// Маршрут
@property (strong, nonatomic) NSMutableArray<RouteStep *> *route;


- (void)calculateRouteByDeparture:(NSDate *)departure
                     andDirection:(NSInteger)direction
                        andCampus:(NSDictionary<NSString *, NSObject*> *)campus;

- (void)calculateRouteByArrival:(NSDate *)arrival
                   andDirection:(NSInteger)direction
                      andCampus:(NSDictionary<NSString *, NSObject*> *)campus;

@end
