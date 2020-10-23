#!/usr/bin/env bash
set -Eeuo pipefail

# Set the working directory for the template
cd "${INPUT_WORKINGDIR:-.}"

# Selected template file
if [[ ! -f "$INPUT_TEMPLATEFILE" ]] && [[ $INPUT_TEMPLATEFILE -ne "*.json" ]]; then
    echo "${INPUT_TEMPLATEFILE} does not exit in the working directory (${INPUT_WORKINGDIR})"
    echo ""
    echo "Setting the file to template.json"
fi

# find var file
if [[ ! -f "$INPUT_VARIABLESFILE" ]] && [[ $INPUT_VARFILE -ne "*.json" ]]; then
    echo "${INPUT_VARIABLESFILE} does not exit in the working directory (${INPUT_WORKINGDIR})"
    exit 1
fi

set +e
# Run packer validate
VALIDATE_OUTPUT=$(sh -c "packer validate -var-file=${INPUT_VARIABLESFILE} ${INPUT_TEMPLATEFILE}" 2>&1)
VALIDATE_SUCCESS=$?
echo "$VALIDATE_OUTPUT"

if [[ "$VALIDATE_SUCCESS" -ne 0 ]]; then
    echo "Packer validate has falied"
    exit 1
fi

set +e
# Run packer build
BUILD_OUTPUT=$(sh -c "packer build -color=false -var-file=${INPUT_VARIABLESFILE} ${INPUT_TEMPLATEFILE}" 2>&1)
BUILD_SUCCESS=$?
echo "$BUILD_OUTPUT"
set -e

exit $BUILD_SUCCESS
