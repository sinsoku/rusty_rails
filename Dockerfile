# == base
FROM ruby:2.6-alpine as base

ENV RAILS_ENV production

# Update rubygems
RUN gem update --system
RUN gem update bundler --pre
RUN bundle config set without development:test

# == builder
FROM base

WORKDIR /builder

# Install packages
RUN apk add --no-cache \
      yarn \
      sqlite-dev \
      tzdata \
      ruby-dev \
      build-base \
      git \
      cargo

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

# Install npm packages
COPY package.json yarn.lock ./
RUN yarn install --production --ignore-engines

# Compile assets
COPY . ./
RUN SECRET_KEY_BASE=dummy bin/rails assets:precompile

# == main
FROM base

WORKDIR /app

# Instal packages
RUN apk add --no-cache \
      nodejs \
      sqlite-dev \
      tzdata

# Copy source files
COPY . ./

# Copy files from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /builder/public/assets ./public/assets
COPY --from=builder /builder/public/packs ./public/packs

RUN SECRET_KEY_BASE=dummy bin/rails db:setup

ENV PORT 3000
EXPOSE 3000

CMD bin/rails server -p $PORT -e $RAILS_ENV
