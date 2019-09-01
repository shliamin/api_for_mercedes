require 'json'
  require 'open-uri'

  latitude = Request.last.latitude
  longitude = Request.last.longitude

  if longitude.to_i > 0
    minLon = longitude.to_i - 0.3
    maxLon = longitude.to_i + 0.3
  else
    minLon = longitude.to_i + 0.3
    maxLon = longitude.to_i - 0.3
  end

  if latitude.to_i > 0
    minLat = latitude.to_i - 0.3
    maxLat = latitude.to_i + 0.3
  else
    minLat = latitude.to_i + 0.3
    maxLat = latitude.to_i - 0.3
  end

  url ="https://api.mapbox.com/geocoding/v5/mapbox.places/museum.json?bbox=#{minLon.to_s},#{minLat.to_s},#{maxLon.to_s},#{maxLat.to_s}&limit=10&access_token=pk.eyJ1Ijoic2hsaWFtaW5lZmltIiwiYSI6ImNqdmdnd3ljODA2enU0OG1tMHo3M213NzQifQ.WTmGdYvf0jgrVig_HvPwUw"
  museum_serialized = open(url).read
  mus = JSON.parse(museum_serialized)

  counter = 0
  features_number = mus["features"].count
  (0..features_number-1).each do |var|
    context_number = mus["features"][var]["context"].count
    (0..context_number-1).each do |var1|
      if mus["features"][var]["context"][var1]["id"][0..7] == "postcode"
        right_postcode = mus["features"][var]["context"][var1]["text"]
        Museum.create(name: mus["features"][var]["place_name"], postcode: right_postcode, latitude: mus["features"][var]["geometry"]["coordinates"][0], longitude: mus["features"][var]["geometry"]["coordinates"][1], position: mus["features"][var]["properties"]["address"])
        counter += 1
      elsif counter < 1
        Museum.create(name: mus["features"][var]["place_name"], latitude: mus["features"][var]["geometry"]["coordinates"][0], longitude: mus["features"][var]["geometry"]["coordinates"][1], position: mus["features"][var]["properties"]["address"])
      end
    end
  end

  json.array! @museums do |museum|
    json.extract! museum, :id, :name, :position, :latitude, :longitude, :postcode
  end

  Museum.delete_all
