//
//  NYUtilites.h
//
//  Created by Cody Dietz on 1/23/15.
//  Copyright (c) 2015 Atomicon Software. All rights reserved.
//
//  Utility functions
//

#import <Foundation/Foundation.h>
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

//Endianess Methods
+ (NSString *)littleEndianToBigEndian:(NSString *)string;
+ (NSString *)littleEndianToBigEndian:(NSString *)string bitShiftAmount:(int)shift;

//Hex Conversion Methods
+ (NSString*)hexRepresentationWithSpaces_AS:(BOOL)spaces data:(NSData *)data;
+ (NSString *)convertDecimalToHex:(NSNumber *)decimal littleEndian:(BOOL)endian;
+ (UInt32)convertDecimalToHex:(NSInteger)decimal endianSwap:(BOOL)endian bytes:(int)numBytes;
+ (NSUInteger)convertHexToDecimal:(NSString *)hexNumberString littleEndian:(BOOL)endian;
+ (NSInteger)convertHexToSignedDecimal:(NSString *)hexNumberString littleEndian:(BOOL)endian;
+ (float)convertHexToFloat:(NSString *)hexNumberString isLittleEndian:(BOOL)endian;
+ (NSString *)dataToHexadecimalString:(NSData *)data;
+ (NSString *)convertAsciiStringToHexString:(NSString *)asciiString;
+ (NSData *)convertAsciiStringToHexData:(NSString *)asciiString;
+ (NSData *)convertHexStringToHexData:(NSString *)dataString;
+ (NSString *)convertHexStringToAsciiString:(NSString *)str;

//Easy NSData to NSString
+ (NSString *)convertDataToString:(NSData *)data;

//Unzips file at path and returns as NSDictionary containing NSData objects for each file
//* Requires CBZip - Available in Pods *
+ (NSDictionary *)unzipZipFileAtPath:(NSString *)filePath;

//Time Methods
+ (NSDate *)millisecondsToStandardDate:(double)milliseconds;
+ (NSDate *)milliseconds:(long double)milliseconds toDateFormat:(NSString *)dateFormat;
+ (NSArray *)millisecondsToArray:(long double)milliseconds;
+ (NSDate *)millisecondsSinceNowToNSDate:(long double)milliseconds;
+ (NSDictionary *)convertSecondsToMHDY:(NSUInteger)seconds;
+ (NSArray *)convertNowToHex;
+ (NSArray *)convertDateTimeToHex:(NSDate *)date;

Random Number Generator
+ (int)generateRandomNumberWithLowerBounds:(NSInteger)lower upperBounds:(NSInteger)upper inclusive:(BOOL)inclusive;

//Weird but fun method for SQLite which usually returns an array containing arrays
//For single querys it is nice to have them converted to a single array containing the values
+ (NSArray *)convertArrayOfArrayToArray:(NSArray *)outer;

//Dispatch methods taking in block parameters for serial queues/groups and main queue
+ (void)dispatch_serial_group:(void (^)(void))block;
+ (void)dispatch_serial_queue:(void (^)(void))block;
+ (void)dispatch_main_queue:(void (^)(void))block;

//NSArray/NSMutableArray Methods
+ (NSArray *)splitArray:(NSArray *)array;
+ (NSArray *)chunkArray:(NSArray *)array IntoChunksSize:(NSInteger)size;
+ (NSArray *)convertAndSplitArray:(NSArray *)array;
+ (NSArray *)sortArrayOfNumbers:(NSArray *)array;
+ (NSArray *)setupArrayForProcessing:(NSArray *)array;
+ (NSArray *)setupArrayForMonitoring:(NSArray *)array;
+ (NSArray *)quicksortNumberArray:(NSArray *)numArray;
+ (void)appendArray:(NSArray *)objects toArray:(NSMutableArray *)array;
+ (NSArray *)sortArrayOfStrings:(NSArray *)stringArray;
+ (NSArray *)reversedArray:(NSArray *)reverse;

//Encryption for AES CFB 8 - Hard to find an implementation in objective-c
+ (NSArray *)aes_cfb8:(BOOL)encrypt data:(NSData *)data iv:(NSString *)ivString key:(NSString *)keyString;

//Decimal to Binary Methods
+ (NSString *)decToBin:(NSInteger)dec;
+ (char *)decimalToBinary:(int)n;

//NSString Methods
+ (NSString *)padString:(NSString *)string padWith:(NSString *)padString totalLength:(NSInteger)length padLeft:(BOOL)left;
+ (NSString *)reverseString:(NSString *)string;
+ (NSString *)substring:(NSString *)string From:(NSUInteger)from length:(NSUInteger)to;
+ (NSMutableString *)stringFromHexString:(NSString *)hexString;

//Returns whether or not the current time - start time > time alloted
+ (bool)howIsTime:(NSTimeInterval)startTime timeAllotted:(NSInteger)time;

//Calculates signal strength of CBPeripheral and returns bars
+ (NSInteger)calculateSignalStrengthForPeripheral:(CBPeripheral *)peripheral withTotalBars:(NSInteger)bars;

//Reszies UIImage
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

//CRC Calculation
+ (NSString *)calculateCRC:(NSString *)dataString;
                   forIndex:(int)index;

// NSDecimal/NSDecimalNumber Methods
+ (NSDecimalNumber *)decimalNumberForDouble:(double)doubleValue;
+ (NSDecimal)decimalValueForDouble:(double)doubleValue;
@end
