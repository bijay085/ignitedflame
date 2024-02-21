#!/bin/bash

# Remove existing metadata files
rm -rf Packages Packages.bz2 Packages.gz Packages.zst Release

# Generate Packages file
dpkg-scanpackages -m debs > Packages

# Compress Packages file using bzip2
bzip2 -k Packages

# Compress Packages file using gzip
gzip -k Packages

# Compress Packages file using zstd with explicit compression level
zstd -19 Packages -o Packages.zst

# Copy Base to Release
cp Base Release

# Function to calculate checksums
calculate_checksums() {
    local file="$1"
    local size_and_name=$(ls -l "$file" | awk '{print $5,$9}')
    
    local md5_command="md5sum"
    if command -v md5sum > /dev/null; then
        md5_command="md5sum"
    elif command -v md5 > /dev/null; then
        md5_command="md5"
    else
        echo "Error: Neither md5sum nor md5 found. Cannot calculate checksums."
        exit 1
    fi

    local md5=$($md5_command "$file" | awk '{print $1}')
    local sha256=$(sha256sum "$file" | awk '{print $1}')
    echo "$md5 $size_and_name $sha256"
}

# Calculate checksums for Packages files
packages_checksums=$(calculate_checksums "Packages")
packagesbz2_checksums=$(calculate_checksums "Packages.bz2")
packagesgz_checksums=$(calculate_checksums "Packages.gz")
packageszst_checksums=$(calculate_checksums "Packages.zst")

# Append checksums to Release file
echo "MD5Sum:" >> Release
echo " $packages_checksums" >> Release
echo " $packagesbz2_checksums" >> Release
echo " $packagesgz_checksums" >> Release
echo " $packageszst_checksums" >> Release

echo "SHA256:" >> Release
echo " $packages_checksums" >> Release
echo " $packagesbz2_checksums" >> Release
echo " $packagesgz_checksums" >> Release
echo " $packageszst_checksums" >> Release

echo "Done"
