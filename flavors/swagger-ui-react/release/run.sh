# Deploy `swagger-ui-react` to npm.

# https://www.peterbe.com/plog/set-ex
set -ex

# Parameter Expansion: http://stackoverflow.com/questions/6393551/what-is-the-meaning-of-0-in-a-bash-script
cd "${0%/*}"

rm -rf ../dist/*
mkdir -p ../dist

# Copy UI's dist files to our directory
cp ../../../dist/swagger-ui.js ../dist
cp ../../../dist/swagger-ui.css ../dist
cp ../../../swagger-config.yaml ../dist

# Create a releasable package manifest
node create-manifest.js > ../dist/package.json

# Transpile our top-level component
../../../node_modules/.bin/cross-env BABEL_ENV=commonjs ../../../node_modules/.bin/babel --config-file ../../../babel.config.js ../index.js > ../dist/commonjs.js
../../../node_modules/.bin/cross-env BABEL_ENV=es ../../../node_modules/.bin/babel --config-file ../../../babel.config.js ../index.js > ../dist/index.js

# For babel-plugin-module-resolver to work correctly we need to change to the root folder
CURRENT_DIR=$(pwd)
cd "../../../"
./node_modules/.bin/cross-env BABEL_ENV=es ./node_modules/.bin/babel --config-file ./babel.config.js ./src/ --out-dir flavors/swagger-ui-react/dist/esm/
cd "$CURRENT_DIR"
# Replace commonjs entrypoint with ESM bundle in esm entrypoint
sed -i '' 's/.\/swagger-ui/.\/esm\/index/' ../dist/index.js

# Copy our README into the dist folder for npm
cp ../README.md ../dist

# Run the release from the dist folder
cd ../dist

if [ "$PUBLISH_FLAVOR_REACT" = "true" ] ; then
  npm publish .
else
  npm pack .
fi
