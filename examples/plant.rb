require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Conservation

  include SMG::Resource

  extract :conservation  , :at => :code
  extract :conservation  , :at => :year   , :context => [:conservation]
  extract :conservation  , :as => :status , :context => [:conservation]

end

class Plant

  include SMG::Resource

  root 'spec'

  extract 'family'            , :context => [:classification]
  extract 'genus'             , :context => [:classification]
  extract 'binomial'
  extract 'conservation'      , :context => [:conservation, :info], :class => Conservation
  collect 'synonims/binomial' , :context => [:synonims], :as => :synonims, 

end

data = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<spec>
  <family>Rosaceae</family>
  <genus>Malus</genus>
  <conservation code="NE" year="2007">Not Evaluated</conservation>
  <binomial>Malus pumila Mill.</binomial>
  <synonims>
    <binomial>Malus communis  Poir.</binomial>
    <binomial>Malus domestica auct. non Borkh.</binomial>
    <binomial>Malus praecox (Pall.) Borkh.</binomial>
    <binomial>Malus pumila Mill. var. niedzwetzkyana (Dieck) C.K. Schneid.</binomial>
    <binomial>Malus sylvestris Amer. auth., non (L.) Mill.</binomial>
    <binomial>Malus sylvestris (L.) Mill. var. praecox (Pall.) Ponomar.</binomial>
    <binomial>Pyrus pumila (Mill.) K. Koch</binomial>
  </synonims>
</spec>
XML

plant = Plant.parse(data,:classification)

puts plant.family               #=> "Rosaceae"
puts plant.genus                #=> "Malus"
puts plant.binomial             #=> "Malus pumila Mill."
puts plant.conservation         #=> nil
puts plant.synonims             #=> []

plant = Plant.parse(data,:synonims)

puts plant.family               #=> nil
puts plant.genus                #=> nil
puts plant.binomial             #=> "Malus pumila Mill."
puts plant.conservation         #=> nil
puts plant.synonims             #=> [ "Malus communis  Poir.", 
                                #     "Malus domestica auct. non Borkh.",
                                #     "Malus praecox (Pall.) Borkh.",
                                #     "Malus pumila Mill. var. niedzwetzkyana (Dieck) C.K. Schneid.",
                                #     "Malus sylvestris Amer. auth., non (L.) Mill.",
                                #     "Malus sylvestris (L.) Mill. var. praecox (Pall.) Ponomar.",
                                #     "Pyrus pumila (Mill.) K. Koch" ]

plant = Plant.parse(data,:conservation)

puts plant.family               #=> nil
puts plant.genus                #=> nil
puts plant.binomial             #=> "Malus pumila Mill."
puts plant.conservation.status  #=> "Not Evaluated"
puts plant.conservation.code    #=> "NE"
puts plant.conservation.year    #=> "2007"
puts plant.synonims             #=> []

plant = Plant.parse(data,:info)

puts plant.family               #=> nil
puts plant.genus                #=> nil
puts plant.binomial             #=> "Malus pumila Mill."
puts plant.conservation.status  #=> nil
puts plant.conservation.code    #=> "NE"
puts plant.conservation.status  #=> nil
puts plant.synonims             #=> []


# EOF