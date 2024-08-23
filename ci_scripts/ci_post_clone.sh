#!/bin/sh

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

## change directory to top
cd ../

env_file=".env"
touch $env_file

cat > $env_file <<EOL
niabisAPIToken=${NIABIS_API_TOKEN}
cloudflareImagesAccountHashId=${CLOUDFLARE_IMAGES_ACCOUNT_HASH_ID}
sentryDsnUrlString=${SENTRY_DSN_URL}
mixpanelApiToken=${MIXPANEL_API_TOKEN}
EOL

cd NiaBisKit

swift package plugin --allow-writing-to-directory Sources generate-env-code SecretConstants ../${env_file} Sources/NiaBisUI/Others/SecretConstants.swift
