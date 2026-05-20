# Pin npm packages by running ./bin/importmap

pin "application"
pin "dm_nav", to: "dm_nav.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "cropperjs" # @1.6.2
pin "trix" # @2.1.18
pin "admin_trix", to: "admin_trix.js"
pin "@rails/actiontext", to: "@rails--actiontext.js"
