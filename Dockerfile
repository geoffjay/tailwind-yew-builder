FROM --platform=linux/amd64 ubuntu

# Ubuntu init
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
  wget \
  xz-utils \
  inotify-tools
RUN apt-get autoremove -y

# Install node js
RUN mkdir /downloads
WORKDIR /downloads

ENV NODE_VERSION="v18.12.1"

RUN wget https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz
RUN ls -lt
RUN tar -xf 'node-'${NODE_VERSION}'-linux-x64.tar.xz'

ENV PATH=/downloads/node-${NODE_VERSION}-linux-x64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Create the npm package.json
RUN mkdir /work
WORKDIR /work

RUN npm set init.name "styles"
RUN npm init --yes
RUN ls

# Install tailwindcss
RUN npm install -g npm@latest
RUN npm install -D \
  tailwindcss@latest \
  tailwindcss-cli@latest \
  postcss@latest \
  autoprefixer@latest \
  clean-css-cli@latest \
  npm-run@latest \
  @tailwindcss/forms

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/work/node_modules/clean-css-cli/bin:/downloads/node-${NODE_VERSION}-linux-x64/bin

COPY package.json .
COPY postcss.config.js .
COPY prod.sh .

# RUN npx browserslist@latest --update-db

## For some reason we have to run this to get it to install properly
RUN npx tailwindcss-cli@latest

## Where the input tailwind.css file can be found
VOLUME /work/input

## Where the final css will be output
VOLUME /work/output

## Where post css will search for src to remove unused tailwind bits
## Point this to the root of your base app (it looks in source_code/src/**/*.rs and source_code/index.html
VOLUME /work/source_code
