/*
 * Copyright (c) 2024 TOKITA Hiroshi
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

// Default Arduino pin mappings for the Raspberry Pi Pico (RP2040).
// Numbers correspond to the GPxx pad on the pico_header (i.e. GPIO index).

// SPI0 (pico_spi): MISO=GP16, SS=GP17, SCK=GP18, MOSI=GP19
#define MOSI    19
#define MISO    16
#define SCK     18
#define SS      17

// I2C0 (pico_i2c0): SDA=GP4, SCL=GP5
#define SDA     4
#define SCL     5

// On-board LED is on GP25
#define LED_BUILTIN 25

#define ARDUINO_ARCH_RP2040
#define ARDUINO_RASPBERRY_PI_PICO

