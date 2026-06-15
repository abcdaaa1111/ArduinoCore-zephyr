/*
 * SPDX-FileCopyrightText: 2019-2025 SiFli Technologies(Nanjing) Co., Ltd
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * CMSIS device "core" header for SF32LB52X.
 *
 * This header contains ONLY the processor/core level definitions that Zephyr's
 * CMSIS integration (<cmsis_core.h> -> <soc.h>) requires SoC-wide:
 *   - the IRQn_Type interrupt number enumeration
 *   - the Cortex-M33 (Star-MC1) core configuration macros
 *   - the CMSIS core peripheral header (core_cm33.h)
 *
 * It deliberately does NOT pull in any of the individual IP register headers
 * (usart.h, spi.h, i2c.h, ...) or the peripheral base-address map. Those live
 * in <register.h> and are only needed by the HAL and the peripheral drivers.
 *
 * Keeping this split lets <soc.h> expose the core device definition to every
 * translation unit (and to the Arduino/LLEXT EDK) without dragging the whole
 * generic-named peripheral register map onto the global include path.
 */

#ifndef _SF32LB52X_DEVICE_H_
#define _SF32LB52X_DEVICE_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifdef SOC_BF0_HCPU

/* -------------------------  Interrupt Number Definition  ------------------------ */
typedef enum IRQn
{
    /* -------------------  Processor Exceptions Numbers  ----------------------------- */
    NonMaskableInt_IRQn           = -14,     /*  2 Non Maskable Interrupt */
    HardFault_IRQn                = -13,     /*  3 HardFault Interrupt */
    MemoryManagement_IRQn         = -12,     /*  4 Memory Management Interrupt */
    BusFault_IRQn                 = -11,     /*  5 Bus Fault Interrupt */
    UsageFault_IRQn               = -10,     /*  6 Usage Fault Interrupt */
    SecureFault_IRQn              =  -9,     /*  7 Secure Fault Interrupt */
    SVCall_IRQn                   =  -5,     /* 11 SV Call Interrupt */
    DebugMonitor_IRQn             =  -4,     /* 12 Debug Monitor Interrupt */
    PendSV_IRQn                   =  -2,     /* 14 Pend SV Interrupt */
    SysTick_IRQn                  =  -1,     /* 15 System Tick Interrupt */

    /* -------------------  Processor Interrupt Numbers  ------------------------------ */
    AON_IRQn                      =   0,
    BLE_MAC_IRQn                  =   1,
    DMAC2_CH1_IRQn                =   2,
    DMAC2_CH2_IRQn                =   3,
    DMAC2_CH3_IRQn                =   4,
    DMAC2_CH4_IRQn                =   5,
    DMAC2_CH5_IRQn                =   6,
    DMAC2_CH6_IRQn                =   7,
    DMAC2_CH7_IRQn                =   8,
    DMAC2_CH8_IRQn                =   9,
    PATCH_IRQn                    =  10,
    DM_MAC_IRQn                   =  11,
    USART4_IRQn                   =  12,
    USART5_IRQn                   =  13,
    SECU2_IRQn                    =  14,
    BT_MAC_IRQn                   =  15,
    BTIM3_IRQn                    =  16,
    BTIM4_IRQn                    =  17,
    PTC2_IRQn                     =  18,
    LPTIM3_IRQn                   =  19,
    GPIO2_IRQn                    =  20,
    HPSYS0_IRQn                   =  21,
    HPSYS1_IRQn                   =  22,
    Interrupt23_IRQn              =  23,
    Interrupt24_IRQn              =  24,
    Interrupt25_IRQn              =  25,
    Interrupt26_IRQn              =  26,
    Interrupt27_IRQn              =  27,
    Interrupt28_IRQn              =  28,
    Interrupt29_IRQn              =  29,
    Interrupt30_IRQn              =  30,
    Interrupt31_IRQn              =  31,
    Interrupt32_IRQn              =  32,
    Interrupt33_IRQn              =  33,
    Interrupt34_IRQn              =  34,
    Interrupt35_IRQn              =  35,
    Interrupt36_IRQn              =  36,
    Interrupt37_IRQn              =  37,
    Interrupt38_IRQn              =  38,
    Interrupt39_IRQn              =  39,
    Interrupt40_IRQn              =  40,
    Interrupt41_IRQn              =  41,
    Interrupt42_IRQn              =  42,
    Interrupt43_IRQn              =  43,
    Interrupt44_IRQn              =  44,
    Interrupt45_IRQn              =  45,
    LPTIM1_IRQn                   =  46,
    LPTIM2_IRQn                   =  47,
    PMUC_IRQn                     =  48,
    RTC_IRQn                      =  49,
    DMAC1_CH1_IRQn                =  50,
    DMAC1_CH2_IRQn                =  51,
    DMAC1_CH3_IRQn                =  52,
    DMAC1_CH4_IRQn                =  53,
    DMAC1_CH5_IRQn                =  54,
    DMAC1_CH6_IRQn                =  55,
    DMAC1_CH7_IRQn                =  56,
    DMAC1_CH8_IRQn                =  57,
    LCPU2HCPU_IRQn                =  58,
    USART1_IRQn                   =  59,
    SPI1_IRQn                     =  60,
    I2C1_IRQn                     =  61,
    EPIC_IRQn                     =  62,
    LCDC1_IRQn                    =  63,
    I2S1_IRQn                     =  64,
    GPADC_IRQn                    =  65,
    EFUSEC_IRQn                   =  66,
    AES_IRQn                      =  67,
    PTC1_IRQn                     =  68,
    TRNG_IRQn                     =  69,
    GPTIM1_IRQn                   =  70,
    GPTIM2_IRQn                   =  71,
    BTIM1_IRQn                    =  72,
    BTIM2_IRQn                    =  73,
    USART2_IRQn                   =  74,
    SPI2_IRQn                     =  75,
    I2C2_IRQn                     =  76,
    EXTDMA_IRQn                   =  77,
    I2C4_IRQn                     =  78,
    SDMMC1_IRQn                   =  79,
    Interrupt80_IRQn              =  80,
    Interrupt81_IRQn              =  81,
    PDM1_IRQn                     =  82,
    Interrupt83_IRQn              =  83,
    GPIO1_IRQn                    =  84,
    MPI1_IRQn                     =  85,
    MPI2_IRQn                     =  86,
    Interrupt87_IRQn              =  87,
    Interrupt88_IRQn              =  88,
    EZIP_IRQn                     =  89,
    AUDPRC_IRQn                   =  90,
    TSEN_IRQn                     =  91,
    USBC_IRQn                     =  92,
    I2C3_IRQn                     =  93,
    ATIM1_IRQn                    =  94,
    USART3_IRQn                   =  95,
    AUD_HP_IRQn                   =  96,
    Interrupt97_IRQn              =  97,
    SECU1_IRQn                    =  98,
    HCPU2LCPU_IRQn                =  -1,
    /* Interrupts 99 .. 479 are left out */
} IRQn_Type;


