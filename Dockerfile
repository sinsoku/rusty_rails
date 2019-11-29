# == builder
FROM ruby:2.6-alpine as builder

ENV RAILS_ENV production
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

# Update rubygems
RUN gem update --system
RUN gem update bundler --pre

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development:test -j4

# Install npm packages
COPY package.json yarn.lock ./
RUN yarn install --production --ignore-engines

# Compile assets
ENV SECRET_KEY_BASE=dummy
COPY . ./
RUN bin/rails assets:precompile

# == main
FROM ruby:2.6-alpine

ENV RAILS_ENV production
WORKDIR /app

# Instal packages
RUN apk add --no-cache \
      nodejs \
      sqlite-dev \
      tzdata

# Update rubygems
RUN gem update --system
RUN gem update bundler --pre

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
