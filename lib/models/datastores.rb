class Datastores
  def initialize(data)
    @data = data.map{|x| Datastore.new(x)}
  end
  def list
    @data
  end
  def each(&block)
    @data.each do |item|
      block.call(item)
    end
  end
  class Datastore
    def initialize(datastore)
      @datastore = datastore
    end
    def label
      @datastore[:label]
    end
    def href
      ENV.fetch('SEARCH_URL') + @datastore[:href] 
    end
    def current?
      !!@datastore[:current]
    end
  end
  
end
