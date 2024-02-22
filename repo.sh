#!/bin/bash

# Remove existing metadata files
rm -rf Packages Packages.* Release Release.*

# Create Packages file if it doesn't exist
if [ ! -e Packages ]; then
    dpkg-scanpackages -m debs > Packages
fi

# Create Release file if it doesn't exist
if [ ! -e Release ]; then
    touch Release
fi

# Function to calculate checksums
calculate_checksums() {
    local file="$1"
    local size=$(stat -c %s "$file")
    local md5=$(md5sum "$file" | awk '{print $1}')
    local sha256=$(sha256sum "$file" | awk '{print $1}')
    echo "$md5 $size $sha256"
}

# Function to create compressed versions and calculate checksums
calculate_and_append_checksums() {
    local file="$1"
    local compression="$2"
    local compressed_file="$file.$compression"
    local file_basename=$(basename "$compressed_file")
    local checksums=$(calculate_checksums "$compressed_file")
    
    # Append checksums to Release file
    echo "MD5Sum:" >> Release
    echo " $checksums" >> Release
    
    echo "SHA256:" >> Release
    echo " $checksums" >> Release
    
    # Compress the file
    case "$compression" in
        bz2)
            bzip2 -k "$file"
            ;;
        gz)
            gzip -k "$file"
            ;;
        zst)
            zstd -19 "$file"
            ;;
    esac
}

# Process each .deb file in the debs directory
for deb_file in debs/*/*.deb; do
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

# Create compressed versions of Packages file
for compression in bz2 gz zst; do
    calculate_and_append_checksums "Packages" "$compression"
done

# Copy Base to Release
cp -r Base Release

# Create compressed versions of Release file
for compression in bz2 gz zst; do
    calculate_and_append_checksums "Release" "$compression"
done

echo "Done"

# Display all checksums
echo "MD5Sum for Packages, Packages.bz2, Packages.gz, Packages.zst:"
md5sum Packages*
echo "SHA256 for Packages, Packages.bz2, Packages.gz, Packages.zst:"
sha256sum Packages*

echo "MD5Sum for Release, Release.bz2, Release.gz, Release.zst:"
md5sum Release*
echo "SHA256 for Release, Release.bz2, Release.gz, Release.zst:"
sha256sum Release*

echo "All checksums calculated and displayed."
