# frozen_string_literal: true

namespace :test do
  desc 'Roda os testes em container isolado e remove apenas ele depois'
  task docker: :environment do
    puts '🟢 Rodando testes no container isolado...'

    # --rm garante que o container de teste seja removido automaticamente após execução
    success = system('docker compose run --rm test')

    exit(1) unless success
  end
end
