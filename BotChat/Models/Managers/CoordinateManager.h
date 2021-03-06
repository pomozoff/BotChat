//
//  CoordinateManager.h
//  SimpleChat
//
//  Created by Anton Pomozov on 12.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@interface CoordinateManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

- (CLLocationCoordinate2D)currentCoordinate;

@end
