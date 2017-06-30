require 'active_support'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_model'
require 'activemodel-serializers-xml'
require 'active_model_serializers'

if ActiveModel.respond_to?(:version) && ActiveModel.version.version.to_i >= 5
  begin
    require 'active_model_serializers'
    require 'activemodel-serializers-xml'
  rescue LoadError
    puts """When using ActiveModel or Rails 5+, you should add
    gem 'active_model_serializers'
    gem 'activemodel-serializers-xml'
    in your Gemfile.
    """
  end
end


module Ooor
  # Ooor::MiniActiveResource is a shrinked version of ActiveResource::Base with the bare minimum we need for Ooor.
  # as a reminder ActiveResource::Base is the main class for mapping RESTful resources as models in a Rails application.
  # Ooor is a bit like ActiveResource but eventually it can use more OpenERP metadata and a richer API
  # to become closer to ActiveRecord or Mongoid than Activeresource. Also OpenERP isn't really good at REST
  # so the part of ActiveResource dedicated to REST is of little help here.
  # An other fundamental difference is Ooor is multi OpenERP instances and multi-sessions.
  # for each session, proxies to OpenERP may be different.
  class MiniActiveResource

    class << self
      def element_name
        @element_name ||= model_name.element
      end
    end

    attr_accessor :attributes, :id

    def to_json(options={})
      raise "you should add gem 'active_model_serializers' in your Gemfile" unless defined?(ActiveModel::Serializers::JSON)
      super(include_root_in_json ? { :root => self.class.element_name }.merge(options) : options)
    end

    def to_xml(options={})
      raise "you should add gem 'activemodel-serializers-xml' in your Gemfile" unless defined?(ActiveModel::Serializers::Xml)
      super({ :root => self.class.element_name }.merge(options))
    end

    # Returns +true+ if this object hasn't yet been saved, otherwise, returns +false+.
    def new?
      !@persisted
    end
    alias :new_record? :new?

    def persisted?
      @persisted
    end

    def id
      attributes["id"]
    end

    # Sets the <tt>\id</tt> attribute of the resource.
    def id=(id)
      attributes["id"] = id.to_i # NOTE added to_i for Ooor (HTML forms can pass it as a string)
    end

    # Reloads the record from the database.
    #
    # This method finds record by its primary key (which could be assigned manually) and
    # modifies the receiver in-place
    # NOTE in Ooor, like ActiveRecord and unlike ActiveResource, reload can take an options parameter
    def reload(options = nil)
      self.class.find(id, options)
    end

    # Returns the Errors object that holds all information about attribute error messages.
    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end


    include ActiveModel::Conversion
    include ActiveModel::Serializers::JSON if defined?(ActiveModel::Serializers::JSON)
    include ActiveModel::Serializers::Xml if defined?(ActiveModel::Serializers::Xml)

  end
end
