//
//  ViewController.m
//  CrackGoogleMapPolyline
//
//  Created by nimo on 2017/8/21.
//  Copyright © 2017年 nimoAndHisFriends. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.actionBtn setTarget:self];
    [self.actionBtn setAction:@selector(goAction:)];
    
    [self.clearBtn setTarget:self];
    [self.clearBtn setAction:@selector(clearAction:)];
}

- (void)goAction:(id)sender {
    NSString *rawData = [self.inputField stringValue];
    NSString *result = [ViewController polylineWithEncodedString:rawData];
    [self.resultField setString:result];
}

- (void)clearAction:(id)sender {
    [self.inputField setStringValue:@""];
    [self.resultField setString:@""];
}

+ (NSString *)polylineWithEncodedString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    NSString *result = @"";
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        result = [NSString stringWithFormat:@"%@%f,%f;",result,finalLat,finalLon];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    return result;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
