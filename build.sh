#!/bin/sh

#  build.sh
#  AdaptiveCardsFramework
#
#  Created by Hale Xie on 2024/06/18.
#  Copyright © 2024 Help Lightning. All rights reserved.
#!/bin/sh

#  build_universal_sdk.sh
#  HLSDK
#
#  Created by Hale Xie on 2021/05/14.
#  Copyright © 2021 Hale Xie. All rights reserved.

function create_universal_framework () {
    framework_dir=$1
    framework_copy_dir=$2
    simulator_dir=$3
    target_name=$4
    output_dir=$5

    binary_path=${framework_copy_dir}/${target_name}
    simulator_binary_path=${simulator_dir}/${target_name}

    rm -rf ${framework_copy_dir}
    cp -RL "${framework_dir}" "${framework_copy_dir}"
    rm -rf "${framework_dir}/SVProgressHUD.bundle"

    lipo -create -output "${binary_path}" "${framework_dir}/${target_name}" "${simulator_binary_path}"

    # copy swift modules
    if [ -d "${framework_dir}/Modules/${target_name}.swiftmodule" ]; then
        cp -RL "${simulator_dir}/Modules/${target_name}.swiftmodule"/*.* "${framework_copy_dir}/Modules/${target_name}.swiftmodule"
    fi

    # merge swift header
    swift_header="${framework_copy_dir}/Headers/${target_name}-Swift.h"
    if [ -f "${swift_header}" ]; then
        swift_header_simulator="${simulator_dir}/Headers/${target_name}-Swift.h"
        swift_header_ios="${framework_dir}/Headers/${target_name}-Swift.h"

        echo "#if TARGET_OS_SIMULATOR" > "${swift_header}"
        cat "${swift_header_simulator}" >> "${swift_header}"
        echo "#else" >> "${swift_header}"
        cat "${swift_header_ios}" >> "${swift_header}"
        echo "#endif" >> "${swift_header}"

    fi

    mkdir -p "${output_dir}"
    rm -rf "${output_dir}/${target_name}.framework"

    cp -RL "${framework_copy_dir}" "${output_dir}${target_name}.framework"

}

if [ -z "${PROJECT_DIR}" ]; then
    PROJECT_DIR=$PWD
fi

rm -rf ${PROJECT_DIR}/distributive ${PROJECT_DIR}/build

HLSDK_WORKSPACE=${PROJECT_DIR}/vipaar-MicrosoftFluentUI.xcworkspace

HLSDK_CONFIGURATION=Release

HLSDK_TARGET_NAME="vipaar-MicrosoftFluentUI"

if [ -z "${OBJROOT}" ]; then
    HLSDK_BUILD_SETTING="-derivedDataPath build"
else
    HLSDK_BUILD_SETTING="OBJROOT=${OBJROOT}/DependentBuilds"
fi

HLSDK_BUILD_DIR_IOS=$(xcodebuild \
                    -workspace ${HLSDK_WORKSPACE} \
                    -scheme ${HLSDK_TARGET_NAME} \
                    -configuration ${HLSDK_CONFIGURATION} \
                    -sdk iphoneos \
                    -showBuildSettings \
                    ${HLSDK_BUILD_SETTING} \
                    | grep TARGET_BUILD_DIR \
                    | awk '{print $3}')

HLSDK_BUILD_DIR_SIMULATOR=$(xcodebuild \
                            -workspace ${HLSDK_WORKSPACE} \
                            -scheme ${HLSDK_TARGET_NAME} \
                            -configuration ${HLSDK_CONFIGURATION} \
                            -sdk iphonesimulator \
                            -showBuildSettings \
                            ${HLSDK_BUILD_SETTING} \
                            | grep TARGET_BUILD_DIR \
                            | awk '{print $3}')

xcodebuild build ${HLSDK_BUILD_SETTING} \
    -workspace ${HLSDK_WORKSPACE} \
    -scheme ${HLSDK_TARGET_NAME} \
    -configuration ${HLSDK_CONFIGURATION} \
    -sdk iphoneos \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO

xcodebuild build ${HLSDK_BUILD_SETTING} \
    -workspace ${HLSDK_WORKSPACE} \
    -scheme ${HLSDK_TARGET_NAME} \
    -configuration ${HLSDK_CONFIGURATION} \
    -sdk iphonesimulator \
    ARCHS=x86_64 \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_ALLOWED=NO

HLSDK_OUTPUT_DIR=${PROJECT_DIR}/distributive/
mkdir -p "${HLSDK_OUTPUT_DIR}"

echo 'Creating MicrosoftFluentUI.framework...'
create_universal_framework "${HLSDK_BUILD_DIR_IOS}/MicrosoftFluentUI/FluentUI.framework" "${HLSDK_BUILD_DIR_IOS}/MicrosoftFluentUI/FluentUI.framework-copy" "${HLSDK_BUILD_DIR_SIMULATOR}/MicrosoftFluentUI/FluentUI.framework" "FluentUI" "${HLSDK_OUTPUT_DIR}"
