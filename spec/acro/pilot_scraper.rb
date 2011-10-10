require 'spec_helper'
require 'acro/pilotScraper'

module ACRO
  describe PilotScraper do
    before(:all) do
      @ps = PilotScraper.new('spec/acro/pilot_p001s16.htm')
    end
    it 'finds the pilot flight file' do
      @ps.pilotID.should == 1
      @ps.flightID.should == 16
    end
    it 'finds the pilot and sequence names' do
      @ps.pilotName.should == 'Kelly Adams'
      @ps.flightName.should == 'Advanced - Power : Known Power'
    end
    it 'finds the judges in the flight file' do
      aj = @ps.judges
      aj.length.should == 7
      aj[0].should == 'Debby Rihn-Harvey'
      aj[6].should == 'Bill Denton'
    end
    it 'finds the k factors for the flight' do
      ak = @ps.k_factors
      ak.length.should == 10
      ak[0].should == 41
      ak[4].should == 31
      ak[9].should == 12
    end
    it 'finds scores for figures' do
      @ps.score(1,3).should == 65
      @ps.score(1,7).should == 85
      @ps.score(5,3).should == 0
      @ps.score(10,7).should == 90
    end
    it 'finds penalty amount for flight' do
      @ps.penalty.should == 20
    end
  end
end