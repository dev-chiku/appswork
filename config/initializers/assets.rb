# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

Rails.application.config.assets.js_compressor = Uglifier.new(mangle: false)

Rails.application.config.assets.precompile += %w( Chart.min.js )
Rails.application.config.assets.precompile += %w( items/index.js )
Rails.application.config.assets.precompile += %w( jquery.blockUI.js )
Rails.application.config.assets.precompile += %w( masonry.js )
Rails.application.config.assets.precompile += %w( imagesloaded.pkgd.min.js )
Rails.application.config.assets.precompile += %w( ng-upload/ng-upload.js )
Rails.application.config.assets.precompile += %w(*.js )
Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)