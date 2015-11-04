//
//  NYUtilites.h
//  metolius_concept_ios7_A1
//
//  Created by Cody Dietz on 1/23/15.
//  Copyright (c) 2015 FCS. All rights reserved.
//
//  Utility functions
//

#import <Foundation/Foundation.h>
#import "HexObject.h"
#import "AsyncController.h"
#import <zlib.h>
#include <CommonCrypto/CommonCrypto.h>

@import CoreBluetooth;

@class DataField;

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT

@class HexObject;

@interface NYUtilites : NSObject

// Getter Methods
+(NSInteger)getStatusFromModbusHexString:(NSString *)hexString;
+(NSInteger)getSizeFromModbusHexString:(NSString *)hexString;
+(NSInteger)getDataFromModbusHexString:(NSString *)hexString;
+(NSInteger)getCrc32FromModbusHexString:(NSString *)hexString;

// Endian Methods
+(NSString *)littleEndianToBigEndian:(NSString *)string;
+(NSString *)littleEndianToBigEndian:(NSString *)string bitShiftAmount:(int)shift;

// Conversion Methods
+(NSString*)hexRepresentationWithSpaces_AS:(BOOL)spaces data:(NSData *)data;
+(NSString *)convertDecimalToHex:(NSNumber *)decimal littleEndian:(BOOL)endian;
+(UInt32)convertDecimalToHex:(NSInteger)decimal endianSwap:(BOOL)endian bytes:(int)numBytes;
+(NSUInteger)convertHexToDecimal:(NSString *)hexNumberString littleEndian:(BOOL)endian;

+ (NSInteger)convertHexToSignedDecimal:(NSString *)hexNumberString littleEndian:(BOOL)endian;

+(float)convertHexToFloat:(NSString *)hexNumberString isLittleEndian:(BOOL)endian;
+(NSString *)dataToHexadecimalString:(NSData *)data;
+(NSString *)floatToFormattedString:(float)data;

+ (NSString *)convertAsciiStringToHexString:(NSString *)asciiString;

+ (NSData *)convertAsciiStringToHexData:(NSString *)asciiString;

+ (NSString *)convertDataToString:(NSData *)data;

+ (NSDictionary *)unzipZipFileAtPath:(NSString *)filePath;

+ (NSDate *)millisecondsToStandardDate:(double)milliseconds;

+ (NSDate *)milliseconds:(long double)milliseconds toDateFormat:(NSString *)dateFormat;

+ (NSArray *)millisecondsToArray:(long double)milliseconds;

+ (NSDate *)millisecondsSinceNowToNSDate:(long double)milliseconds;

// Extraneous Methods
+(void)test;


+ (int)generateRandomNumberWithLowerBounds:(NSInteger)lower upperBounds:(NSInteger)upper inclusive:(BOOL)inclusive;

+ (NSArray *)convertArrayOfArrayToArray:(NSArray *)outer;

+ (void)dispatch_serial_group:(void (^)(void))block;

+ (void)dispatch_serial_queue:(void (^)(void))block;

+ (void)dispatch_main_queue:(void (^)(void))block;

+ (NSArray *)splitArray:(NSArray *)array;

+ (NSArray *)chunkArray:(NSArray *)array IntoChunksSize:(NSInteger)size;

+ (NSArray *)convertAndSplitArray:(NSArray *)array;

+ (NSArray *)sortArrayOfNumbers:(NSArray *)array;

+ (NSArray *)setupArrayForProcessing:(NSArray *)array;

+ (NSArray *)setupArrayForMonitoring:(NSArray *)array;

+ (NSArray *)quicksortNumberArray:(NSArray *)numArray;

+ (void)appendArray:(NSArray *)objects toArray:(NSMutableArray *)array;

+ (NSArray *)aes_cfb8:(BOOL)encrypt data:(NSData *)data iv:(NSString *)ivString key:(NSString *)keyString;

+ (NSData *)convertHexStringToHexData:(NSString *)dataString;

+ (NSString *)decToBin:(NSInteger)dec;


+ (NSString *)padString:(NSString *)string padWith:(NSString *)padString totalLength:(NSInteger)length padLeft:(BOOL)left;

+ (NSString *)reverseString:(NSString *)string;

+(char *)decimalToBinary:(int)n;
+(bool)howIsTime:(NSTimeInterval)startTime timeAllotted:(NSInteger)time;

+(NSInteger)calculateSignalStrengthForPeripheral:(CBPeripheral *)peripheral withTotalBars:(NSInteger)bars;

+ (NSArray *)sortArrayOfStrings:(NSArray *)stringArray;

+ (NSString *)convertHexStringToAsciiString:(NSString *)str;

+(NSArray *)sortFirmwareZipFileArray:(NSDictionary *)array;

+(void)showSettingsSavedSuccess;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (NSDictionary *)convertSecondsToMHDY:(NSUInteger)seconds;

+ (NSArray *)convertNowToHex;

+ (NSArray *)convertDateTimeToHex:(NSDate *)date;

+ (NSString *)substring:(NSString *)string From:(NSUInteger)from length:(NSUInteger)to;

+ (NSDecimalNumber *)divideValue:(NSDecimalNumber *)valueFloat
                      forAddress:(NSString *)address
                        forIndex:(int)index;

+ (BOOL)checkBoundsForValue:(float)valueFloat
                 forAddress:(NSString *)address
                   forIndex:(int)index;

+ (BOOL)canWrite:(DataField *)dataField;

+ (NSMutableString *)stringFromHexString:(NSString *)hexString;

+ (NSString *)formatFirmwareVersion:(NSString *)version;

+ (NSURL *)writeStringToFile:(NSString *)data;

+ (NSString *)calculateCRC:(NSString *)dataString;

+ (NSArray *)reversedArray:(NSArray *)reverse;
@end
