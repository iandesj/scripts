#!/usr/bin/env sh

if [[ $(uname -a) = *"Darwin"* ]]; then
    wget https://chromedriver.storage.googleapis.com/2.36/chromedriver_mac64.zip
    unzip chromedriver_mac64*
    rm chromedriver_mac64*
    sudo mv chromedriver /usr/local/bin/
elif [[ $(uname -a) = *"Linux"* ]]; then
        wget https://chromedriver.storage.googleapis.com/2.36/chromedriver_mac64.zip
        unzip chromedriver_mac64*
        rm chromedriver_mac64*
        sudo mv chromedriver /usr/local/bin/
fi