#else       /*LCPU*/

typedef enum IRQn
{
    /* -------------------  Processor Exceptions Numbers  ----------------------------- */
    NonMaskableInt_IRQn           = -14,     /*  2 Non Maskable Interrupt */
    HardFault_IRQn                = -13,     /*  3 HardFault Interrupt */
    MemoryManagement_IRQn         = -12,     /*  4 Memory Management Interrupt */
    BusFault_IRQn                 = -11,     /*  5 Bus Fault Interrupt */
    UsageFault_IRQn               = -10,     /*  6 Usage Fault Interrupt */
    SecureFault_IRQn              =  -9,     /*  7 Secure Fault Interrupt */
    SVCall_IRQn                   =  -5,     /* 11 SV Call Interrupt */
    DebugMonitor_IRQn             =  -4,     /* 12 Debug Monitor Interrupt */
    PendSV_IRQn                   =  -2,     /* 14 Pend SV Interrupt */
    SysTick_IRQn                  =  -1,     /* 15 System Tick Interrupt */

    /* -------------------  Processor Interrupt Numbers  ------------------------------ */
    AON_IRQn                      =   0,
    BLE_MAC_IRQn                  =   1,
    DMAC2_CH1_IRQn                =   2,
    DMAC2_CH2_IRQn                =   3,
    DMAC2_CH3_IRQn                =   4,
    DMAC2_CH4_IRQn                =   5,
    DMAC2_CH5_IRQn                =   6,
    DMAC2_CH6_IRQn                =   7,
    DMAC2_CH7_IRQn                =   8,
    DMAC2_CH8_IRQn                =   9,
    PATCH_IRQn                    =  10,
    DM_MAC_IRQn                   =  11,
    USART4_IRQn                   =  12,
    USART5_IRQn                   =  13,
    SECU2_IRQn                    =  14,
    BT_MAC_IRQn                   =  15,
    BTIM3_IRQn                    =  16,
    BTIM4_IRQn                    =  17,
    PTC2_IRQn                     =  18,
    LPTIM3_IRQn                   =  19,
    GPIO2_IRQn                    =  20,
    HPSYS0_IRQn                   =  21,
    HPSYS1_IRQn                   =  22,
    HCPU2LCPU_IRQn                =  23,
    Interrupt24_IRQn              =  24,
    Interrupt25_IRQn              =  25,
    Interrupt26_IRQn              =  26,
    Interrupt27_IRQn              =  27,
    Interrupt28_IRQn              =  28,
    Interrupt29_IRQn              =  29,
    Interrupt30_IRQn              =  30,
    Interrupt31_IRQn              =  31,
    USART1_IRQn                   =  -1,
    LCPU2HCPU_IRQn                =  -1,
    DMAC1_CH1_IRQn                =  -1,
    DMAC1_CH2_IRQn                =  -1,
    DMAC1_CH3_IRQn                =  -1,
    DMAC1_CH4_IRQn                =  -1,
    DMAC1_CH5_IRQn                =  -1,
    DMAC1_CH6_IRQn                =  -1,
    DMAC1_CH7_IRQn                =  -1,
    DMAC1_CH8_IRQn                =  -1,
    /* Interrupts 32 .. 479 are left out */
} IRQn_Type;

