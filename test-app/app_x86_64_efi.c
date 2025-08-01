/* app_x86_64_efi.c
 *
 * Test EFI boot application for x86_64 EFI target
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

/* Simple EFI application test function with memory verification */
void test_efi_app(void)
{
    /* Simple test application that prints Hello World */
    const char* hello_msg = "Hello World from wolfBoot EFI Test App!";
    const char* success_msg = "wolfBoot EFI Test App completed successfully!";
    
    /* This function will be called by wolfBoot when it loads the signed image */
    /* In a real scenario, this would be the entry point for the application */
    
    /* For now, we just return - the actual printing would happen when the app runs */
    return;
}

/* Application entry point that wolfBoot will call after loading */
void app_main(void) __attribute__((section(".text")));
void app_main(void)
{
    /* This function will be called when wolfBoot successfully loads and executes the app */
    
    /* Write magic numbers to multiple memory locations to verify execution */
    volatile uint32_t* magic_location1 = (volatile uint32_t*)0x1000;
    volatile uint32_t* magic_location2 = (volatile uint32_t*)0x2000;
    volatile uint32_t* magic_location3 = (volatile uint32_t*)0x3000;
    
    /* Write different magic numbers to prove the app is running */
    *magic_location1 = 0xDEADBEEF;  /* Primary magic number */
    *magic_location2 = 0xCAFEBABE;  /* Secondary magic number */
    *magic_location3 = 0x12345678;  /* Tertiary magic number */
    
    /* Write a counter to show the app is actively running */
    volatile uint32_t* counter_location = (volatile uint32_t*)0x4000;
    volatile uint32_t counter = 0;
    
    /* Simple infinite loop - no exceptions, no prints, just running */
    while(1) {
        counter++;
        *counter_location = counter;  /* Update counter in memory */
        
        /* This infinite loop shows the app is running */
        /* The magic numbers in memory prove the app executed */
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