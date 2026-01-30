# frozen_string_literal: true

namespace :docker do
  desc 'Sobe os containers de desenvolvimento (exceto test)'
  task up: :environment do
    services = %w[db redis api sidekiq]
    success = system("docker compose up -d #{services.join(' ')}")
    exit(1) unless success
  end
end