#endif /* SOC_BF0_HCPU */

/* ================================================================================ */
/* ================      Processor and Core Peripheral Section     ================ */
/* ================================================================================ */

/* --------  Configuration of Core Peripherals  ----------------------------------- */
#define __CM33_REV                0x0000U   /* Core revision r0p1 */
#define __SAUREGION_PRESENT       0U        /* SAU regions present */
#define __MPU_PRESENT             1U        /* MPU present */
#define __VTOR_PRESENT            1U        /* VTOR present */
#define __NVIC_PRIO_BITS          3U        /* Number of Bits used for Priority Levels */
#define __Vendor_SysTickConfig    0U        /* Set to 1 if different SysTick Config is used */
#ifndef __FPU_PRESENT
#define __FPU_PRESENT             1U        /* no FPU present */
#endif /* __FPU_PRESENT */
#ifndef __DSP_PRESENT
#define __DSP_PRESENT             1U        /* no DSP extension present */
#endif /* __DSP_PRESENT */

#include "core_cm33.h"                      /* Processor and core peripherals */

#ifdef SOC_BF0_HCPU
#ifndef __ICACHE_PRESENT
#define __ICACHE_PRESENT          1U
#endif
#ifndef __DCACHE_PRESENT
#define __DCACHE_PRESENT          1U
#endif
#else
#ifndef __ICACHE_PRESENT
#define __ICACHE_PRESENT          1U
#endif
#ifndef __DCACHE_PRESENT
#define __DCACHE_PRESENT          1U
#endif

#endif /* SOC_BF0_HCPU */

#if defined(SOC_BF0_HCPU)
#define MPU_REGION_NUM       12
#else
#define MPU_REGION_NUM        8
#endif /* SOC_BF0_HCPU */

#ifdef __cplusplus
}
#endif

#endif /* _SF32LB52X_DEVICE_H_ */
