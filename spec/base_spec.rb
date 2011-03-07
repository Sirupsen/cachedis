require 'spec_helper'

describe Cachedis do
  include HelperMethods

  before do
    @cachedis = Cachedis.new
  end

  describe 'when setting something' do
    it 'sets without errors' do
      with_no_cache
      @cachedis.redis_instance.should_receive(:set).exactly(1).times.and_return(['element', 'element 2'].to_yaml)
      
      lambda { 
      @cachedis.cachedis 'expensive-query' do
        ['element', 'element 2']
      end }.should_not raise_error
    end
  end

  describe 'when setting and later retrieving something' do
    it 'retrieves from redis cache' do
      with_cache('query')
      @cachedis.redis_instance.should_not_receive(:set)

      result = @cachedis.cachedis 'expensive-query' do
                "query"
              end

      result.should == "query".to_yaml
    end
  end

  describe 'when setting additonal redis parameters' do
    context 'with one argument' do
      it 'sets them in redis' do
        with_no_cache

        @cachedis.redis_instance.should_receive(:expire).exactly(1).times

        @cachedis.cachedis 'name', :expire => 60 * 60 do
        end
      end
    end

    context 'with an array of arguments' do
      it 'sets them in redis' do
        with_no_cache
        @cachedis.redis_instance.should_receive(:rename).exactly(1).times

        @cachedis.cachedis 'name', :rename => ['key', 'otherkey'] do
        end
      end
    end
  end
end