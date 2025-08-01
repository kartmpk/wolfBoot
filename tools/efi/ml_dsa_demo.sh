#!/bin/bash

echo "=========================================="
echo "🐺 wolfBoot ML-DSA Demo"
echo "=========================================="
echo ""

echo "1. Configuration Check"
echo "======================"
echo "Current signing algorithm: $(grep 'SIGN?' .config | cut -d'=' -f2)"
echo "ML-DSA Level: $(grep 'ML_DSA_LEVEL' .config | cut -d'=' -f2)"
echo "Signature Size: $(grep 'IMAGE_SIGNATURE_SIZE' .config | cut -d'=' -f2) bytes"
echo "Header Size: $(grep 'IMAGE_HEADER_SIZE' .config | cut -d'=' -f2) bytes"
echo ""

echo "2. Key Information"
echo "=================="
if [ -f "wolfboot_signing_private_key.der" ]; then
    echo "✅ Private key exists: wolfboot_signing_private_key.der"
    echo "   Key size: $(stat -c%s wolfboot_signing_private_key.der) bytes"
else
    echo "❌ Private key not found"
fi

if [ -f "wolfboot_signing_public_key.der" ]; then
    echo "✅ Public key exists: wolfboot_signing_public_key.der"
    echo "   Key size: $(stat -c%s wolfboot_signing_public_key.der) bytes"
else
    echo "❌ Public key not found"
fi
echo ""

echo "3. Signed Images"
echo "================"
if [ -f "output/images/bzImage_v1_signed.bin" ]; then
    echo "✅ Signed kernel v1: output/images/bzImage_v1_signed.bin"
    echo "   Size: $(stat -c%s output/images/bzImage_v1_signed.bin) bytes"
else
    echo "❌ Signed kernel v1 not found"
fi

if [ -f "output/images/bzImage_v2_signed.bin" ]; then
    echo "✅ Signed kernel v2: output/images/bzImage_v2_signed.bin"
    echo "   Size: $(stat -c%s output/images/bzImage_v2_signed.bin) bytes"
else
    echo "❌ Signed kernel v2 not found"
fi
echo ""

echo "4. ML-DSA Signature Structure"
echo "============================="
echo "Header breakdown (first 128 bytes):"
hexdump -C output/images/bzImage_v1_signed.bin | head -8
echo ""

echo "5. Verification Test"
echo "==================="
echo "Testing signature verification with wolfBoot keytools..."
./tools/keytools/sign --verify output/images/bzImage_v1_signed.bin wolfboot_signing_public_key.der
echo ""

echo "6. EFI Boot Test"
echo "================"
echo "Starting QEMU to demonstrate ML-DSA verification during boot..."
echo "Press Ctrl+C to stop the demo"
echo ""

# Run the EFI test
./tools/efi/run_efi.sh 