PLATFORM=$1
DESTINATION=$(realpath $2)
URL="https://nightly.link/Simon-L/mfx-base-app/workflows/ci/main/mfx-base-app-${PLATFORM}.zip"

echo "Preparing for ${PLATFORM} in ${DESTINATION}"
echo "URL: ${URL}"

if [[ -d ${DESTINATION} ]]; then
    echo "Abort. Destination already exists."
    exit 1
fi

mkdir ${DESTINATION}

cd ${DESTINATION}
curl -L ${URL} --output file.zip
unzip file.zip
rm file.zip
tree .