rm -rf Packages Packages.bz2 Packages.gz Packages.zst Release
dpkg-scanpackages -m debs > Packages
bzip2 -k Packages
gzip -k Packages
zstd -19 Packages
cp Base Release

# Calculate sizes and hashes using SHA-512
packages_size=$(ls -l Packages | awk '{print $5,$9}')
packages_sha512=$(sha512sum Packages | awk '{print $1}')
packagesbz2_size=$(ls -l Packages.bz2 | awk '{print $5,$9}')
packagesbz2_sha512=$(sha512sum Packages.bz2 | awk '{print $1}')
packagesgz_size=$(ls -l Packages.gz | awk '{print $5,$9}')
packagesgz_sha512=$(sha512sum Packages.gz | awk '{print $1}')
packageszst_size=$(ls -l Packages.zst | awk '{print $5,$9}')
packageszst_sha512=$(sha512sum Packages.zst | awk '{print $1}')

# Append to Release file
echo "SHA512:" >> Release
echo " $packages_sha512 $packages_size" >> Release
echo " $packagesbz2_sha512 $packagesbz2_size" >> Release
echo " $packagesgz_sha512 $packagesgz_size" >> Release
echo " $packageszst_sha512 $packageszst_size" >> Release

echo "Done"
