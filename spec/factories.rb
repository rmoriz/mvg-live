# encoding: UTF-8

FactoryGirl.define do
  factory :live do
  end

  factory :westfriedhof, class: MVG::Live do
    station 'Westfriedhof'
    transports [:u, :tram, :bus]
  end

  factory :hackerbruecke, class: MVG::Live do
    station "Hackerbrücke"
    transports [:tram, :s]
  end

  factory :goethe_institut, class: MVG::Live do
    station 'Goethe-Institut'
    transports [:tram]
  end

  factory :leonrodplatz, class: MVG::Live do
    station 'Leonrodplatz'
    transports [:tram, :bus]
  end
end
