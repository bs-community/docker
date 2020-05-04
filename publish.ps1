$version = Get-Content ./version.json | ConvertFrom-Json
$major = $version.major
$minor = $version.minor
$patch = $version.patch
$full = $version.full

docker push "blessingskin/blessing-skin:apache"
docker push "blessingskin/blessing-skin:latest"
docker push "blessingskin/blessing-skin:latest-apache"
docker push "blessingskin/blessing-skin:$major-apache"
docker push "blessingskin/blessing-skin:$minor-apache"
docker push "blessingskin/blessing-skin:$patch-apache"
docker push "blessingskin/blessing-skin:$full-apache"
docker push "blessingskin/blessing-skin:fpm"
docker push "blessingskin/blessing-skin:latest-fpm"
docker push "blessingskin/blessing-skin:$major-fpm"
docker push "blessingskin/blessing-skin:$minor-fpm"
docker push "blessingskin/blessing-skin:$patch-fpm"
docker push "blessingskin/blessing-skin:$full-fpm"
