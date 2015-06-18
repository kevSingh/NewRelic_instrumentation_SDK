#!/bin/bash

BUILD_DIR="$HOME/src/newrelic_agent_sdk_installation/"

if [[ ! -d "$BUILD_DIR" ]]; then
    mkdir -p "$BUILD_DIR"
fi

url_path=$( curl  http://download.newrelic.com/agent_sdk/ | \
            egrep -i -e '\.tar\.gz' -e '\.tgz' | \
            sed 's/^.*href="//; s/".*//' )

echo -e "Downloading http://download.newrelic.com/agent_sdk/$url_path\n"

curl  -o  "$BUILD_DIR/nr_agent_sdk.tar.gz" \
      "http://download.newrelic.com/agent_sdk/$url_path"

curl_exit_code=$?
if [[ $curl_exit_code -ne 0 ]]; then
      echo "ERROR: curl exit-code was $curl_exit_code."
      echo "Please make sure that the file " \
           "$BUILD_DIR/nr_agent_sdk.tar.gz exists and is valid."
      echo "Aborting."
      exit 1
fi

echo  -e "\nExtracting $BUILD_DIR/nr_agent_sdk.tar.gz ...\n"

cd "$BUILD_DIR" && \
   tar  -xzf  nr_agent_sdk.tar.gz

tar_exit_code=$?
if [[ $tar_exit_code -ne 0 ]]; then
      echo "ERROR: tar exit-code was $tar_exit_code."
      echo "Please make sure that the file " \
           "$BUILD_DIR/nr_agent_sdk.tar.gz is a tar-gzipped file."
      echo "Aborting."
      # exit with a different error code than the above for curl
      exit 2
fi

nr_agent_base_directory=$( find $(pwd) -maxdepth 1 -mindepth 1 -type d -cmin -5 )

echo $nr_agent_base_directory

ln  -sf  "$nr_agent_base_directory"   $(pwd)/nr_agent_sdk_base_dir

echo -e "\n$BUILD_DIR is ready.\n"

# Last step
# Prepare the ~/.newrelic/log4plus.properties files

if [[ ! -d "$HOME/.newrelic/" ]]; then
    mkdir  $HOME/.newrelic/
fi
if [[ ! -f "$HOME/.newrelic/log4cplus.properties" ]]; then
    echo -e "Preparing NewRelic logging settings in " \
            "$HOME/.newrelic/log4cplus.properties ...\n"

    cp "$nr_agent_base_directory/config/log4cplus.properties" $HOME/.newrelic/
    sed -i 's#log4cplus.logger.com.newrelic=info,#log4cplus.logger.com.newrelic=debug,#' \
           $HOME/.newrelic/log4cplus.properties
else
    echo -e "$HOME/.newrelic/log4cplus.properties exists. " \
            "Skipping creating it.\n"
fi

echo -e "Done"

