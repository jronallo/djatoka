class DjatokaGenerator < Rails::Generator::Base
  def initialize(*runtime_args)
    super
  end

  def manifest
    record do |m|
      m.template 'OpenURL.js', 'public/javascripts/OpenURL.js'
      m.template 'OpenLayers.js', 'public/javascripts/OpenLayers.js'
      m.template 'djatoka.js', 'public/javascripts/djatoka.js'
      m.template 'djatoka-initializer.rb', 'config/initializers/djatoka.rb'

      m.directory 'public/javascripts/img'
      m.template 'east-mini.png',       'public/javascripts/img/east-mini.png'
      m.template 'north-mini.png',      'public/javascripts/img/north-mini.png'
      m.template 'south-mini.png',      'public/javascripts/img/south-mini.png'
      m.template 'west-mini.png',       'public/javascripts/img/west-mini.png'
      m.template 'zoom-minus-mini.png', 'public/javascripts/img/zoom-minus-mini.png'
      m.template 'zoom-world-mini.png', 'public/javascripts/img/zoom-world-mini.png'
      m.template 'zoom-plus-mini.png',  'public/javascripts/img/zoom-plus-mini.png'
      m.template 'blank.gif',           'public/javascripts/img/blank.gif'
    end
  end

  protected

  def banner
    %{Usage: #{$0} #{spec.name}\nCopies OpenURL.js public/javascripts/}
  end

end

