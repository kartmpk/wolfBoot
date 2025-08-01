#!/bin/sh

echo "Building wolfBoot with x86_64 EFI config and Linux kernel..."

# Build wolfBoot EFI
echo "Building wolfBoot EFI..."
make TARGET=x86_64_efi SIGN=ML_DSA ML_DSA_LEVEL=2 IMAGE_SIGNATURE_SIZE=2420 IMAGE_HEADER_SIZE=4840 HASH=SHA256 DEBUG=1

if [ $? -ne 0 ]; then
    echo "Error: Failed to build wolfBoot EFI"
    exit 1
fi

# Buildroot setup
WORK_DIR=/home/prasanna/sources/wolfBoot/
BR_VER=2022.08.3
BR_DIR=buildroot-$BR_VER
IMAGE_DIR=$WORK_DIR/output

if (test ! -d $WORK_DIR);then
    mkdir -p $WORK_DIR
fi

if (test ! -d $WORK_DIR/$BR_DIR);then
    echo "Downloading and extracting Buildroot..."
    curl https://buildroot.org/downloads/$BR_DIR.tar.gz -o $WORK_DIR/$BR_DIR.tar.gz
    tar xvf $WORK_DIR/$BR_DIR.tar.gz -C $WORK_DIR
fi

echo "Building Linux kernel with Buildroot..."
# Clear problematic environment variables for Buildroot
unset LD_LIBRARY_PATH
BR2_EXTERNAL=$(pwd)/tools/efi/br_ext_dir make -C $WORK_DIR/$BR_DIR tiny_defconfig O=$IMAGE_DIR
make -C $WORK_DIR/$BR_DIR O=$IMAGE_DIR

if [ $? -ne 0 ]; then
    echo "Error: Failed to build Linux kernel with Buildroot"
    exit 1
fi

# Sign the Linux kernel images
echo "Signing Linux kernel images..."
SIGN_TOOL="./tools/keytools/sign"

$SIGN_TOOL --ml_dsa $IMAGE_DIR/images/bzImage wolfboot_signing_private_key.der 1
$SIGN_TOOL --ml_dsa $IMAGE_DIR/images/bzImage wolfboot_signing_private_key.der 2

if [ $? -ne 0 ]; then
    echo "Error: Failed to sign Linux kernel images"
    exit 1
fi

# Setup EFI partition
echo "Setting up EFI partition..."
mkdir -p /tmp/efi

# Create EFI disk using the same method as prepare_efi_partition.sh
if [ ! -f "/tmp/efi.disk" ]; then
    echo "Creating EFI disk..."
    dd if=/dev/zero of=/tmp/efi.disk bs=256M count=1
    sudo mkfs.vfat /tmp/efi.disk
    echo "EFI disk created and formatted successfully"
fi

# Mount and copy files (following prepare_efi_partition.sh method)
echo "Mounting EFI disk..."
sudo mount /tmp/efi.disk /tmp/efi -oloop

if [ $? -eq 0 ]; then
    echo "Successfully mounted EFI disk"
    # Copy the signed Linux kernel images
    sudo cp $IMAGE_DIR/images/bzImage_v1_signed.bin /tmp/efi/kernel.img
    sudo cp $IMAGE_DIR/images/bzImage_v2_signed.bin /tmp/efi/update.img
    sudo cp wolfboot.efi /tmp/efi/
    
    # Create startup script (following prepare_efi_partition.sh format)
    cat <<EOF > /tmp/startup.nsh
@echo -off
echo Starting wolfBoot EFI...
fs0:
wolfboot.efi
EOF
    sudo mv /tmp/startup.nsh /tmp/efi/
    sudo umount /tmp/efi
    echo "Files copied to EFI disk"
else
    echo "Failed to mount EFI disk"
fi

echo "Build complete!"
echo "Files created:"
echo "  - wolfboot.efi (wolfBoot EFI bootloader)"
echo "  - $IMAGE_DIR/images/bzImage_v1_signed.bin (signed Linux kernel v1)"
echo "  - $IMAGE_DIR/images/bzImage_v2_signed.bin (signed Linux kernel v2)"

echo ""
echo "To test with QEMU, run:"
echo "  ./tools/efi/run_efi.sh"


