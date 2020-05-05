if (Test-Path source) {
    Set-Location source
    git pull
    Set-Location ..
}
else {
    git clone https://github.com/bs-community/blessing-skin-server.git source --depth=1
}

$githubToken = if ($env:GITHUB_TOKEN) {
    $env:GITHUB_TOKEN
}
else {
    't'
}

$version = Get-Content ./version.json | ConvertFrom-Json
$major = $version.major
$minor = $version.minor
$patch = $version.patch
$full = $version.full


Copy-Item -Path source -Destination ./apache -Recurse
docker build `
    -t "blessingskin/blessing-skin:apache" `
    -t "blessingskin/blessing-skin:latest" `
    -t "blessingskin/blessing-skin:latest-apache" `
    -t "blessingskin/blessing-skin:$major-apache" `
    -t "blessingskin/blessing-skin:$minor-apache" `
    -t "blessingskin/blessing-skin:$patch-apache" `
    -t "blessingskin/blessing-skin:$full-apache" `
    --build-arg CHANGE_SOURCE=$env:CHANGE_SOURCE `
    --build-arg GITHUB_TOKEN=$githubToken `
    apache
if ($env:CI -ne 'true') {
    Remove-Item ./apache/source -Recurse -Force
}

Copy-Item -Path source -Destination ./fpm -Recurse
docker build `
    -t "blessingskin/blessing-skin:fpm" `
    -t "blessingskin/blessing-skin:latest-fpm" `
    -t "blessingskin/blessing-skin:$major-fpm" `
    -t "blessingskin/blessing-skin:$minor-fpm" `
    -t "blessingskin/blessing-skin:$patch-fpm" `
    -t "blessingskin/blessing-skin:$full-fpm" `
    --build-arg CHANGE_SOURCE=$env:CHANGE_SOURCE `
    --build-arg GITHUB_TOKEN=$githubToken `
    fpm
if ($env:CI -ne 'true') {
    Remove-Item ./fpm/source -Recurse -Force
}
