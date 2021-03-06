require 'spec_helper'

describe "Rack::NoWWW" do

  include Rack::Test::Methods
  let(:mock_endpoint) { lambda { |env| [200, {}, ["Hello, world."]] } }

  describe "when receiving a request with a 'www'" do
    context "without the :only_hosts parameter specified" do
  
      let :app do
        Rack::NoWWW.new(mock_endpoint)
      end

      before(:each) do
        request '/', {'HTTP_HOST' => 'www.example.org' }
      end

      it "should issue a 301 redirect" do
        last_response.status.should == 301
      end

      it "should redirect to the URL without the 'www'" do
        last_response.headers['Location'].should == "http://example.org/"
      end

      it "should have a text/html content type" do
        last_response.headers['Content-Type'].should == "text/html"
      end

      it "should have a body of 'Moved Permanently\\n'" do
        last_response.body.should == "Moved Permanently\n"
      end
      
    end

    context "with a non-matching domain in the :only_hosts parameter" do
      let :app do
        Rack::NoWWW.new(mock_endpoint, only_hosts: ['www.do-not-redirect.org'])
      end

      before(:each) do
        request '/', {'HTTP_HOST' => 'www.example.org' }
      end

      it "should not issue a 301 redirect" do
        last_response.status.should == 200
      end
    end

    context "with a matching domain in the :only_hosts parameter" do
      let :app do
        Rack::NoWWW.new(mock_endpoint, only_hosts: ['www.example.org'])
      end

      before(:each) do
        request '/', {'HTTP_HOST' => 'www.example.org' }
      end

      it "should issue a 301 redirect" do
        last_response.status.should == 301
      end

      it "should redirect to the URL without the 'www'" do
        last_response.headers['Location'].should == "http://example.org/"
      end
    end
  end

  describe "when receiving a request without a 'www'" do
    let :app do
      Rack::NoWWW.new(mock_endpoint)
    end

    it "should fall through to the app" do
      get '/'
      last_response.status.should == 200
      last_response.body.should == "Hello, world."
    end
  end

end
