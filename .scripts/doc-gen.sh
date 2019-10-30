#!/bin/bash

set -e

BINARY_DIR=./work
BINARY_FILE="${BINARY_DIR}/terraform-docs"
BINARY_VERSION=0.6.0
BINARY_URL_PREFIX="https://github.com/segmentio/terraform-docs/releases/download/v${BINARY_VERSION}/terraform-docs-v${BINARY_VERSION}"

DOCS_CMDS="--sort-inputs-by-required --with-aggregate-type-defaults markdown table"
DOCS_DIR=docs

VARS_TF=variables.tf
OUTS_TF=outputs.tf

INS_MD=inputs.md
OUTS_MD=outputs.md


function setup {
    mkdir -p ${BINARY_DIR}
    if [[ ! -e "${BINARY_FILE}" ]]; then
        if [[ "$OSTYPE" == "linux-gnu" ]]; then
            BINARY_URL="${BINARY_URL_PREFIX}-linux-amd64"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            BINARY_URL="${BINARY_URL_PREFIX}-darwin-amd64"
        else
            echo "Please run this in either a Linux or Mac environment."     
            exit 1  
        fi
        echo "Downloading ${BINARY_URL}"
        curl -L -o "${BINARY_FILE}" "${BINARY_URL}"
        chmod +x "${BINARY_FILE}"
    fi
}

function main_docs {
    if test ! -d "${DOCS_DIR}"; then
        mkdir "${DOCS_DIR}"
    fi

    echo -e "# Terraform Enterprise: Clustering\n" | tee "${DOCS_DIR}/${INS_MD}" "${DOCS_DIR}/${OUTS_MD}" &> /dev/null

    eval "${BINARY_FILE} ${DOCS_CMDS} ${VARS_TF}"  >> "${DOCS_DIR}/${INS_MD}"
    eval "${BINARY_FILE} ${DOCS_CMDS} ${OUTS_TF}" >> "${DOCS_DIR}/${OUTS_MD}"

}


function module_docs {
    if test -d ./modules; then
        for dir in ./modules/*; do
            mkdir -p "${dir}/${DOCS_DIR}"
            
            echo -e "# Terraform Enterprise: Clustering\n" | tee "${dir}/${DOCS_DIR}/${INS_MD}" "${dir}/${DOCS_DIR}/${OUTS_MD}" &> /dev/null

            eval "${BINARY_FILE} ${DOCS_CMDS} ${dir}/${VARS_TF}"  >> "${dir}/${DOCS_DIR}/${INS_MD}"
            eval "${BINARY_FILE} ${DOCS_CMDS} ${dir}/${OUTS_TF}" >> "${dir}/${DOCS_DIR}/${OUTS_MD}"
        done
    else
        echo "No modules directory, skipping."
    fi
}


setup
main_docs
module_docs



