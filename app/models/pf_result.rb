# Result computations for one pilot + flight combination
#  includes results computed from all judges for each figure of the flight
#
# flight_value is the total of flight_value from all judges, divided
#   by the number of judges * 10.  It should closely match the sum of
#   figure_results.  Value is stored as a decimal accurate to 1/100 point.
#
# adj_flight_value is flight_value minus any penalties earned by the pilot
#   on the flight.  Value is stored as a decimal accurate to 1/100 point.
#
# flight_rank is the pilot rank relative to all other pilots on the
#   flight, based on flight_value.  It is the number of pilots with a higher
#   flight_value, plus one
#
# adj_flight_rank is the pilot rank relative to all other pilots on the
#   flight, based on the adj_flight_value.  This is the final computed
#   placement of the pilot.
#
# figure_results is the total of pfj_result.computed values from all
#   judges for each figure, divided by the number of judges
#   Values are stored as integer number of tenths (scaled * 10)
#
class PfResult < ActiveRecord::Base
  belongs_to :pilot_flight

  serialize :figure_results

  # Return the pfj_result for a judge team that contributed to
  # this flight result
  def for_judge(judge)
    pilot_flight.pfj_results.where(:judge_id => judge).first
  end

  # Return the judge_teams for a flight
  # (each an instance from table :judges)
  def judge_teams
    pilot_flight.pfj_results.collect { |pfj_result| pfj_result.judge }
  end
end