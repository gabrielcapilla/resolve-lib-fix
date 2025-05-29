#!/usr/bin/env bash

# Strict mode for error handling
set -o errexit -o nounset -o pipefail

# Colors RGB & End
declare -r R="\033[1;31m"
declare -r G="\033[1;32m"
# declare -r B="\033[1;34m" # Unused
declare -r Y="\033[1;33m"
declare -r E="\033[0m"

# Color codes
declare -r A="${Y}::${E}" # Action
declare -r S="${G}::${E}" # Success
declare -r F="${R}::${E}" # Error/Fail

# Paths
declare -r OPT_RESOLVE_LIBS="/opt/resolve/libs"
declare -r DISABLED_FOLDER="${OPT_RESOLVE_LIBS}/_disabled"

# Log and error message and exit with a non-zero status
function log_error() {
  printf >&2 "${F} %s\n" "$*"
  exit 1
}

# Check if necessary directories exists
function validate_libs_directory() {
  [[ -d "${OPT_RESOLVE_LIBS}" ]] || log_error "Directory ${OPT_RESOLVE_LIBS} not found"
}

# Create _disabled folder
function create_disabled_folder() {
  sudo mkdir --parents -- "${DISABLED_FOLDER}" || log_error "Can´t create _disabled folder in ${DISABLED_FOLDER}"
}

# Move the selected libraries
function move_library_files() {
  shopt -s nullglob
  local -a matched_files=("${OPT_RESOLVE_LIBS}"/{libgio,libglib,libgmodule,libgobject}*)
  shopt -u nullglob
  [[ ${#matched_files[@]} -gt 0 ]] || log_error "No libraries found in ${OPT_RESOLVE_LIBS}"

  printf "%b\n" "${A} Moving libraries to ${DISABLED_FOLDER}"
  sudo mv -- "${matched_files[@]}" "${DISABLED_FOLDER}/" || log_error "Failed to move libraries to ${DISABLED_FOLDER}"
}

# Revert: move libraries from _disabled to OPT_RESOLVE_LIBS and remove _disabled
function revert_library_files() {
  [[ -d "${DISABLED_FOLDER}" ]] || log_error "Folder ${DISABLED_FOLDER} does not exist"

  shopt -s nullglob
  local -a matched_files=("${DISABLED_FOLDER}"/{libgio,libglib,libgmodule,libgobject}*)
  shopt -u nullglob
  [[ ${#matched_files[@]} -gt 0 ]] || log_error "No libraries found in ${DISABLED_FOLDER}"

  printf "%b\n" "${A} Restoring libraries from ${DISABLED_FOLDER} to ${OPT_RESOLVE_LIBS}"
  sudo mv -- "${matched_files[@]}" "${OPT_RESOLVE_LIBS}/" || log_error "Error restoring libraries to ${OPT_RESOLVE_LIBS}"
  printf "%b\n" "${S} Libraries restored to ${OPT_RESOLVE_LIBS}"

  sudo rmdir -- "${DISABLED_FOLDER}" || log_error "Error removing folder ${DISABLED_FOLDER}"
  printf "%b\n" "${S} Folder ${DISABLED_FOLDER} removed"
}

# Main function orchestrating the script flow
function main() {
  if [[ "${1:-}" == "--revert" ]]; then
    validate_libs_directory
    revert_library_files
    printf "%b\n" "${S} Restoration completed successfully!"
  else
    validate_libs_directory
    create_disabled_folder
    move_library_files
    printf "%b\n" "${S} Patch successfully applied!"
  fi
}

# Execute the main function
main "$@"
