FROM ruby:3.2.9-bookworm

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    postgresql-client \
    nodejs \
    yarn \
    vim \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Create necessary directories
RUN mkdir -p tmp/pids

# Expose port
EXPOSE 3000

ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
