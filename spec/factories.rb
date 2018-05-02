FactoryBot.define do
  factory :live do
  end

  factory :westfriedhof, class: MVG::Live do
    station 'Westfriedhof'
    transports %i[u tram bus]
  end

  factory :hackerbruecke, class: MVG::Live do
    station 'Hackerbrücke'
    transports %i[tram s]
  end

  factory :goethe_institut, class: MVG::Live do
    station 'Goethe-Institut'
    transports [:tram]
  end

  factory :leonrodplatz, class: MVG::Live do
    station 'Leonrodplatz'
    transports %i[tram bus]
  end
end
