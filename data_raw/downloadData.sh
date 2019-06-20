#!/bin/sh

GREP_OPTIONS=''

cookiejar=$(mktemp cookies.XXXXXXXXXX)
netrc=$(mktemp netrc.XXXXXXXXXX)
chmod 0600 "$cookiejar" "$netrc"
function finish {
  rm -rf "$cookiejar" "$netrc"
}

trap finish EXIT
WGETRC="$wgetrc"

prompt_credentials() {
    echo "Enter your Earthdata Login or other provider supplied credentials"
    read -p "Username (elcarnahan): " username
    username=${username:-elcarnahan}
    read -s -p "Password: " password
    echo "machine urs.earthdata.nasa.gov login $username password $password" >> $netrc
    echo
}

exit_with_error() {
    echo
    echo "Unable to Retrieve Data"
    echo
    echo $1
    echo
    echo "https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.23/ATL06_20190223095316_08700203_001_01.h5"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 2 --netrc-file "$netrc" https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.23/ATL06_20190223095316_08700203_001_01.h5 -w %{http_code} | tail  -1`
    if [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w %{http_code} https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.23/ATL06_20190223095316_08700203_001_01.h5 | tail -1)
    if [[ "$status" -ne "200" && "$status" -ne "304" ]]; then
        # URS authentication is required. Now further check if the application/remote service is approved.
        detect_app_approval
    fi
}

setup_auth_wget() {
    # The safest way to auth via curl is netrc. Note: there's no checking or feedback
    # if login is unsuccessful
    touch ~/.netrc
    chmod 0600 ~/.netrc
    credentials=$(grep 'machine urs.earthdata.nasa.gov' ~/.netrc)
    if [ -z "$credentials" ]; then
        cat "$netrc" >> ~/.netrc
    fi
}

    fetch_urls() {
    if command -v curl >/dev/null 2>&1; then
        setup_auth_curl
        while read -r line; do
          # Get everything after the last '/'
          filename="${line##*/}"

          # Strip everything after '?'
          stripped_query_params="${filename%%\?*}"

          curl -f -b "$cookiejar" -c "$cookiejar" -L --netrc-file "$netrc" -g -o $stripped_query_params -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
        done;
    elif command -v wget >/dev/null 2>&1; then
        # We can't use wget to poke provider server to get info whether or not URS was integrated without download at least one of the files.
        echo
        echo "WARNING: Can't find curl, use wget instead."
        echo "WARNING: Script may not correctly identify Earthdata Login integrations."
        echo
        setup_auth_wget
        while read -r line; do
          # Get everything after the last '/'
          filename="${line##*/}"

          # Strip everything after '?'
          stripped_query_params="${filename%%\?*}"

          wget --load-cookies "$cookiejar" --save-cookies "$cookiejar" --output-document $stripped_query_params --keep-session-cookies -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
        done;
    else
        exit_with_error "Error: Could not find a command-line downloader.  Please install curl or wget"
    fi
}

fetch_urls <<'EDSCEOF'
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.23/ATL06_20190223095316_08700203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.19/ATL06_20190219100134_08090203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.17/ATL06_20190217233746_07870205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.15/ATL06_20190215100955_07480203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.13/ATL06_20190213234606_07260205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.09/ATL06_20190209235428_06650205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.06/ATL06_20190206105217_06110203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.06/ATL06_20190206000250_06040205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.02.02/ATL06_20190202110037_05500203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.29/ATL06_20190129110855_04890203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.28/ATL06_20190128004505_04670205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.25/ATL06_20190125111711_04280203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.24/ATL06_20190124005321_04060205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.21/ATL06_20190121112525_03670203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.20/ATL06_20190120010133_03450205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.17/ATL06_20190117113337_03060203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.16/ATL06_20190116010949_02840205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.13/ATL06_20190113114201_02450203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.12/ATL06_20190112011814_02230205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.08/ATL06_20190108121605_01690203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.08/ATL06_20190108012637_01620205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2019.01.04/ATL06_20190104122425_01080203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.31/ATL06_20181231123245_00470203_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.30/ATL06_20181230020855_00250205_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.27/ATL06_20181227124101_13730103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.26/ATL06_20181226021713_13510105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.23/ATL06_20181223124922_13120103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.22/ATL06_20181222022533_12900105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.19/ATL06_20181219125740_12510103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.18/ATL06_20181218023352_12290105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.15/ATL06_20181215130559_11900103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.14/ATL06_20181214024209_11680105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.10/ATL06_20181210025030_11070105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.06/ATL06_20181206134817_10530103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.02/ATL06_20181202135637_09920103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.12.01/ATL06_20181201033248_09700105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.28/ATL06_20181128140455_09310103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.27/ATL06_20181127034106_09090105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.24/ATL06_20181124141317_08700103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.23/ATL06_20181123034931_08480105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.20/ATL06_20181120142144_08090103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.19/ATL06_20181119035757_07870105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.16/ATL06_20181116143009_07480103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.15/ATL06_20181115040622_07260105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.11/ATL06_20181111041444_06650105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.11.07/ATL06_20181107151228_06110103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.10.30/ATL06_20181030152858_04890103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.10.29/ATL06_20181029050508_04670105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.10.26/ATL06_20181026153716_04280103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.10.25/ATL06_20181025051327_04060105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.10.22/ATL06_20181022154534_03670103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.10.21/ATL06_20181021052145_03450105_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.10.18/ATL06_20181018155352_03060103_001_01.h5
https://n5eil01u.ecs.nsidc.org/DP7/ATLAS/ATL06.001/2018.10.17/ATL06_20181017053005_02840105_001_01.h5
EDSCEOF
