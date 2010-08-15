require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

data = <<-XML
<yml_catalog date="2010-08-15 16:50">
  <shop>
    <name>Books.Ru</name>
    <company>Books.Ru Online Shop</company>
    <url>http://www.books.ru/</url>
    <currencies>
      <currency id="RUR" rate="1"/>
    </currencies>
    <offers>
      <offer id="745663" type="books" available="true">
        <url>http://www.books.ru/shop/books/745663</url>
        <price>290</price>
        <currencyId>RUR</currencyId>
        <picture>http://www.books.ru/img/745663m.jpg</picture>
        <author>Форд Н., Найгард М., Де Ора Б.</author>
        <name>97 этюдов для архитекторов программных систем</name>
        <publisher>Символ-Плюс</publisher>
        <year>2010</year>
        <ISBN>978-5-93286-176-9</ISBN>
      </offer>
      <offer id="749548" type="books" available="true">
        <url>http://www.books.ru/shop/books/749548</url>
        <price>590</price>
        <currencyId>RUR</currencyId>
        <picture>http://www.books.ru/img/749548m.jpg</picture>
        <author>Головатый А., Каплан-Мосс Д.</author>
        <name>Django. Подробное руководство</name>
        <publisher>Символ-Плюс</publisher>
        <year>2010</year>
        <ISBN>978-5-93286-187-5</ISBN>
      </offer>
      <offer id="734220" type="books" available="false">
        <url>http://www.books.ru/shop/books/734220</url>
        <price>850</price>
        <currencyId>RUR</currencyId>
        <picture>http://www.books.ru/img/734220m.jpg</picture>
        <author>Шварц Б., Зайцев П., Ткаченко В., Заводны Д.</author>
        <name>MySQL. Оптимизация производительности, 2-е издание</name>
        <publisher>Символ-Плюс</publisher>
        <year>2010</year>
        <ISBN>978-5-93286-153-0</ISBN>
      </offer>
      <offer id="784182" type="books" available="true">
        <url>http://www.books.ru/shop/books/784182</url>
        <price>723</price>
        <currencyId>RUR</currencyId>
        <picture>http://www.books.ru/img/784182m.jpg</picture>
        <author>Бизли Д.</author>
        <name>Python. Подробный справочник, 4-е издание</name>
        <publisher>Символ-Плюс</publisher>
        <year>2010</year>
        <ISBN>978-5-93286-157-8</ISBN>
      </offer>
    </offers>
  </shop>
</yml_catalog>
XML

class Offer
  include SMG::Resource

  extract 'offer', :at => :id, :class => :integer

  root 'offer'
  extract :name
  extract :author
  extract :publisher
  extract :ISBN, :as => :isbn
  extract :year, :class => :integer

  extract :price, :class => :integer
  extract :currencyId, :as => :currency_id

end

class Catalog
  include SMG::Resource

  extract 'yml_catalog', :at => :date, :as => :date
  extract 'yml_catalog/shop/name'

  collect 'yml_catalog/shop/offers/offer',
    :class => Offer,
    :with => {:available => 'true'},
    :as => :available

  collect 'yml_catalog/shop/offers/offer',
    :at => :id,
    :as => :offer_ids,
    :class => :integer

  collect 'yml_catalog/shop/offers/offer',
    :at => :id,
    :as => :available_offer_ids,
    :class => :integer,
    :with => {:available => 'true'}

end

catalog = Catalog.parse(data)

puts catalog.date                           #=> 2010-08-15 16:50
puts catalog.name                           #=> 'Books.Ru'
puts catalog.offer_ids                      #=> [745663, 749548, 734220, 784182]
puts catalog.available_offer_ids            #=> [745663, 749548, 784182]
puts catalog.available.size                 #=> 3
puts catalog.available.map(&:isbn)          #=> ['978-5-93286-176-9', '978-5-93286-187-5', '978-5-93286-157-8']

offer = catalog.available.last
puts "#{offer.name}, #{offer.author}"       #=> 'Python. Подробный справочник, 4-е издание, Бизли Д.'
puts "#{offer.price} #{offer.currency_id}"  #=> '723 RUR'

# EOF