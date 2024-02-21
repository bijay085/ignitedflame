#!/bin/bash

# Remove existing metadata files
rm -rf Packages Packages.bz2 Packages.gz Packages.zst Release Release.bz2 Release.gz Release.zst

# Generate Packages file if it doesn't exist
if [ ! -e Packages ]; then
    dpkg-scanpackages -m debs > Packages
fi

# Compress Packages file using bzip2
bzip2 -k Packages

# Compress Packages file using gzip
gzip -k Packages

# Compress Packages file using zstd
zstd -19 Packages

# Copy Base to Release
cp -r Base Release

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

# Compress Packages.bz2 file
bzip2 -k Packages

# Compress Packages.zst file
zstd -19 Packages

# Calculate checksums for Packages.bz2 and Packages.zst files
packagesbz2_checksums=$(calculate_checksums "Packages.bz2")
packageszst_checksums=$(calculate_checksums "Packages.zst")

# Append checksums to Release file
echo "MD5Sum:" >> Release
echo " $packagesbz2_checksums" >> Release
echo " $packageszst_checksums" >> Release

echo "SHA256:" >> Release
echo " $packagesbz2_checksums" >> Release
echo " $packageszst_checksums" >> Release

# Compress Release file using bzip2
bzip2 -k Release

# Compress Release file using gzip
gzip -k Release

# Compress Release file using zstd
zstd -19 Release

# Calculate checksums for Release files
release_checksums=$(calculate_checksums "Release")
releasebz2_checksums=$(calculate_checksums "Release.bz2")
releasegz_checksums=$(calculate_checksums "Release.gz")
releasezst_checksums=$(calculate_checksums "Release.zst")

# Append checksums to Release file
echo "MD5Sum:" >> Release
echo " $release_checksums" >> Release
echo " $releasebz2_checksums" >> Release
echo " $releasegz_checksums" >> Release
echo " $releasezst_checksums" >> Release

echo "SHA256:" >> Release
echo " $release_checksums" >> Release
echo " $releasebz2_checksums" >> Release
echo " $releasegz_checksums" >> Release
echo " $releasezst_checksums" >> Release

echo "Done"
