# encoding: UTF-8
require 'spec_helper'

describe MVG::Live do

  before do
    # https://github.com/myronmarston/vcr/wiki/Usage-with-MiniTest
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  describe "when initialized" do
    it "can be created with no arguments" do
      mvglive = MVG::Live.new
      mvglive.must_be_instance_of MVG::Live
    end

    it "can be created for a specific station" do
      mvglive = MVG::Live.new 'Westfriedhof'
      mvglive.station.must_match 'Westfriedhof'
    end

    it "can be created for a specific transports" do
      transports = [ :u, :bus, :tram, :s ]
      mvglive = MVG::Live.new 'Westfriedhof', :transports => transports
      mvglive.transports.must_be_same_as transports
    end
  end

  describe "validations" do
    it "should not valid without a station" do
      mvglive = MVG::Live.new
      mvglive.station = nil
      mvglive.valid?.must_equal false
    end

    it "should be valid with a station and the default transports" do
      mvglive = build(:westfriedhof)
      mvglive.valid?.must_equal true
    end

    it "should not be valid with invalid transports" do
      transports = [ :transrapid, :express_s_bahn_zum_flughafen ]
      mvglive = MVG::Live.new 'Vom äh Hauptbahnof äh abfliegen', :transports  => transports
      mvglive.valid?.must_equal false
      mvglive.errors.keys.must_include :transports
    end
  end

  describe "HTTP" do
    it "should return a faraday connection object" do
      mvglive = build(:westfriedhof)
      mvglive.connection.must_be_instance_of Faraday::Connection
    end

    it "should point to the correct host" do
      mvglive = build(:westfriedhof)
      mvglive.connection.host.must_equal 'www.mvg-live.de'
    end

    it "should build the right query" do
      mvglive = build(:westfriedhof)
      mvglive.retrieve.env[:url].to_s.must_equal 'http://www.mvg-live.de/ims/dfiStaticAuswahl.svc?haltestelle=Westfriedhof&ubahn=checked&tram=checked&bus=checked'
    end

    it "should provide cached access to the response object through @response_obj" do
      mvglive = build(:westfriedhof)
      mvglive.retrieve
      mvglive.response_obj.must_be_instance_of Faraday::Response
    end
  end

  describe "Parser" do
    describe "unknown station" do
      it "should inform about incorrent stations and possible fits" do
        @mvglive = MVG::Live.new 'Moosfeld'
        @mvglive.fetch
        @mvglive.station_unknown.must_equal true
      end
    end

    describe "with S-Bahn" do
      before do
        @mvglive = build(:hackerbruecke)
        @mvglive.retrieve
        @mvglive.parse
      end

      describe "display" do
        it "should have the correct entry size" do
          @mvglive.result_display.must_be_instance_of Array
          @mvglive.result_display.size.must_equal 7
        end

        it "should have the correct order " do
          @mvglive.result_display.map{ |e| [ e[:line], e[:destination], e[:minutes] ]}.must_equal [
                                                                                                      ["N16", "Effnerplatz", 8],
                                                                                                      ["N16", "Amalienburgstraße", 23],
                                                                                                      ["N16", "Effnerplatz", 38],
                                                                                                      ["N16", "Amalienburgstraße", 53],
                                                                                                      ["S8", "Flughafen München", 17]
                                                                                                  ]
        end
      end

      describe "sorted" do
        it "should have the correct entry size" do
          @mvglive.result_sorted.must_be_instance_of Array
          @mvglive.result_sorted.size.must_equal 7
        end

        it "should have the correct order" do
          @mvglive.result_sorted.map{ |e| [ e[:line], e[:destination], e[:minutes] ]}.must_equal [
                                                                                                    ["N16", "Effnerplatz", 5],
                                                                                                    ["S8", "Flughafen München", 13],
                                                                                                    ["N16", "Amalienburgstraße", 19],
                                                                                                    ["S1", "Flughafen München", 25],
                                                                                                    ["N16", "Effnerplatz", 34],
                                                                                                    ["N16", "Amalienburgstraße", 49]
                                                                                                  ]
        end
      end

      describe "both" do
        it "should have the same number of entries" do
          @mvglive.result_sorted.size.must_equal @mvglive.result_display.size
        end
      end

    end
  end

  describe "Output" do
    describe "JSON" do


    end
  end

end