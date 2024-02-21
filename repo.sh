#!/bin/bash

# Remove existing metadata files
rm -rf Packages Packages.bz2 Packages.gz Packages.zst Release

# Generate Packages file
dpkg-scanpackages -m debs > Packages

# Compress Packages file using bzip2
bzip2 -k Packages

# Compress Packages file using gzip
gzip -k Packages

# Compress Packages file using zstd
zstd -19 Packages

# Copy Base to Release
cp Base Release

# Function to calculate checksums
calculate_checksums() {
    local file="$1"
    local size=$(ls -l "$file" | awk '{print $5}')
    local md5=$(md5sum "$file" | awk '{print $1}')
    local sha256=$(sha256sum "$file" | awk '{print $1}')
    echo "$md5 $size $sha256"
}

# Process each .deb file in the debs directory
for deb_file in debs/*.deb; do
    echo "Processing $deb_file"
    
    # Try to extract metadata from the .deb file
    if dpkg-deb -I "$deb_file" &>/dev/null; then
        # If successful, add the package to Packages file
        dpkg-deb -f "$deb_file" Package >> Packages
        echo "  Added $deb_file to Packages"
    else
        # If failed, skip this file
        echo "  Failed to process $deb_file. Skipping."
        continue
    fi
done

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
