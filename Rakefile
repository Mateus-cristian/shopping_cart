# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :db do
  desc 'Prepara o banco, executa os testes e remove containers Docker'
  task docker_prepare_and_cleanup: :environment do
    sh 'docker compose up -d db'
    sh 'docker compose run --rm test bundle exec rake db:create db:schema:load'
    sh 'docker compose run --rm test'
    sh 'docker compose down'
  end
end

namespace :swagger do
  desc 'Gera a documentação Swagger dentro do container Docker com permissão garantida'
  task docker_generate: :environment do
    sh 'docker compose run --user root --rm api bundle exec rake rswag:specs:swaggerize'
  end
end
