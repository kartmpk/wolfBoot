#!/bin/sh

# Script to test the x86_64 EFI config with test EFI application using QEMU

echo "Testing wolfBoot EFI with test EFI application..."

# Check if we're in the right directory
if [ ! -f "wolfboot.efi" ]; then
    echo "Error: wolfboot.efi not found. Run ./tools/efi/compile_efi_test_app.sh first"
    exit 1
fi

# Check if test application files exist
if [ ! -f "test-app/image_v1_signed.bin" ] || [ ! -f "test-app/image_v2_signed.bin" ]; then
    echo "Error: Test application files not found. Run ./tools/efi/compile_efi_test_app.sh first"
    exit 1
fi

# Create EFI disk image if it doesn't exist
if [ ! -f "/tmp/efi.disk" ]; then
    echo "Creating EFI disk image..."
    dd if=/dev/zero of=/tmp/efi.disk bs=1M count=100
    mkfs.fat -F 32 /tmp/efi.disk
fi

# Mount and copy files
echo "Setting up EFI partition..."
mkdir -p /tmp/efi
sudo mount /tmp/efi.disk /tmp/efi

# Copy the test application files
sudo cp test-app/image_v1_signed.bin /tmp/efi/test_app_v1.efi
sudo cp test-app/image_v2_signed.bin /tmp/efi/test_app_v2.efi
sudo cp wolfboot.efi /tmp/efi/

# Unmount
sudo umount /tmp/efi

echo "EFI partition setup complete!"
echo "Files copied to EFI partition:"
echo "  - /tmp/efi.disk (EFI disk image)"
echo "  - test_app_v1.efi (signed test EFI app v1)"
echo "  - test_app_v2.efi (signed test EFI app v2)"
echo "  - wolfboot.efi (wolfBoot EFI bootloader)"

echo ""
echo "To run with QEMU:"
echo "  ./tools/efi/run_efi.sh"
echo ""
echo "Or manually:"
echo "  qemu-system-x86_64 -m 256M -net none -bios /usr/share/edk2-ovmf/x64/OVMF.fd -drive file=/tmp/efi.disk,index=0,media=disk,format=raw -vga none -serial stdio -display none" 