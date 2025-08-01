/* app_x86_64_efi_v2.c
 *
 * Test EFI boot application V2 for x86_64 EFI target
 * This is the "update" version with different magic numbers
 *
 * Copyright (C) 2024 wolfSSL Inc.
 *
 * This file is part of wolfBoot.
 *
 * wolfBoot is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * wolfBoot is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * ============================================================================
 */

#ifdef TARGET_X86_64_EFI

#include <efi.h>
#include <efilib.h>
#include <string.h>

/* UART functions removed - we're using pure memory writes for verification */

/* Simple EFI application test function V2 with different memory verification */
void test_efi_app_v2(void)
{
    /* This is the UPDATE version of the test app */
    /* It uses different magic numbers to distinguish from the primary app */
    
    /* This function will be called by wolfBoot when it loads the signed image */
    /* In a real scenario, this would be the entry point for the updated application */
    
    /* For now, we just return - the actual printing would happen when the app runs */
    return;
}

/* Application entry point that wolfBoot will call after loading */
void app_main(void) __attribute__((section(".text")));
void app_main(void)
{
    /* This function will be called when wolfBoot successfully loads and executes the UPDATE app */
    
    /* Write DIFFERENT magic numbers to distinguish this from the primary app */
    volatile uint32_t* magic_location1 = (volatile uint32_t*)0x1000;
    volatile uint32_t* magic_location2 = (volatile uint32_t*)0x2000;
    volatile uint32_t* magic_location3 = (volatile uint32_t*)0x3000;
    
    /* Write DIFFERENT magic numbers to prove this is the UPDATE app running */
    *magic_location1 = 0xUPDATED1;  /* UPDATE version magic number 1 */
    *magic_location2 = 0xUPDATED2;  /* UPDATE version magic number 2 */
    *magic_location3 = 0xUPDATED3;  /* UPDATE version magic number 3 */
    
    /* Write a different counter pattern to show this is the UPDATE app */
    volatile uint32_t* counter_location = (volatile uint32_t*)0x4000;
    volatile uint32_t counter = 0x1000;  /* Start from different value */
    
    /* Simple infinite loop with different pattern */
    while(1) {
        counter += 2;  /* Increment by 2 instead of 1 */
        *counter_location = counter;  /* Update counter in memory */
        
        /* This infinite loop shows the UPDATE app is running */
        /* The different magic numbers prove this is the UPDATE version */
        /* No exceptions, no prints - just pure execution */
    }
}

/* Entry point that wolfBoot will jump to */
void boot_entry(void) __attribute__((section(".text")));
void boot_entry(void)
{
    /* Call our main function */
    app_main();
}

#endif /* TARGET_x86_64_efi */ 