# encoding: UTF-8

FactoryGirl.define do
  factory :live  do
  end

  factory :westfriedhof, :class => MVG::Live do
    station "Westfriedhof"
    transports [ :ubahn, :tram, :bus ]
  end

  factory :hackerbrücke, :class => MVG::Live do
    station "Hackerbrücke"
    transports [ :tram, :sbahn ]
  end

  factory :goethe_institut, :class => MVG::Live do
    station "Goethe-Institut"
    transports [ :tram ]
  end

  factory :leonrodplatz, :class => MVG::Live do
    station "Leonrodplatz"
    transports [ :tram, :bus ]
  end
end