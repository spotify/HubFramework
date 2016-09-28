#!/usr/bin/env bash
# Copyright (c) 2015-2016 Spotify AB.
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -uo pipefail

LICENSE_HEADER_TEMPLATE_FILE="$1"
LICENSED_SOURCE_FILES="${*:2}"

FORMAT_FAIL="\033[31;1m"
FORMAT_SUCCESS="\033[32m"
FORMAT_COMMENT="\033[94m"

FORMAT_BOLD_ON="\033[1m"
FORMAT_RESET="\033[0m"

SYMBOL_FAIL="✗"
SYMBOL_SUCCESS="✓"

INVALID_SOURCE_FILES=""

# Check each file in our public API and internal sources.
for SOURCE_FILE in $LICENSED_SOURCE_FILES; do
    # Diff the source file’s first few lines with the license header template. They should not
    # differ. Also the header needs to be.
    diff \
        --brief \
        "$LICENSE_HEADER_TEMPLATE_FILE" \
        <(head -n \
            "$(wc -l "$LICENSE_HEADER_TEMPLATE_FILE" | awk '{print $1}')" \
            "$SOURCE_FILE") \
        &> /dev/null

    if [ "$?" == "0" ]; then
        echo -en "${FORMAT_SUCCESS}${SYMBOL_SUCCESS}${FORMAT_RESET}    \"${SOURCE_FILE}\""
    else
        echo -en "${FORMAT_FAIL}${SYMBOL_FAIL}    \"${SOURCE_FILE}\" ${FORMAT_BOLD_ON}[invalid license header]${FORMAT_BOLD_ON}"

        INVALID_SOURCE_FILES+="$SOURCE_FILE "
    fi

    echo -e "$FORMAT_RESET"
done

echo
if [ -n "$INVALID_SOURCE_FILES" ]; then
    echo -e "${FORMAT_FAIL}${SYMBOL_FAIL} [FAILURE] The following source files contains an invalid license header:${FORMAT_RESET}"
    for SOURCE_FILE in $INVALID_SOURCE_FILES; do
        echo "  - \"$SOURCE_FILE\""
    done
    echo -e "\n${FORMAT_COMMENT}Please make sure the license header in the mentioned files matches that of the license header template at \`$LICENSE_HEADER_TEMPLATE_FILE\`.${FORMAT_RESET}"

    exit 1
else
    echo -e "${FORMAT_SUCCESS}${SYMBOL_SUCCESS} [SUCCESS] All source files contains the required license.${FORMAT_RESET}"
    exit 0
fi
