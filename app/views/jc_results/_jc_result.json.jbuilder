json.judge do
  json.partial! jc_result.judge
end
json.(jc_result, :gamma, :rho, :flight_count, :minority_zero_ct, :minority_grade_ct)
